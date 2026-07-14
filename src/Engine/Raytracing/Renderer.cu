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
__global__ void InitRandom(int maxX, int maxY, curandState *dCurandState) {
  int x = threadIdx.x + blockIdx.x * blockDim.x;
  int y = threadIdx.y + blockIdx.y * blockDim.y;

  if ((x >= maxX) || (y >= maxY))
    return;

  int pixelIndex = y * maxX + x;
  curand_init(1984, pixelIndex, 0, &dCurandState[pixelIndex]);
}

__global__ void Render(uint8_t *fb, Hittable **world, int maxX, int maxY, CameraParams camParams, curandState *dCurandSate) {
  int x = threadIdx.x + blockIdx.x * blockDim.x;
  int y = threadIdx.y + blockIdx.y * blockDim.y;

  if ((x >= maxX) || (y >= maxY))
    return;

  int pixelIndex = y * maxX + x;
  curandState localRandState = dCurandSate[pixelIndex];

  Triplet pixelColor(0, 0, 0);
  for (int sample = 0; sample < camParams.samplesPerPixel; sample++) {
    Ray ray = GetRay(x, y, camParams, &localRandState);
    pixelColor += RayColor(world, ray, camParams.maxDepth, &localRandState);
  }

  double r = ComputeColor(pixelColor.x, camParams.samplesPerPixel);
  double g = ComputeColor(pixelColor.y, camParams.samplesPerPixel);
  double b = ComputeColor(pixelColor.z, camParams.samplesPerPixel);

  fb[pixelIndex * 3 + 0] = (uint8_t)r;
  fb[pixelIndex * 3 + 1] = (uint8_t)g;
  fb[pixelIndex * 3 + 2] = (uint8_t)b;
}

__device__ Ray GetRay(int i, int j, CameraParams camParams, curandState *dCurandState) {
  Vector3 pixelCentre = (Vector3)camParams.pixel00Loc + (i * camParams.pixelDeltaHorizontal) + (j * camParams.pixelDeltaVertical);
  Vector3 pixelSample = pixelCentre + PixelSampleSquare(camParams, dCurandState);
  Vector3 rayOrigin = camParams.center;
  Vector3 rayDirection = pixelSample - (Vector3)rayOrigin;
  return Ray(rayOrigin, rayDirection);
}

__device__ Triplet RayColor(Hittable **world, Ray &ray, int depth, curandState *dCurandState) {
  HitRecord hitRecord;
  Interval rayTInterval(0.001, FLT_MAX);

  Triplet accumulation(0, 0, 0);
  // may still require throughput to correctly calculate attenuation.
  // for loop may also be easier for compiler to unroll and optimize than a while loop
  while (depth > 1) {
    if (!(*world)->Hit(ray, rayTInterval, hitRecord)) {
      accumulation += Triplet(0, 0, 0);
      depth--;
      break;
    }

    Ray scattered(Vector3(0, 0, 0), Vector3(0, 0, 0));
    Triplet attenuation(0, 0, 0);
    Triplet colorFromEmission = hitRecord.material->Emitted(0, 0, hitRecord.point);

    if (!hitRecord.material->Scatter(ray, hitRecord, attenuation, scattered, dCurandState)) {
      accumulation += colorFromEmission;
      ray = scattered;
      depth--;
      continue;
    }
    ray = scattered;

    Triplet colorFromScatter = attenuation * accumulation;
    accumulation += colorFromScatter;
    depth--;
  }

  return accumulation;
}

__device__ Vector3 PixelSampleSquare(CameraParams camParams, curandState *dCurandState) {
  double pX = -0.5 + curand_uniform(dCurandState);
  double pY = -0.5 + curand_uniform(dCurandState);
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
  camParams.samplesPerPixel = 1000;
  camParams.maxDepth = 200;
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
    auto diffuseLight = new DiffuseLight(Triplet(1, 0.5, 1), 3);
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

uint8_t *StartRender() {
  CameraParams camParams; // may be more performant to be a global __constant__
  InitialiseProperties(camParams);

  // create world
  Hittable **dObjectList; // objects in hittableList
  Hittable **dWorld;      // hittableList itself
  checkCudaErrors(cudaMalloc((void **)&dObjectList, 2 * sizeof(Hittable *)));
  checkCudaErrors(cudaMalloc((void **)&dWorld, sizeof(Hittable *))); // allow decaying into Hittable because only the Hit function is needed
  CreateWorld<<<1, 1>>>(dObjectList, dWorld);

  std::cout << "World Created" << std::endl;
  // create framebuffer
  int numPixels = (int)camParams.imageHeight * camParams.imageWidth;
  size_t fbSize = 3 * numPixels * sizeof(uint8_t);

  uint8_t *fb;
  checkCudaErrors(cudaMallocManaged((void **)&fb, fbSize));

  int tx = 8;
  int ty = 8;

  // Render buffer
  dim3 blocks(camParams.imageWidth / tx + 1, camParams.imageHeight / ty + 1);
  dim3 threads(tx, ty);

  curandState *dRandState;
  checkCudaErrors(cudaMalloc((void **)&dRandState, numPixels * sizeof(curandState)));

  InitRandom<<<blocks, threads>>>(camParams.imageWidth, camParams.imageHeight, dRandState);
  checkCudaErrors(cudaGetLastError());
  checkCudaErrors(cudaDeviceSynchronize());

  Render<<<blocks, threads>>>(fb, dWorld, camParams.imageWidth, camParams.imageHeight, camParams, dRandState);
  checkCudaErrors(cudaGetLastError());
  checkCudaErrors(cudaDeviceSynchronize());

  std::cout << "Done" << std::endl;

  FreeWorld<<<1, 1>>>(dObjectList, dWorld);
  checkCudaErrors(cudaGetLastError());
  checkCudaErrors(cudaFree(dObjectList));
  checkCudaErrors(cudaFree(dWorld));

  return fb;
}
