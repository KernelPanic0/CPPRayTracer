#pragma once
#include "HitRecord.cuh"
#include "Ray.cuh"

#ifndef __CUDACC__
#define __host__
#define __device__
#endif

class Material {
public:
  __device__ virtual bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) = 0;
  __device__ virtual inline Triplet Emitted(double u, double v, Vector3 point) {
    return Triplet(0, 0, 0);
  }
};

class Lambertian : public Material {
private:
  Triplet albedo;

public:
  __device__ inline Lambertian() : albedo(0, 0, 0) {}

  __device__ inline Lambertian(Triplet albedo) : albedo(albedo) {}

  __device__ inline bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) override {
    Vector3 scatterDirection = hitRecord.normal + Vector3::RandomUnitVector();

    if (scatterDirection.NearZero())
      scatterDirection = hitRecord.normal;

    scattered = Ray(hitRecord.point, scatterDirection);
    attenuation = albedo;
    return true;
  }
};

class Metal : public Lambertian {
private:
  Triplet albedo;
  double fuzz;

public:
  __device__ inline Metal(Triplet albedo, double fuzz) : albedo(albedo), fuzz(fuzz) {}

  __device__ inline Metal(Triplet albedo) : albedo(albedo), fuzz(0) {}

  __device__ inline bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) override {
    Vector3 reflected = Vector3::Reflect(Vector3::UnitVector(rayIn.direction), hitRecord.normal);
    scattered = Ray(hitRecord.point, reflected + fuzz * Vector3::RandomUnitVector());
    attenuation = albedo;
    return Vector3::Dot(scattered.direction, hitRecord.normal) > 0;
  }
};

class DiffuseLight : public Material {
private:
  Triplet emit;
  double intensity;

public:
  __device__ inline DiffuseLight(Triplet emit, double intensity) : emit(emit), intensity(intensity) {}

  __device__ inline bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) override {
    return false;
  }

  __device__ inline Triplet Emitted(double u, double v, Vector3 point) override {
    return emit * intensity;
  }
};