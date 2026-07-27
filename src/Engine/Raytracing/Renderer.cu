#include "Renderer.cuh"

// clang-format off
// CUDA

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

    if ((x >= maxX) || (y >= maxY)) return;

    int pixelIndex = y * maxX + x;
    curand_init(1984, pixelIndex, 0, &dCurandState[pixelIndex]);
}

__global__ void RenderSampleKernel(uint8_t *fb, Triplet *accumBuffer, Hittable **world, int maxX, int maxY, CameraParams camParams, curandState *dCurandSate, int sample) {
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;

    if ((x >= maxX) || (y >= maxY)) return;

    int pixelIndex = y * maxX + x;
    curandState localRandState = dCurandSate[pixelIndex];

    Triplet pixelColor(0, 0, 0);
    Ray ray = GetRay(x, y, camParams, &localRandState);
    pixelColor += RayColor(world, ray, camParams.maxDepth, &localRandState);

    if (sample == 1) {
        accumBuffer[pixelIndex] = pixelColor;
    } else {
        accumBuffer[pixelIndex] += pixelColor;
    }

    Triplet averagedColor = accumBuffer[pixelIndex] / (double)sample;

    double r = ComputeColor(averagedColor.x, 1);
    double g = ComputeColor(averagedColor.y, 1);
    double b = ComputeColor(averagedColor.z, 1);

    fb[pixelIndex * 3 + 0] = (uint8_t)r;
    fb[pixelIndex * 3 + 1] = (uint8_t)g;
    fb[pixelIndex * 3 + 2] = (uint8_t)b;
    
    dCurandSate[pixelIndex] = localRandState;
}

__global__ void RenderGridKernel(uint8_t *fb, Hittable **world, int maxX, int maxY, CameraParams camParams, curandState *dCurandSate, int startX, int startY, bool* stopRequested) {
    int x = startX + threadIdx.x + blockIdx.x * blockDim.x;
    int y = startY + threadIdx.y + blockIdx.y * blockDim.y;

    if ((x >= maxX) || (y >= maxY)) return;

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
    Triplet throughput(1, 1, 1);

    // for loop may also be easier for compiler to unroll and optimize than a while loop
    while (depth > 1) {
        if (!(*world)->Hit(ray, rayTInterval, hitRecord)) {
            accumulation += throughput * Triplet(0, 0, 0);
            depth--;

            break;
        }

        Ray scattered(Vector3(0, 0, 0), Vector3(0, 0, 0));
        Triplet attenuation(0, 0, 0);
        Triplet colorFromEmission = hitRecord.material->Emitted(0, 0, hitRecord.point);

        if (!hitRecord.material->Scatter(ray, hitRecord, attenuation, scattered, dCurandState)) {
            accumulation += throughput * colorFromEmission;
            ray = scattered;
            depth--;

            continue;
        }

        ray = scattered;
        Triplet colorFromScatter = attenuation * accumulation;
        throughput *= attenuation;
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
    camParams.samplesPerPixel = 200;
    camParams.maxDepth = 15;
    camParams.center = Vector3(0, 0, 0);

    double focalLength = 1.0;
    double viewportHeight = 2.0;
    double viewportWidth = viewportHeight * ((double)camParams.imageWidth / (double)camParams.imageHeight);

    Vector3 cameraCenter(0, 0, 0);
    Vector3 viewportHorizontal(viewportWidth, 0, 0);
    Vector3 viewportVertical(0, -viewportHeight, 0); // Y inverted to match image coordinates

    camParams.pixelDeltaHorizontal = viewportHorizontal / camParams.imageWidth;
    camParams.pixelDeltaVertical = viewportVertical / camParams.imageHeight;

    Vector3 viewportTopLeft = (Vector3)cameraCenter - Vector3(0, 0, focalLength) - viewportHorizontal / 2 - viewportVertical / 2;
    camParams.pixel00Loc = viewportTopLeft + 0.5 * (camParams.pixelDeltaHorizontal + camParams.pixelDeltaVertical);
}

__global__ void CreateWorldKernel(Hittable **dHittableList, Hittable **dWorld, RawSphereData *world, size_t size) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
    for (int i = 0; i < size; i++) {
        *(dHittableList + i) = new Sphere(world[i].center, world[i].radius, world[i].material.Build());
    }

    *dWorld = new HittableList(dHittableList, size);
  }
}

__global__ void FreeWorldKernel(Hittable **dHittableList, Hittable **dWorld, size_t size) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        for (size_t i = 0; i < size; i++) {
            delete dHittableList[i];
        }
    }

    delete *dWorld;
}

// C++

CudaRenderer::CudaRenderer(int width, int height) {
    dFramebuffer = nullptr;
    dRandState = nullptr;
    dWorld = nullptr;
    dObjectList = nullptr;
    hOutputBuffer = nullptr;

    checkCudaErrors(cudaMalloc((void**)&dStopRequested, sizeof(bool)));
    checkCudaErrors(cudaMemset(dStopRequested, 0, sizeof(bool)));

    for (int i = 0; i < numStreams; i++) {
        checkCudaErrors(cudaStreamCreate(&streams[i]));
    }

    Resize(width, height);
}

