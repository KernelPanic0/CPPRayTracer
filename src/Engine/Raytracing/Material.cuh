#pragma once
#include "MaterialType.hpp"
#include "HitRecord.cuh"
#include "Ray.cuh"

#ifndef __HIPCC__
#define __host__
#define __device__
#endif

struct Lambertian {
  Triplet albedo;

  __host__ __device__ static Lambertian Make(Triplet albedo) {
    Lambertian m;
    m.albedo = albedo;
    return m;
  }

  __device__ bool Scatter(const Ray &rayIn, const HitRecord &hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) const {
    Vector3 scatterDirection = hitRecord.normal + Vector3::RandomUnitVector(dCurandState);

    if (scatterDirection.NearZero())
      scatterDirection = hitRecord.normal;

    scattered = Ray(hitRecord.point, scatterDirection);
    attenuation = albedo;
    return true;
  }

  __device__ Triplet Emitted() const { return Triplet(0, 0, 0); }
};

struct Sheen {
  Triplet sheen; // precomputed tint; the albedo itself is no longer needed

  static constexpr float kTintAmount = 0.5f;

  __host__ __device__ static Sheen Make(Triplet albedo) {
    // Rec. 709 luma coefficients https://en.wikipedia.org/wiki/Rec._709
    float luminance = Vector3::Dot(Triplet(0.2126, 0.7152, 0.0722), albedo);
    Triplet realTint = luminance > 0.0 ? albedo * (1.0 / luminance) : Triplet(1, 1, 1);

    Sheen m;
    m.sheen = Triplet(1.0f - kTintAmount) + Triplet(kTintAmount) * realTint;
    return m;
  }

  __device__ bool Scatter(const Ray &rayIn, const HitRecord &hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) const {
    Vector3 scatterDirection = Vector3::UnitVector(hitRecord.normal + Vector3::RandomUnitVector(dCurandState));
    if (scatterDirection.NearZero())
      scatterDirection = hitRecord.normal;

    Vector3 halfVector = Vector3::UnitVector(scatterDirection - rayIn.direction);

    float cosThetaD = fabsf(Vector3::Dot(halfVector, scatterDirection));
    float m = 1.0f - cosThetaD;
    float sheenWeight = (m * m) * (m * m) * m;

    attenuation = static_cast<float>(M_PI) * sheen * sheenWeight;
    scattered = Ray(hitRecord.point, scatterDirection);
    return true;
  }

  __device__ Triplet Emitted() const { return Triplet(0, 0, 0); }
};

struct Glass {
  float indexOfRefraction;

  __host__ __device__ static Glass Make(float indexOfRefraction = 2.417f) {
    Glass m;
    m.indexOfRefraction = indexOfRefraction;
    return m;
  }

  __device__ static float Reflectance(float cosine, float refractionIndex) {
    // Schlick approximation
    float r0 = (1.0f - refractionIndex) / (1.0f + refractionIndex);
    r0 = r0 * r0;

    float m = 1.0f - cosine;
    return r0 + (1.0f - r0) * (m * m) * (m * m) * m;
  }

  __device__ bool Scatter(const Ray &rayIn, const HitRecord &hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) const {
    attenuation = Triplet(1, 1, 1);
    float refractionIndex = hitRecord.frontFace ? (1.0f / indexOfRefraction) : indexOfRefraction;
    float cosTheta = fminf(Vector3::Dot(-rayIn.direction, hitRecord.normal), 1.0f);
    float sinTheta = sqrtf(1.0f - cosTheta * cosTheta);

    Vector3 out;
    bool canRefract = refractionIndex * sinTheta < 1.0f;

    if (!canRefract || Reflectance(cosTheta, refractionIndex) > hiprand_uniform(dCurandState)) {
      out = Vector3::Reflect(Vector3::UnitVector(rayIn.direction), hitRecord.normal);
    } else {
      out = Vector3::Refract(Vector3::UnitVector(rayIn.direction), hitRecord.normal, refractionIndex);
    }

    scattered = Ray(hitRecord.point, out);
    return true;
  }

  __device__ Triplet Emitted() const { return Triplet(0, 0, 0); }
};

struct Metal {
  Triplet albedo;
  float fuzz;

  __host__ __device__ static Metal Make(Triplet albedo, float fuzz = 0.0f) {
    Metal m;
    m.albedo = albedo;
    m.fuzz = fuzz;
    return m;
  }

  __device__ bool Scatter(const Ray &rayIn, const HitRecord &hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) const {
    Vector3 reflected = Vector3::Reflect(Vector3::UnitVector(rayIn.direction), hitRecord.normal);
    scattered = Ray(hitRecord.point, reflected + fuzz * Vector3::RandomUnitVector(dCurandState));
    attenuation = albedo;
    return Vector3::Dot(scattered.direction, hitRecord.normal) > 0;
  }

  __device__ Triplet Emitted() const { return Triplet(0, 0, 0); }
};

struct DiffuseLight {
  Triplet emit;
  float intensity;

  __host__ __device__ static DiffuseLight Make(Triplet emit, float intensity) {
    DiffuseLight m;
    m.emit = emit;
    m.intensity = intensity;
    return m;
  }

  __device__ bool Scatter(const Ray &, const HitRecord &, Triplet &, Ray &, hiprandState *) const {
    return false;
  }

  __device__ Triplet Emitted() const { return emit * intensity; }
};

struct Material {
    MaterialType type;
    union {
        Lambertian lambertian;
        Metal metal;
        Glass glass;
        Sheen sheen;
        DiffuseLight diffuseLight;
    };

    __device__ bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered, hiprandState *dCurandState) const {
        switch (type) {
            case MaterialType::DiffuseLight: return false;
            case MaterialType::Lambertian: return lambertian.Scatter(rayIn, hitRecord, attenuation, scattered, dCurandState);
            case MaterialType::Metal: return metal.Scatter(rayIn, hitRecord, attenuation, scattered, dCurandState);
            case MaterialType::Glass: return glass.Scatter(rayIn, hitRecord, attenuation, scattered, dCurandState);
            case MaterialType::Sheen: return sheen.Scatter(rayIn, hitRecord, attenuation, scattered, dCurandState);
        }
    }

    __host__ __device__ Material(MaterialType type, Triplet albedo, float fuzz, float intensity) : type(type) {
        switch (type) {
        case MaterialType::Lambertian:
            lambertian = Lambertian::Make(albedo);
            break;

        case MaterialType::Metal:
            metal = Metal::Make(albedo, fuzz);
            break;

        case MaterialType::Glass:
            glass = Glass::Make();
            break;

        case MaterialType::Sheen:
            sheen = Sheen::Make(albedo);
            break;

        case MaterialType::DiffuseLight:
            diffuseLight = DiffuseLight::Make(albedo, intensity);
            break;
        }
    }

    __device__ Triplet Emitted() const {
        switch (type) {
            case MaterialType::DiffuseLight: return diffuseLight.Emitted();
        }
        return Triplet(0, 0, 0);
    }
};