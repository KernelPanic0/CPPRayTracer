#pragma once
#include "Hittable.hpp"
#include "Interval.hpp"
#include "Material.hpp"
#include "Ray.hpp"
#include "Vector.hpp"

class Sphere : public Hittable {
private:
  Vector3 centre;
  double radius;
  Material *material;

public:
  bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) override;
  Sphere(Vector3 centre, double radius, Material *material);
};