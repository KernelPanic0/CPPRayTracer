#pragma once
#include "Vector.hpp"

class Ray {
public:
  Vector3 origin;
  Vector3 direction;

  Ray(Vector3 origin, Vector3 direction);
  Vector3 At(double t);
};