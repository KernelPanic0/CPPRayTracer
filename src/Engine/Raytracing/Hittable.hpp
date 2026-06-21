#pragma once
#include "Interval.hpp"
#include "Ray.hpp"
#include "Vector.hpp"

struct HitRecord {
  Vector3 point;
  Vector3 normal;
  Material material;
  double t;
  bool frontFace;

  void SetFaceNormal(Ray ray, Vector3 outwardNormal);
};

struct Hittable {
public:
  virtual bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord);
};