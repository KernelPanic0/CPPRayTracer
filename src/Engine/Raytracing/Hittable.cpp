#include "Hittable.hpp"

void HitRecord::SetFaceNormal(Ray ray, Vector3 outwardNormal) {
  // The parameter outward should be of unit length.
  frontFace = Vector3::Dot(ray.direction, outwardNormal) < 0;
  normal = frontFace ? outwardNormal : -outwardNormal;
}

bool Hittable::Hit(Ray ray, Interval rayT, HitRecord &hitRecord) {
  return false;
}