#pragma once
#include "Hittable.cuh"
#include "Interval.cuh"
#include "Material.cuh"
#include "Ray.cuh"
#include "Vector.cuh"

class Sphere : public Hittable {
private:
  Vector3 centre;
  double radius;
  Material *material;

public:
  __device__ inline bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) override {
    Vector3 oc = (Vector3)(ray.origin - centre); // Vector to the centre of the sphere

    // Coefficients used for the quadratic equation in order to find the intersection points of the ray.
    double a = ray.direction.LengthSquared();
    double half_b = Vector3::Dot(oc, ray.direction);
    double c = oc.LengthSquared() - radius * radius;
    // Calculate discriminant to determine whether there are real solutions or not (ie if the sphere was intersected in the first place)
    double discriminant = half_b * half_b - a * c;
    if (discriminant < 0)
      return false; // The ray does NOT intersect with the sphere.
    double sqrtd = sqrt(discriminant);

    // Find nearest root that's within rayT.min and rayT.max
    double root = (-half_b - sqrtd) / a;
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
    hitRecord.material = material;
    return true;
  }

  __host__ __device__ inline Sphere(Vector3 centre, double radius, Material *material) : centre(centre), radius(radius), material(material) {}
};