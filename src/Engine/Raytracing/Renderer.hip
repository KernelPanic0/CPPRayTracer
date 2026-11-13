#include "Renderer.hip.h"
#include "hip/hip_runtime.h"

// clang-format off
// HIP

#define checkHipErrors(val) check_hip((val), #val, __FILE__, __LINE__)
void check_hip(hipError_t result, char const *const func, const char *const file, int const line) {
  if (result) {
    std::cerr << "HIP error = " << static_cast<unsigned int>(result) << " at " << file << ":" << line << " '" << func << "' \n";
    // Make sure we call HIP Device Reset before exiting
    hipDeviceReset();
    exit(99);
  }
}
__global__ void InitRandom(int maxX, int maxY, hiprandState *dCurandState) {
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;

    if ((x >= maxX) || (y >= maxY)) return;

    int pixelIndex = y * maxX + x;
    hiprand_init(1984, pixelIndex, 0, &dCurandState[pixelIndex]);
}

__global__ void RenderSampleKernel(uint8_t *fb, Triplet *accumBuffer, Hittable **world, int maxX, int maxY, CameraParams camParams, hiprandState *dCurandSate, int sample, RenderStatistics* renderStats) {
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;

    if ((x >= maxX) || (y >= maxY)) return;

    int pixelIndex = y * maxX + x;
    hiprandState localRandState = dCurandSate[pixelIndex];

    Triplet pixelColor(0, 0, 0);
    Ray ray = GetRay(x, y, camParams, &localRandState);
    pixelColor += RayColor(world, ray, camParams.maxDepth, &localRandState, renderStats);

    if (sample == 1) {
        accumBuffer[pixelIndex] = pixelColor;
    } else {
        accumBuffer[pixelIndex] += pixelColor;
    }

    Triplet averagedColor = accumBuffer[pixelIndex] / (float)sample;

    float r = ComputeColor(averagedColor.x, 1);
    float g = ComputeColor(averagedColor.y, 1);
    float b = ComputeColor(averagedColor.z, 1);

    fb[pixelIndex * 3 + 0] = (uint8_t)r;
    fb[pixelIndex * 3 + 1] = (uint8_t)g;
    fb[pixelIndex * 3 + 2] = (uint8_t)b;

    dCurandSate[pixelIndex] = localRandState;
}

__global__ void RenderBucketKernel(uint8_t *fb, Hittable **world, int maxX, int maxY, CameraParams camParams, hiprandState *dCurandSate, int startX, int startY, bool* stopRequested, RenderStatistics* renderStats) {
    int x = startX + threadIdx.x + blockIdx.x * blockDim.x;
    int y = startY + threadIdx.y + blockIdx.y * blockDim.y;

    if ((x >= maxX) || (y >= maxY)) return;

    int pixelIndex = y * maxX + x;
    hiprandState localRandState = dCurandSate[pixelIndex];

    Triplet pixelColor(0, 0, 0);
    for (int sample = 0; sample < camParams.samplesPerPixel; sample++) {
        Ray ray = GetRay(x, y, camParams, &localRandState);
        pixelColor += RayColor(world, ray, camParams.maxDepth, &localRandState, renderStats);
    }

    float r = ComputeColor(pixelColor.x, camParams.samplesPerPixel);
    float g = ComputeColor(pixelColor.y, camParams.samplesPerPixel);
    float b = ComputeColor(pixelColor.z, camParams.samplesPerPixel);

    fb[pixelIndex * 3 + 0] = (uint8_t)r;
    fb[pixelIndex * 3 + 1] = (uint8_t)g;
    fb[pixelIndex * 3 + 2] = (uint8_t)b;
}

__device__ Ray GetRay(int i, int j, CameraParams camParams, hiprandState *dCurandState) {
    Vector3 pixelCentre = (Vector3)camParams.pixel00Loc + (i * camParams.pixelDeltaHorizontal) + (j * camParams.pixelDeltaVertical);
    Vector3 pixelSample = pixelCentre + PixelSampleSquare(camParams, dCurandState);
    Vector3 rayOrigin = camParams.center;
    Vector3 rayDirection = pixelSample - (Vector3)rayOrigin;

    return Ray(rayOrigin, rayDirection);
}

