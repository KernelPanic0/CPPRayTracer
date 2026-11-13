#pragma once
#include "hip/hip_runtime.h"
#include <iostream>
#include <stdint.h>
#include "Vector.hip"
#include "Hittable.hip"
#include "HittableList.hip"
#include "Sphere.hip"
#include <float.h>
#include "RawObjectData.hpp"
#include "Triangle.hip"
#include <thread>

#ifndef __HIPCC__
#define __host__
#define __device__
#define __global__
#endif

struct CameraParams {
    Vector3 center;
    Vector3 pixel00Loc;
    Vector3 pixelDeltaHorizontal;
    Vector3 pixelDeltaVertical;

    float aspectNum = 16.0f;
    float aspectDenom = 9.0f;
    float aspectRatio = aspectNum / aspectDenom;
    int imageWidth = 400;
    float imageHeight;
    Triplet backgroundColor;
    int samplesPerPixel = 15;
    int maxDepth = 5;
};

struct RenderStatistics {
    int raysCast = 0;
};

constexpr int numStreams = 8;
class Renderer {
  public:
    bool isRendering = false;
    bool canvasEmpty = true;
    bool sizeDirty = false; // for regenerating texture in GraphicsManager when size changes. Probably a better way to do this
    CameraParams camParams;
    uint8_t *hOutputBuffer = nullptr;
    RenderStatistics *renderStats = nullptr;
    float *progress = nullptr;

    Renderer(int width, int height);
    void RenderFrame();
    void RenderAccumulation();
    void Resize(int width, int height);
    void RequestStop();
    void ClearOutput();
    void UpdateWorld(const WorldData &hWorld);
    void FreeWorld();
    ~Renderer();

  private:
    int numPixels;
    hipStream_t streams[numStreams];

    bool *dStopRequested = nullptr;
    Triplet *dAccumulationBuffer = nullptr;
    uint8_t *dFramebuffer = nullptr;
    hiprandState *dRandState = nullptr;
    // these will need to be grouped into struct
    Sphere **dSphereList = nullptr;
    Triangle **dTriangleList = nullptr;
    size_t sphereCount = 0;
    size_t triangleCount = 0;

    Hittable **dWorld = nullptr;
};

__device__ Triplet RayColor(Hittable **world, Ray &ray, int depth, hiprandState *dCurandState, RenderStatistics *renderStats);
__device__ Ray GetRay(int i, int j, CameraParams camParams, hiprandState *dCurandState);
__device__ Vector3 PixelSampleSquare(CameraParams camParams, hiprandState *dCurandState);
__device__ float ComputeColor(float color, int samplesPerPixel);
__host__ void InitialiseProperties(CameraParams &camParams);