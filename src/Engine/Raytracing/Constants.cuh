#pragma once
#include <limits>
#include <math.h>
#include <random>
#include <curand_kernel.h>

#ifndef __CUDACC__
#define __host__
#define __device__
#endif

class Constants {
private:
  static inline std::mt19937 gen{std::random_device{}()};
  static inline std::uniform_real_distribution<double> dist{0.0, 1.0};

public:
  static constexpr double infinity = std::numeric_limits<double>::max();
  static constexpr double pi = M_PI;

  __device__ static inline double DegreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  __device__ static inline double RandomDouble() {
    // return (double)gen() / (double)std::mt19937::max();
    return 0.5;
  }
};