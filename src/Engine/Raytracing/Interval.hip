#pragma once
#include "hip/hip_runtime.h"

#ifndef __HIPCC__
#define __host__
#define __device__
#endif

struct Interval {
  float min, max;

  __device__ inline Interval(float min, float max) : min(min), max(max) {}

  __device__ inline bool Contains(float x) const {
    return x >= min && x <= max;
  }

  __device__ inline bool Surrounds(float x) const {
    return x > min && x < max;
  }

  __device__ inline float Clamp(float x) const {
    if (x < min)
      return min;
    if (x > max)
      return max;
    return x;
  }
};