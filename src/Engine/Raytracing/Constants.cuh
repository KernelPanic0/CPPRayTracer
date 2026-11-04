#pragma once
#include "hip/hip_runtime.h"
#include <limits>
#include <math.h>
#include <random>
#include <hiprand/hiprand_kernel.h>

#ifndef __HIPCC__
#define __host__
#define __device__
#endif

class Constants {
public:
  static constexpr float infinity = std::numeric_limits<float>::max();
  static constexpr float pi = M_PI;

  __device__ static inline float DegreesToRadians(float degrees) {
    return degrees * pi / 180.0;
  }
};