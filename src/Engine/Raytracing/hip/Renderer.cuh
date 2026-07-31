#include "hip/hip_runtime.h"
#pragma once
#include "Hittable.cuh"
#include "RawSphereData.hpp"
#include "Sphere.cuh"
#include "Vector.cuh"
#include <float.h>
#include <iostream>
#include <stdint.h>
#include <thread>

#ifndef __HIPCC__
#define __host__
#define __device__
#define __global__
#endif

struct CameraParams
{
    Vector3 center;
    Vector3 pixel00Loc;
    Vector3 pixelDeltaHorizontal;
    Vector3 pixelDeltaVertical;

    double aspectNum = 16.0f;
    double aspectDenom = 9.0f;
    double aspectRatio = aspectNum / aspectDenom;
    int imageWidth = 400;
    double imageHeight;
    Triplet backgroundColor;
    int samplesPerPixel = 15;
    int maxDepth = 5;
};

struct RenderStatistics
{
    int raysCast = 0;
};

constexpr int numStreams = 8;
class CudaRenderer
{
  public:
    bool isRendering = false;
    bool canvasEmpty = true;
    bool sizeDirty = false; // for regenerating texture in GraphicsManager when
                            // size changes. Probably a better way to do this
    CameraParams camParams;
    uint8_t *hOutputBuffer = nullptr;
    RenderStatistics *renderStats = nullptr;
    float *progress = nullptr;

    CudaRenderer(int width, int height);
    void RenderFrame();
    void RenderAccumulation();
    void Resize(int width, int height);
    void RequestStop();
    void ClearOutput();
    void UpdateWorld(const std::vector<RawSphereData> &hWorld);
    void FreeWorld();
    ~CudaRenderer();

  private:
    int numPixels;
    hipStream_t streams[numStreams];

    bool *dStopRequested = nullptr;
    Triplet *dAccumulationBuffer = nullptr;
    uint8_t *dFramebuffer = nullptr;
    hiprandState *dRandState = nullptr;
    Hittable **dObjectList = nullptr;
    Hittable **dWorld = nullptr;
    size_t worldSize = 0;
};

__device__ Triplet RayColor(Hittable **world, Ray &ray, int depth,
                            hiprandState *dCurandState,
                            RenderStatistics *renderStats);
__device__ Ray GetRay(int i, int j, CameraParams camParams,
                      hiprandState *dCurandState);
__device__ Vector3 PixelSampleSquare(CameraParams camParams,
                                     hiprandState *dCurandState);
__device__ double ComputeColor(double color, int samplesPerPixel);
__host__ void InitialiseProperties(CameraParams &camParams);