#pragma once
#include "Ray.hpp"

struct HitRecord; // forward declaration - no include needed

class Material {
public:
  virtual bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) = 0;
  virtual Triplet Emitted(double u, double v, Vector3 point); // Color
};

class Lambertian : public Material {
private:
  Triplet albedo;

public:
  Lambertian();
  Lambertian(Triplet albedo);
  bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) override;
};

class Metal : public Lambertian {
private:
  Triplet albedo;
  double fuzz;

public:
  Metal(Triplet albedo, double fuzz);
  Metal(Triplet albedo);
  bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) override;
};

class DiffuseLight : public Material {
private:
  Triplet emit;
  double intensity;

public:
  DiffuseLight(Triplet emit, double intensity);
  bool Scatter(Ray rayIn, HitRecord hitRecord, Triplet &attenuation, Ray &scattered) override;
  Triplet Emitted(double u, double v, Vector3 point) override;
};