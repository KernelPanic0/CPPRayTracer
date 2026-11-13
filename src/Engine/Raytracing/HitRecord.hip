#pragma once
#include <memory>
#include "Vector.hip"
#include "Ray.hip"

#ifndef __HIPCC__
#define __host__
#define __device__
#endif

struct Material;

struct HitRecord {
  Vector3 point;
  Vector3 normal;
  Material *material;
  float t;
  bool frontFace;

  __device__ inline void SetFaceNormal(Ray ray, Vector3 outwardNormal) {
    frontFace = Vector3::Dot(ray.direction, outwardNormal) < 0;
    normal = frontFace ? outwardNormal : -outwardNormal;
  }
};