__device__ Triplet RayColor(Hittable **world, Ray &ray, int depth, hiprandState *dCurandState, RenderStatistics* renderStats) {
    HitRecord hitRecord;
    Interval rayTInterval(0.1f, FLT_MAX);

    Triplet accumulation(0, 0, 0);
    Triplet throughput(1, 1, 1);

    while (depth > 1) {
        renderStats->raysCast++;
        if (!(*world)->Hit(ray, rayTInterval, hitRecord)) {
            accumulation += throughput * Triplet(0, 0, 0);
            depth--;

            break;
        }

        Ray scattered(Vector3(0, 0, 0), Vector3(0, 0, 0));
        Triplet attenuation(0, 0, 0);
        Triplet colorFromEmission = hitRecord.material->Emitted();

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

__device__ Vector3 PixelSampleSquare(CameraParams camParams, hiprandState *dCurandState) {
    float pX = -0.5 + hiprand_uniform(dCurandState);
    float pY = -0.5 + hiprand_uniform(dCurandState);

    return (pX * camParams.pixelDeltaHorizontal) + (pY * camParams.pixelDeltaVertical);
}

__device__ float ComputeColor(float color, int samplesPerPixel) {
    float scale = 1.0 / samplesPerPixel;
    color *= scale;
    color = std::sqrt(color); // linear to gamma
    Interval intensity(0.000, 0.999);

    return 255.999 * intensity.Clamp(color);
}

__host__ void InitialiseProperties(CameraParams &camParams) {
    camParams.samplesPerPixel = 200;
    camParams.maxDepth = 15;
    camParams.center = Vector3(0, 0, 0);

    float focalLength = 1.0;
    float viewportHeight = 2.0;
    float viewportWidth = viewportHeight * ((float)camParams.imageWidth / (float)camParams.imageHeight);

    Vector3 cameraCenter(0, 0, 0);
    Vector3 viewportHorizontal(viewportWidth, 0, 0);
    Vector3 viewportVertical(0, -viewportHeight, 0); // Y inverted to match image coordinates

    camParams.pixelDeltaHorizontal = viewportHorizontal / camParams.imageWidth;
    camParams.pixelDeltaVertical = viewportVertical / camParams.imageHeight;

    Vector3 viewportTopLeft = (Vector3)cameraCenter - Vector3(0, 0, focalLength) - viewportHorizontal / 2 - viewportVertical / 2;
    camParams.pixel00Loc = viewportTopLeft + 0.5 * (camParams.pixelDeltaHorizontal + camParams.pixelDeltaVertical);
}

__global__ void CreateWorldKernel(Sphere** dSphereList, Triangle** dTriangleList, RawSphereData *spheres, RawTriangleData *triangles, size_t sphereCount, size_t triangleCount, Hittable** dWorld) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        for (int i = 0; i < sphereCount; i++) {
            *(dSphereList + i) = new Sphere(spheres[i].center, spheres[i].radius, spheres[i].material);
        }
        for (int i = 0; i < triangleCount; i++) {
            *(dTriangleList + i) = new Triangle(triangles[i].vertices, triangles[i].material);
        }

        *dWorld = new HittableList(dSphereList, dTriangleList, sphereCount, triangleCount);
  }
}

__global__ void FreeWorldKernel(Sphere **dSphereList, Triangle **dTriangleList, size_t sphereCount, size_t triangleCount, Hittable** dWorld) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        for (size_t i = 0; i < sphereCount; i++) {
            delete dSphereList[i];
        }

        for (size_t i = 0; i < triangleCount; i++) {
            delete dTriangleList[i];
        }
    }

    delete *dWorld;
}

// C++

Renderer::Renderer(int width, int height) {
    dFramebuffer = nullptr;
    dRandState = nullptr;
    dWorld = nullptr;
    hOutputBuffer = nullptr;

    checkHipErrors(hipMalloc(&dStopRequested, sizeof(bool)));
    checkHipErrors(hipMemset(dStopRequested, 0, sizeof(bool)));
    checkHipErrors(hipHostMalloc(&progress, sizeof(float)));
    checkHipErrors(hipMallocManaged(&renderStats, sizeof(RenderStatistics)));

    for (int i = 0; i < numStreams; i++) {
        checkHipErrors(hipStreamCreate(&streams[i]));
    }

    Resize(width, height);
}

void Renderer::RenderAccumulation() {
    hipMemset(dAccumulationBuffer, 0, camParams.imageWidth * camParams.imageHeight * sizeof(Triplet));

    isRendering = true;
    canvasEmpty = false;
    dim3 threads(16, 16);
    dim3 blocks((camParams.imageWidth + threads.x - 1) / threads.x, (camParams.imageHeight + threads.y - 1) / threads.y);

    for (int i = 1; i < camParams.samplesPerPixel; i++) {
        RenderSampleKernel<<<blocks, threads>>>(dFramebuffer, dAccumulationBuffer, dWorld, camParams.imageWidth, camParams.imageHeight, camParams, dRandState, i, renderStats);

        checkHipErrors(hipDeviceSynchronize());
        checkHipErrors(hipMemcpy(hOutputBuffer, dFramebuffer, numPixels * 3 * sizeof(uint8_t), hipMemcpyDeviceToHost));
        *progress = (float)i/(float)camParams.samplesPerPixel;
    }
    isRendering = false;
}

