#pragma once

#ifndef __CUDACC__
#define __host__
#define __device__
#endif

struct Interval {
  double min, max;

  __host__ __device__ inline Interval(double min, double max) : min(min), max(max) {}

  __host__ __device__ inline bool Contains(double x) const {
    return x >= min && x <= max;
  }

  __host__ __device__ inline bool Surrounds(double x) const {
    return x > min && x < max;
  }

  __host__ __device__ inline double Clamp(double x) const {
    if (x < min)
      return min;
    if (x > max)
      return max;
    return x;
  }
};