#include "Material.hpp"
#include "Hittable.hpp"
#include <iostream>

// bool Material::Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) {
//   return true;
// }

Triplet Material::Emitted(double u, double v, Vector3 point) { // Color
  return Triplet(0, 0, 0);
}

Lambertian::Lambertian() {}

Lambertian::Lambertian(Triplet albedo) {
  this->albedo = albedo;
}

bool Lambertian::Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) {
  Vector3 scatterDirection = hitRecord.normal + Vector3::RandomUnitVector();

  if (scatterDirection.NearZero())
    scatterDirection = hitRecord.normal;

  scattered = Ray(hitRecord.point, scatterDirection);
  attenuation = albedo;
  return true;
}

Metal::Metal(Triplet albedo, double fuzz) {
  this->albedo = albedo;
  this->fuzz = fuzz;
}

Metal::Metal(Triplet albedo) {
  this->albedo = albedo;
  this->fuzz = 0;
}

bool Metal::Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) {
  Vector3 reflected = Vector3::Reflect(Vector3::UnitVector(rayIn.direction), hitRecord.normal);
  scattered = Ray(hitRecord.point, reflected + fuzz * Vector3::RandomUnitVector());
  attenuation = albedo;
  return Vector3::Dot(scattered.direction, hitRecord.normal) > 0;
}

DiffuseLight::DiffuseLight(Triplet emit, double intensity) {
  this->emit = emit;
  this->intensity = intensity;
}

bool DiffuseLight::Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) {
  return false;
}

Triplet DiffuseLight::Emitted(double u, double v, Vector3 point) {
  return emit * intensity;
}