void Renderer::RenderFrame() {
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

            hipStream_t currentStream = streams[streamIdx];

            RenderBucketKernel<<<blocks, threads, 0, currentStream>>>(dFramebuffer, dWorld, camParams.imageWidth, camParams.imageHeight, camParams, dRandState, x, y, dStopRequested, renderStats);

            size_t pitch = camParams.imageWidth * 3 * sizeof(uint8_t);
            size_t offset = (y * camParams.imageWidth + x) * 3;

            uint8_t* dSrc = dFramebuffer + offset;
            uint8_t* hDst = hOutputBuffer + offset;

            checkHipErrors(hipMemcpy2DAsync(
                hDst,
                pitch,
                dSrc,
                pitch,
                currentBucketWidth * 3 * sizeof(uint8_t),
                currentBucketHeight,
                hipMemcpyDeviceToHost,
                currentStream
            ));

            float currentProgress = *progress + currentBucketWidth * currentBucketHeight / ((float)camParams.imageWidth * (float)camParams.imageHeight);
            checkHipErrors(hipMemcpyAsync(
                progress,
                &currentProgress,
                sizeof(float),
                hipMemcpyHostToHost
            ));

            streamIdx = (streamIdx + 1) % numStreams;
        }
    }

    checkHipErrors(hipDeviceSynchronize());
    isRendering = false;
}

void Renderer::Resize(int width, int height) {
    camParams.imageWidth = width;
    camParams.imageHeight = height;
    sizeDirty = true;

    InitialiseProperties(camParams);

    numPixels = width * height;

    hipMemset(progress, 0.0f, sizeof(float));
    canvasEmpty = true;
    if (hOutputBuffer) {
        checkHipErrors(hipHostFree(hOutputBuffer));
        checkHipErrors(hipFree(dAccumulationBuffer));
        hOutputBuffer = nullptr;
    }

    // PINNED host memory
    checkHipErrors(hipHostMalloc((void**)&hOutputBuffer, numPixels * 3 * sizeof(uint8_t)));
    checkHipErrors(hipMalloc(&dAccumulationBuffer, numPixels * sizeof(Triplet)));


    if (dFramebuffer) hipFree(dFramebuffer);
    if (dRandState) hipFree(dRandState);

    checkHipErrors(hipMalloc((void**)&dFramebuffer, numPixels * 3 * sizeof(uint8_t)));
    checkHipErrors(hipMalloc((void**)&dRandState, numPixels * sizeof(hiprandState)));

    dim3 threads(16, 16);
    dim3 blocks((width + threads.x - 1) / threads.x, (height + threads.y - 1) / threads.y);
    InitRandom<<<blocks, threads>>>(width, height, dRandState);
    hipDeviceSynchronize();
}

void Renderer::RequestStop() {
    // checkHipErrors(hipMemset(dStopRequested, true, sizeof(bool))); // implement later
    isRendering = false;
}

void Renderer::UpdateWorld(const WorldData &hWorld) {
    FreeWorld();
    sphereCount = hWorld.sphereCount;
    triangleCount = hWorld.triangleCount;
    size_t worldSize = sphereCount + triangleCount;
    if (worldSize == 0) return;

    RawSphereData* dWorldSphereData = nullptr;
    RawTriangleData* dWorldTriangleData = nullptr;

    checkHipErrors(hipMalloc((void**)&dWorldSphereData, sphereCount * sizeof(RawSphereData)));
    checkHipErrors(hipMemcpy(dWorldSphereData, hWorld.spheres, sphereCount * sizeof(RawSphereData), hipMemcpyHostToDevice));
    checkHipErrors(hipMalloc((void**)&dWorldTriangleData, triangleCount * sizeof(RawTriangleData)));
    checkHipErrors(hipMemcpy(dWorldTriangleData, hWorld.triangles, triangleCount * sizeof(RawTriangleData), hipMemcpyHostToDevice));

    checkHipErrors(hipMalloc((void**)&dSphereList, sphereCount * sizeof(Sphere*)));
    checkHipErrors(hipMalloc((void**)&dTriangleList, triangleCount * sizeof(Triangle*)));
    checkHipErrors(hipMalloc((void**)&dWorld, sizeof(Hittable*)));


    CreateWorldKernel<<<1, 1>>>(dSphereList, dTriangleList, dWorldSphereData, dWorldTriangleData, sphereCount, triangleCount, dWorld);
    hipDeviceSynchronize();

    hipFree(dWorldSphereData);
    hipFree(dWorldTriangleData);
}

void Renderer::FreeWorld() {
    size_t worldSize = sphereCount + triangleCount;
    if (dWorld && worldSize > 0) {
        FreeWorldKernel<<<1, 1>>>(dSphereList, dTriangleList, sphereCount, triangleCount, dWorld);
        hipDeviceSynchronize();
        hipFree(dSphereList);
        hipFree(dTriangleList);
        hipFree(dWorld);
        dSphereList = nullptr;
        dTriangleList = nullptr;
        dWorld = nullptr;
        sphereCount = 0;
        triangleCount = 0;
    }
}

Renderer::~Renderer() {
    FreeWorld();
    if (dFramebuffer) hipFree(dFramebuffer);
    if (dRandState) hipFree(dRandState);

    if (hOutputBuffer) {
        hipHostFree(hOutputBuffer);
    }

    for (int i = 0; i < numStreams; i++) {
        hipStreamDestroy(streams[i]);
    }
}