void CudaRenderer::RenderAccumulation() {
    cudaMemset(dAccumulationBuffer, 0, camParams.imageWidth * camParams.imageHeight * sizeof(Triplet));

    isRendering = true;
    canvasEmpty = false;
    dim3 threads(16, 16);
    dim3 blocks((camParams.imageWidth + threads.x - 1) / threads.x, (camParams.imageHeight + threads.y - 1) / threads.y);

    for (int i = 1; i < camParams.samplesPerPixel; i++) {
        RenderSampleKernel<<<blocks, threads>>>(dFramebuffer, dAccumulationBuffer, dWorld, camParams.imageWidth, camParams.imageHeight, camParams, dRandState, i);

        checkCudaErrors(cudaDeviceSynchronize());
        checkCudaErrors(cudaMemcpy(hOutputBuffer, dFramebuffer, numPixels * 3 * sizeof(uint8_t), cudaMemcpyDeviceToHost));    
    }
    isRendering = false;
}

void CudaRenderer::RenderFrame() {
    isRendering = true;
    canvasEmpty = false;
    int bucketSize = 64;
    dim3 threads(16, 16);
    int streamIdx = 0;

    for (int x = 0; x < camParams.imageWidth; x += bucketSize) {
        for (int y = 0; y < camParams.imageHeight; y += bucketSize) {
            int currentBucketWidth = std::min(bucketSize, camParams.imageWidth - x);
            int currentBucketHeight = std::min(bucketSize, (int)camParams.imageHeight - y);

            dim3 blocks((currentBucketWidth + threads.x - 1) / threads.x, (currentBucketHeight + threads.y - 1) / threads.y);

            cudaStream_t currentStream = streams[streamIdx];

            RenderGridKernel<<<blocks, threads, 0, currentStream>>>(dFramebuffer, dWorld, camParams.imageWidth, camParams.imageHeight, camParams, dRandState, x, y, dStopRequested);

            size_t pitch = camParams.imageWidth * 3 * sizeof(uint8_t);
            size_t offset = (y * camParams.imageWidth + x) * 3;

            uint8_t* dSrc = dFramebuffer + offset;
            uint8_t* hDst = hOutputBuffer + offset;

            checkCudaErrors(cudaMemcpy2DAsync(
                hDst,                                 
                pitch,                                
                dSrc,                                 
                pitch,                                
                currentBucketWidth * 3 * sizeof(uint8_t),
                currentBucketHeight,                   
                cudaMemcpyDeviceToHost,
                currentStream
            ));

            streamIdx = (streamIdx + 1) % numStreams;
        }
    }

    checkCudaErrors(cudaDeviceSynchronize());
    isRendering = false;
}

void CudaRenderer::Resize(int width, int height) {
    camParams.imageWidth = width;
    camParams.imageHeight = height;
    sizeDirty = true;

    InitialiseProperties(camParams);

    if (numPixels == width * height && hOutputBuffer != nullptr) {
        return; 
    }
    
    numPixels = width * height;

    canvasEmpty = true;
    if (hOutputBuffer) {
        checkCudaErrors(cudaFreeHost(hOutputBuffer));
        hOutputBuffer = nullptr;
    }

    // PINNED host memory
    checkCudaErrors(cudaMallocHost((void**)&hOutputBuffer, numPixels * 3 * sizeof(uint8_t)));
    checkCudaErrors(cudaMalloc(&dAccumulationBuffer, numPixels * sizeof(Triplet)));


    if (dFramebuffer) cudaFree(dFramebuffer);
    if (dRandState) cudaFree(dRandState);

    checkCudaErrors(cudaMalloc((void**)&dFramebuffer, numPixels * 3 * sizeof(uint8_t)));
    checkCudaErrors(cudaMalloc((void**)&dRandState, numPixels * sizeof(curandState)));

    dim3 threads(16, 16);
    dim3 blocks((width + threads.x - 1) / threads.x, (height + threads.y - 1) / threads.y);
    InitRandom<<<blocks, threads>>>(width, height, dRandState);
    cudaDeviceSynchronize();
}

void CudaRenderer::RequestStop() {
    // checkCudaErrors(cudaMemset(dStopRequested, true, sizeof(bool))); // implement later
    isRendering = false;
}

void CudaRenderer::UpdateWorld(const std::vector<RawSphereData> &hWorld) {
    FreeWorld();
    worldSize = hWorld.size();
    if (worldSize == 0) return;

    RawSphereData* dWorldData = nullptr;
    checkCudaErrors(cudaMalloc((void**)&dWorldData, worldSize * sizeof(RawSphereData)));
    checkCudaErrors(cudaMemcpy(dWorldData, hWorld.data(), worldSize * sizeof(RawSphereData), cudaMemcpyHostToDevice));

    checkCudaErrors(cudaMalloc((void**)&dObjectList, worldSize * sizeof(Hittable*)));
    checkCudaErrors(cudaMalloc((void**)&dWorld, sizeof(Hittable*)));

    CreateWorldKernel<<<1, 1>>>(dObjectList, dWorld, dWorldData, worldSize);
    cudaDeviceSynchronize();

    cudaFree(dWorldData);
}

void CudaRenderer::FreeWorld() {
    if (dWorld && worldSize > 0) {
        FreeWorldKernel<<<1, 1>>>(dObjectList, dWorld, worldSize);
        cudaDeviceSynchronize();
        cudaFree(dObjectList);
        cudaFree(dWorld);
        dObjectList = nullptr;
        dWorld = nullptr;
        worldSize = 0;
    }
}

CudaRenderer::~CudaRenderer() {
    FreeWorld();
    if (dFramebuffer) cudaFree(dFramebuffer);
    if (dRandState) cudaFree(dRandState);

    if (hOutputBuffer) {
        cudaFreeHost(hOutputBuffer);
    }

    for (int i = 0; i < numStreams; i++) {
        cudaStreamDestroy(streams[i]);
    }
}