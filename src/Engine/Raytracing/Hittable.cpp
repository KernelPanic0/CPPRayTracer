#include "Hittable.hpp"

void HitRecord::SetFaceNormal(Ray ray, Vector3 outwardNormal) {
  // The parameter outward should be of unit length.
  frontFace = Vector3::Dot(ray.direction, outwardNormal) < 0;
  normal = frontFace ? outwardNormal : -outwardNormal;
}

bool Hittable::Hit(Ray ray, Interval rayT, HitRecord &hitRecord) {
  return false;
}

HittableList::HittableList() {}

HittableList::HittableList(std::shared_ptr<Hittable> objectToAdd) {
  objects.push_back(objectToAdd);
}

void HittableList::Add(std::shared_ptr<Hittable> objectToAdd) {
  objects.push_back(objectToAdd);
};

bool HittableList::Hit(Ray ray, Interval rayT, HitRecord &hitRecord) {
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