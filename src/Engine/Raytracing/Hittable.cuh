#pragma once
#include "Interval.cuh"
#include "HitRecord.cuh"
#include "Material.cuh"
#include "Ray.cuh"
#include "Vector.cuh"
#include <memory>

struct Hittable {
  __host__ __device__ virtual inline bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) {
    return false;
  }
};

struct HittableList : Hittable {
  std::vector<std::shared_ptr<Hittable>> objects;

  __host__ __device__ inline HittableList() {}

  __host__ __device__ inline HittableList(std::shared_ptr<Hittable> objectToAdd) {
    objects.push_back(objectToAdd);
  }

  __host__ __device__ inline void Add(std::shared_ptr<Hittable> objectToAdd) {
    objects.push_back(objectToAdd);
  }

  __host__ __device__ inline bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) override {
    HitRecord tempRecord;
    bool hitAnything = false;
    double closestSoFar = rayT.max;

    for (std::shared_ptr<Hittable> obj : objects) {
      if (obj->Hit(ray, Interval(rayT.min, closestSoFar), tempRecord)) {
        hitAnything = true;
        closestSoFar = tempRecord.t;
        hitRecord = tempRecord;
      }
    }
    return hitAnything;
  }
};