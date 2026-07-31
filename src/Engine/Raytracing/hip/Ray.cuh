#pragma once
#include "Vector.cuh"

#ifndef __HIPCC__
#define __host__
#define __device__
#endif

struct Ray {
  Vector3 origin;
  Vector3 direction;

  __device__ Ray(Vector3 _origin, Vector3 _direction) : origin(_origin), direction(_direction) {};
  __device__ inline Vector3 At(double t) const { return origin + t * direction; };
};