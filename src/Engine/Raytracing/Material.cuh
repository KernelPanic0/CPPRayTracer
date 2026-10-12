#pragma once
#include "HitRecord.cuh"
#include "Ray.cuh"

#ifndef __HIPCC__
#define __host__
#define __device__
#endif

class Material {
public:
  __device__ virtual bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) = 0;
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

  __device__ inline bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) override {
    Vector3 scatterDirection = hitRecord.normal + Vector3::RandomUnitVector(dCurandState);

    if (scatterDirection.NearZero())
      scatterDirection = hitRecord.normal;

    scattered = Ray(hitRecord.point, scatterDirection);
    attenuation = albedo;
    return true;
  }
};

class Sheen : public Material {
private:
  Triplet albedo;
  double tintAmount = 0.5;

public:
  __device__ inline Sheen() : albedo(0, 0, 0) {}

  __device__ inline Sheen(Triplet albedo) : albedo(albedo) {}

  __device__ inline bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) override {
    Vector3 scatterDirection = Vector3::UnitVector(hitRecord.normal + Vector3::RandomUnitVector(dCurandState));
    if (scatterDirection.NearZero())
        scatterDirection = hitRecord.normal;

    // Based on Rec 709 Luma coefficients https://en.wikipedia.org/wiki/Rec._709
    double luminance = Vector3::Dot(Triplet(0.2126, 0.7152, 0.0722), albedo); // TODO: this actually needs to be a triplet and needs its own "dot" implementation

    Triplet realTint = luminance > 0.0 ? albedo * (1.0 / luminance) : Triplet(1, 1, 1);
    Triplet sheen = Triplet((1.0 - tintAmount)) + Triplet(tintAmount) * realTint;

    Vector3 halfVector = Vector3::UnitVector(scatterDirection - rayIn.direction);

    double cosThetaD = std::abs(Vector3::Dot(halfVector, scatterDirection));
    double cosThetaO = std::abs(Vector3::Dot(hitRecord.normal, scatterDirection));
    double radiance = pow(1.0 - cosThetaD, 5.0) * cosThetaO;

    attenuation = M_PI * sheen * radiance;
    scattered = Ray(hitRecord.point, scatterDirection);
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

  __device__ inline bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) override {
    Vector3 reflected = Vector3::Reflect(Vector3::UnitVector(rayIn.direction), hitRecord.normal);
    scattered = Ray(hitRecord.point, reflected + fuzz * Vector3::RandomUnitVector(dCurandState));
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

  __device__ inline bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) override {
    return false;
  }

  __device__ inline Triplet Emitted(double u, double v, Vector3 point) override {
    return emit * intensity;
  }
};