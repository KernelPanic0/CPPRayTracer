#pragma once
#include "hip/hip_runtime.h"
#include "Hittable.hip"
#include "Interval.hip"
#include "Material.hip"
#include "Ray.hip"
#include "Vector.hip"
#include "RawObjectData.hpp"

class Sphere : public Hittable {
private:
  Vector3 centre;
  float radius;
  Material material;

public:
  __device__ inline bool Hit(const Ray &ray, const Interval &rayT, HitRecord &hitRecord) override {
    Vector3 oc = (Vector3)(ray.origin - centre); // Vector to the centre of the sphere

    // Coefficients used for the quadratic equation in order to find the intersection points of the ray.
    float a = ray.direction.LengthSquared();
    float half_b = Vector3::Dot(oc, ray.direction);
    float c = oc.LengthSquared() - radius * radius;
    // Calculate discriminant to determine whether there are real solutions or not (ie if the sphere was intersected in the first place)
    float discriminant = half_b * half_b - a * c;
    if (discriminant < 0)
      return false; // The ray does NOT intersect with the sphere.
    float sqrtd = sqrt(discriminant);

    // Find nearest root that's within rayT.min and rayT.max
    float root = (-half_b - sqrtd) / a;
    if (!rayT.Surrounds(root)) {
      root = (-half_b + sqrtd) / a;
      if (!rayT.Surrounds(root)) {
        return false;
      }
    }

    hitRecord.t = root;
    hitRecord.point = ray.At(hitRecord.t);
    Vector3 outwardNormal = (Vector3)(hitRecord.point - centre) / radius;
    hitRecord.SetFaceNormal(ray, outwardNormal);
    hitRecord.material = &material;
    return true;
  }

  __host__ __device__ inline Sphere(Vector3 centre, float radius, RawMaterialData &rawMaterial) : centre(centre), radius(radius), material(rawMaterial.type, rawMaterial.albedo, rawMaterial.fuzz, rawMaterial.intensity) {}
};