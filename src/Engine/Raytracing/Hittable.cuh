#pragma once
#include "Interval.cuh"
#include "Material.cuh"
#include "Ray.cuh"
#include "Vector.cuh"
#include <memory>

#ifndef __CUDACC__
#define __host__
#define __device__
#endif

struct HitRecord {
  Vector3 point;
  Vector3 normal;
  std::shared_ptr<Material> material;
  double t;
  bool frontFace;

  __host__ __device__ inline void SetFaceNormal(Ray ray, Vector3 outwardNormal) {
    frontFace = Vector3::Dot(ray.direction, outwardNormal) < 0;
    normal = frontFace ? outwardNormal : -outwardNormal;
  }
};

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