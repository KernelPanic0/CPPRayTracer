#pragma once
#include "hip/hip_runtime.h"
#include "Interval.hip"
#include "HitRecord.hip"
#include "Ray.hip"
#include "Vector.hip"

struct Hittable {
  __device__ virtual inline bool Hit(const Ray &ray, const Interval &rayT, HitRecord &hitRecord) {
    return false;
  }
};
