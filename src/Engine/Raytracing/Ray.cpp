#include "Ray.hpp"

Ray::Ray(Vector3 _origin, Vector3 _direction) : origin(_origin), direction(_direction) {}

Vector3 Ray::At(double t) {
  return (origin + t * direction);
}