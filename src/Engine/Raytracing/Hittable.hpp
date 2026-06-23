#pragma once
#include "Interval.hpp"
#include "Material.hpp"
#include "Ray.hpp"
#include "Vector.hpp"

struct HitRecord {
  Vector3 point;
  Vector3 normal;
  Material *material;
  double t;
  bool frontFace;

  void SetFaceNormal(Ray ray, Vector3 outwardNormal);
};

struct Hittable {
  virtual bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord);
};

struct HittableList : Hittable {
  std::vector<Hittable *> objects;

  HittableList(Hittable &objectToAdd);
  HittableList();
  void Add(Hittable &objectToAdd);
  bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) override;
};