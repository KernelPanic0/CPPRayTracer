#include "hip/hip_runtime.h"
#pragma once
#include "Interval.cuh"
#include "HitRecord.cuh"
#include "Material.cuh"
#include "Ray.cuh"
#include "Vector.cuh"
#include <memory>

struct Hittable {
  __device__ virtual inline bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) {
    return false;
  }
};

struct HittableList : Hittable {
  Hittable **objects;
  size_t size = 0;

  __device__ inline HittableList() {}
  __device__ inline HittableList(Hittable **_objects, size_t _size) : objects(_objects), size(_size) {}

  __device__ inline void Add(Hittable *objectToAdd) {
    objects[size] = objectToAdd;
    size++;
  }

  __device__ inline bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) override {
    HitRecord tempRecord;
    bool hitAnything = false;
    double closestSoFar = rayT.max;

    for (int i = 0; i < size; i++) {
      Hittable *obj = objects[i];

      if (obj->Hit(ray, Interval(rayT.min, closestSoFar), tempRecord)) {
        hitAnything = true;
        closestSoFar = tempRecord.t;
        hitRecord = tempRecord;
      }
    }
    return hitAnything;
  }
};