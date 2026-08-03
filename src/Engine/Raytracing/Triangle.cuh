#pragma once
#include "Hittable.cuh"
#include "Interval.cuh"
#include "Material.cuh"
#include "Ray.cuh"
#include "Vector.cuh"

class Triangle : public Hittable {
  private:
    Vector3 vertices[3];
    Vector3 normal;
    Material *material;

  public:
    __device__ inline bool Hit(Ray ray, Interval rayT, HitRecord &hitRecord) override {
        if (Vector3::Dot(ray.direction, normal) == 0)
            return false;

        Vector3 edge1 = vertices[1] - vertices[0];
        Vector3 edge2 = vertices[2] - vertices[0];

        Vector3 p = Vector3::Cross(ray.direction, edge2);
        double det = Vector3::Dot(edge1, p);

        if (!rayT.Surrounds(abs(det)))
            return false;

        double invDet = 1 / det;
        Vector3 tVec = ray.origin - vertices[0];

        double u = Vector3::Dot(tVec, p) * invDet;
        if (u < 0 || u > 1)
            return false;

        Vector3 q = Vector3::Cross(tVec, edge1);
        double v = Vector3::Dot(ray.direction, q) * invDet;

        if (v < 0 || u + v > 1)
            return false;

        double t = Vector3::Dot(edge2, q) * invDet;
        if (t < 0)
            return false;

        hitRecord.t = t;
        hitRecord.point = ray.At(hitRecord.t);
        hitRecord.normal = normal;
        hitRecord.frontFace;
        hitRecord.material = material;

        return true;
    }
    __host__ __device__ inline Triangle(Vector3 _vertices[3], Material *material) : vertices{_vertices[0], _vertices[1], _vertices[2]}, material(material) {
        normal = Vector3::Cross(vertices[1] - vertices[0], vertices[2] - vertices[0]);
    }
};