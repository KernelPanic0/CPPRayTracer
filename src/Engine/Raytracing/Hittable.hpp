#pragma once
#include "Vector.hpp"

struct HitRecord {
  Vector3 point;
  Vector3 normal;
  Material material;
  double t;
  bool frontFace;

  void SetFaceNormal(Ray ray, Vector3 outwardNormal) {
    // The parameter outward should be of unit length.
    frontFace = Vector3.Dot(ray.direction, outwardNormal) < 0;
    normal = frontFace ? outwardNormal : -outwardNormal;
  }
};

struct Hittable {
public:
  virtual bool Hit(Ray ray, Interval rayT, ref HitRecord hitRecord) {
    return false;
  }
};