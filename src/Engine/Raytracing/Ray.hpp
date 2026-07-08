#pragma once
#include "Vector.cuh"

class Ray {
public:
  Vector3 origin;
  Vector3 direction;

  Ray(Vector3 origin, Vector3 direction);
  Vector3 At(double t);
};