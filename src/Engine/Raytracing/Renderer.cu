#include "Renderer.cuh"

#define checkCudaErrors(val) check_cuda((val), #val, __FILE__, __LINE__)
void check_cuda(cudaError_t result, char const *const func, const char *const file, int const line) {
  if (result) {
    std::cerr << "CUDA error = " << static_cast<unsigned int>(result) << " at " << file << ":" << line << " '" << func << "' \n";
    // Make sure we call CUDA Device Reset before exiting
    cudaDeviceReset();
    exit(99);
  }
}

__global__ void Render(uint8_t *fb, Hittable **world, int maxX, int maxY, CameraParams camParams) {
  int x = threadIdx.x + blockIdx.x * blockDim.x;
  int y = threadIdx.y + blockIdx.y * blockDim.y;

  if ((x >= maxX) || (y >= maxY))
    return;

  int pixel_index = y * maxX * 3 + x * 3;

  Triplet pixelColor(0, 0, 0);
  for (int sample = 0; sample < camParams.samplesPerPixel; sample++) {
    Ray ray = GetRay(x, y, camParams);
    pixelColor += RayColor(world, ray, camParams.maxDepth);
  }

  double r = ComputeColor(pixelColor.x, camParams.samplesPerPixel);
  double g = ComputeColor(pixelColor.y, camParams.samplesPerPixel);
  double b = ComputeColor(pixelColor.z, camParams.samplesPerPixel);

  fb[pixel_index + 0] = (uint8_t)r;
  fb[pixel_index + 1] = (uint8_t)g;
  fb[pixel_index + 2] = (uint8_t)b;
}

__device__ Ray GetRay(int i, int j, CameraParams camParams) {
  Vector3 pixelCentre = (Vector3)camParams.pixel00Loc + (i * camParams.pixelDeltaHorizontal) + (j * camParams.pixelDeltaVertical);
  Vector3 pixelSample = pixelCentre + PixelSampleSquare(camParams);
  Vector3 rayOrigin = camParams.center;
  Vector3 rayDirection = pixelSample - (Vector3)rayOrigin;
  return Ray(rayOrigin, rayDirection);
}

__device__ Triplet RayColor(Hittable **world, const Ray &ray, int depth) {
  if (depth <= 0)
    return Triplet(0, 0, 0);

  HitRecord hitRecord;
  Interval rayTInterval(0.001, Constants::infinity);

  if (!(*world)->Hit(ray, rayTInterval, hitRecord))
    return Triplet(0, 0, 0); // background color

  Ray scattered(Vector3(0, 0, 0), Vector3(0, 0, 0));
  Triplet attenuation(0, 0, 0);
  Triplet colorFromEmission = hitRecord.material->Emitted(0, 0, hitRecord.point);

  if (!hitRecord.material->Scatter(ray, hitRecord, attenuation, scattered))
    return colorFromEmission;

  Triplet colorFromScatter = attenuation * RayColor(world, scattered, depth - 1);
  return colorFromEmission + colorFromScatter;
}

__device__ Vector3 PixelSampleSquare(CameraParams camParams) {
  double pX = -0.5 + Constants::RandomDouble();
  double pY = -0.5 + Constants::RandomDouble();
  return (pX * camParams.pixelDeltaHorizontal) + (pY * camParams.pixelDeltaVertical);
}

__device__ double ComputeColor(double color, int samplesPerPixel) {
  double scale = 1.0 / samplesPerPixel;
  color *= scale;
  color = std::sqrt(color); // linear to gamma
  Interval intensity(0.000, 0.999);
  return 255.999 * intensity.Clamp(color);
}

__host__ void InitialiseProperties(CameraParams &camParams) {
  camParams.imageHeight = camParams.imageWidth / camParams.aspectRatio;
  camParams.imageHeight = (camParams.imageHeight < 1) ? 1 : camParams.imageHeight;
  camParams.center = Vector3(0, 0, 0);

  double focalLength = 1.0;
  double viewportHeight = 2.0;
  double viewportWidth = viewportHeight * ((double)camParams.imageWidth / camParams.imageHeight);

  Vector3 cameraCenter(0, 0, 0);
  Vector3 viewportHorizontal(viewportWidth, 0, 0);
  Vector3 viewportVertical(0, -viewportHeight, 0); // Y inverted to match image coordinates

  camParams.pixelDeltaHorizontal = viewportHorizontal / camParams.imageWidth;
  camParams.pixelDeltaVertical = viewportVertical / camParams.imageHeight;

  Vector3 viewportTopLeft = (Vector3)cameraCenter - Vector3(0, 0, focalLength) - viewportHorizontal / 2 - viewportVertical / 2;

  camParams.pixel00Loc = viewportTopLeft + 0.5 * (camParams.pixelDeltaHorizontal + camParams.pixelDeltaVertical);
}

__global__ void CreateWorld(Hittable **dHittableList, Hittable **dWorld) {
  if (threadIdx.x == 0 && blockIdx.x == 0) {
    auto diffuseLight = new DiffuseLight(Triplet(1, 1, 1), 3);
    auto mSurface = new Lambertian(Triplet(1, 1, 1));

    *(dHittableList) = new Sphere(Vector3(0, 2.8, -2), 1, diffuseLight);        // light source
    *(dHittableList + 1) = new Sphere(Vector3(0, -50002, -5), 50000, mSurface); // floor

    *dWorld = new HittableList(dHittableList, 2);
  }
}

__global__ void FreeWorld(Hittable **dHittableList, Hittable **dWorld) {
  delete *(dHittableList);
  delete *(dHittableList + 1);
  delete *dWorld;
}

uint8_t *StartRender(int imageHeight, int imageWidth) {
  CameraParams camParams;
  InitialiseProperties(camParams);
  // create world
  Hittable **dObjectList; // objects in hittableList
  Hittable **dWorld;      // hittableList itself
  checkCudaErrors(cudaMalloc((void **)&dObjectList, 2 * sizeof(Hittable *)));
  checkCudaErrors(cudaMalloc((void **)&dWorld, sizeof(Hittable *))); // allow decaying into Hittable because only the Hit function is needed
  CreateWorld<<<1, 1>>>(dObjectList, dWorld);

  std::cout << "World Created" << std::endl;
  // create framebuffer
  int numPixels = (int)imageHeight * imageWidth;
  size_t fbSize = 3 * numPixels * sizeof(uint8_t);

  uint8_t *fb;
  checkCudaErrors(cudaMallocManaged((void **)&fb, fbSize));

  int tx = 8;
  int ty = 8;

  // Render buffer
  dim3 blocks(imageWidth / tx + 1, imageHeight / ty + 1);
  dim3 threads(tx, ty);

  std::cout << "Starting Render" << std::endl;
  Render<<<blocks, threads>>>(fb, dWorld, imageWidth, imageHeight, camParams);
  checkCudaErrors(cudaGetLastError());
  checkCudaErrors(cudaDeviceSynchronize());

  std::cout << "Done" << std::endl;

  FreeWorld<<<1, 1>>>(dObjectList, dWorld);
  checkCudaErrors(cudaGetLastError());
  checkCudaErrors(cudaFree(dObjectList));
  checkCudaErrors(cudaFree(dWorld));

  return fb;
}
