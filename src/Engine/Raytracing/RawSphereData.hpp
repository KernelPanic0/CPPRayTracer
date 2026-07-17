#pragma once
#include "Vector.cuh"
#include "Material.cuh"

enum class MaterialType { Lambertian,
                          Metal,
                          DiffuseLight };

struct RawMaterialData {
  MaterialType type;
  Triplet albedo;
  double fuzz = 0.0;      // Metal only
  double intensity = 1.0; // DiffuseLight only

  __device__ Material *Build() {
    switch (type) {
    case MaterialType::Lambertian:
      return new Lambertian(albedo);
    case MaterialType::Metal:
      return new Metal(albedo, fuzz);
    case MaterialType::DiffuseLight:
      return new DiffuseLight(albedo, intensity);
    default:
      return nullptr;
    }
  };
};

struct RawSphereData {
  Vector3 center;
  double radius;
  RawMaterialData material;
};