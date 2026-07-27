#pragma once
#include <iostream>
#include <stdint.h>
#include "Vector.cuh"
#include "Hittable.cuh"
#include "Sphere.cuh"
#include <float.h>
#include "RawSphereData.hpp"
#include <thread>

#ifndef __CUDACC__
#define __host__
#define __device__
#define __global__
#endif

struct CameraParams {
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

constexpr int numStreams = 8;
class CudaRenderer {
  public:
    bool isRendering = false;
    bool canvasEmpty = true;
    bool sizeDirty = false; // for regenerating texture in GraphicsManager when size changes. Probably a better way to do this
    CameraParams camParams;
    uint8_t *hOutputBuffer = nullptr;

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
    cudaStream_t streams[numStreams];

    bool *dStopRequested = nullptr;
    Triplet *dAccumulationBuffer = nullptr;
    uint8_t *dFramebuffer = nullptr;
    curandState *dRandState = nullptr;
    Hittable **dObjectList = nullptr;
    Hittable **dWorld = nullptr;
    size_t worldSize = 0;
};

__device__ Triplet RayColor(Hittable **world, Ray &ray, int depth, curandState *dCurandState);
__device__ Ray GetRay(int i, int j, CameraParams camParams, curandState *dCurandState);
__device__ Vector3 PixelSampleSquare(CameraParams camParams, curandState *dCurandState);
__device__ double ComputeColor(double color, int samplesPerPixel);
__host__ void InitialiseProperties(CameraParams &camParams);