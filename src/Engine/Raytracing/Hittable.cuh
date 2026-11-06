#pragma once
#include "hip/hip_runtime.h"
#include "Interval.cuh"
#include "HitRecord.cuh"
#include "Ray.cuh"
#include "Vector.cuh"

struct Hittable {
  __device__ virtual inline bool Hit(const Ray &ray, const Interval &rayT, HitRecord &hitRecord) {
    return false;
  }
};
