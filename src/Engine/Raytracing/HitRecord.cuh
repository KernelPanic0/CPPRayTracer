#pragma once
#include <memory>
#include "Vector.cuh"
#include "Ray.cuh"

#ifndef __CUDACC__
#define __host__
#define __device__
#endif

struct Material;

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
