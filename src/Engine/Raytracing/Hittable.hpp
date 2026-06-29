#pragma once
#include "Interval.hpp"
#include "Material.hpp"
#include "Ray.hpp"
#include "Vector.hpp"
#include <memory>

struct HitRecord {
  Vector3 point;
  Vector3 normal;
  std::shared_ptr<Material> material;
  double t;
  bool frontFace;

  void SetFaceNormal(Ray ray, Vector3 outwardNormal);
};

struct Hittable {
  virtual bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord);
};

struct HittableList : Hittable {
  std::vector<std::shared_ptr<Hittable>> objects;

  HittableList(std::shared_ptr<Hittable> objectToAdd);
  HittableList();
  void Add(std::shared_ptr<Hittable> objectToAdd);
  bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) override;
};