#pragma once
#include <iostream>
#include <stdint.h>
#include "Vector.cuh"
#include "Hittable.cuh"
#include "Sphere.cuh"
#include <float.h>

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

  double aspectRatio = 16.0 / 9.0;
  int imageWidth = 400;
  double imageHeight;
  Triplet backgroundColor;
  int samplesPerPixel = 50;
  int maxDepth = 5;
};

__device__ Triplet RayColor(Hittable **world, Ray &ray, int depth, curandState *dCurandState);
__device__ Ray GetRay(int i, int j, CameraParams camParams, curandState *dCurandState);
__device__ Vector3 PixelSampleSquare(CameraParams camParams, curandState *dCurandState);
__device__ double ComputeColor(double color, int samplesPerPixel);
// __global__ void InitialiseProperties(CameraParams &camParams);

uint8_t *StartRender();