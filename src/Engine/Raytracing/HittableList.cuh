#include "Ray.cuh"
#include "Sphere.cuh"
#include "Triangle.cuh"
#include "Hittable.cuh"
#include "Interval.cuh"
#include "HitRecord.cuh"

struct HittableList : Hittable {
  Sphere **spheres;
  Triangle **triangles;
  size_t sphereCount = 0;
  size_t triangleCount = 0;

  __device__ inline HittableList() {}
  __device__ inline HittableList(Sphere **_spheres, Triangle** _triangles, size_t sCount, size_t tCount):
    spheres(_spheres),
    triangles(_triangles),
    sphereCount(sCount),
    triangleCount(tCount) {}

  __device__ inline bool Hit(const Ray &ray, const Interval &rayT, HitRecord &hitRecord) override {
    HitRecord tempRecord;
    bool hitAnything = false;
    float closestSoFar = rayT.max;

    for (int i = 0; i < sphereCount; i++) {
      Sphere *sphere = spheres[i];

      if (sphere->Hit(ray, Interval(rayT.min, closestSoFar), tempRecord)) {
        hitAnything = true;
        closestSoFar = tempRecord.t;
        hitRecord = tempRecord;
      }
    }

    for (int i = 0; i < triangleCount; i++) {
      Triangle *triangle = triangles[i];

      if (triangle->Hit(ray, Interval(rayT.min, closestSoFar), tempRecord)) {
        hitAnything = true;
        closestSoFar = tempRecord.t;
        hitRecord = tempRecord;
      }
    }
    return hitAnything;
  }
};