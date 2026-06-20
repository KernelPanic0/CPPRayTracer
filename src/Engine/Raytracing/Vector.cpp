#include "Vector.hpp"

Triplet::Triplet(double x, double y, double z) {
  this->x = x;
  this->y = y;
  this->z = z;
}

Triplet::Triplet() {
  this->x = 0;
  this->y = 0;
  this->z = 0;
}

double Vector3::Length() {
  return std::sqrt(LengthSquared());
}

double Vector3::LengthSquared() {
  return x * x + y * y + z * z;
}

Triplet Triplet::Random() {
  double x = Constants::RandomDouble();
  double y = Constants::RandomDouble();
  double z = Constants::RandomDouble();
  return Triplet(x, y, z);
}

Triplet Triplet::Random(double min, double max) {
  double x = Constants::RandomDouble() * (max - min) + min;
  double y = Constants::RandomDouble() * (max - min) + min;
  double z = Constants::RandomDouble() * (max - min) + min;
  return Triplet(x, y, z);
}

Vector3::Vector3(Triplet t) {
  this->x = t.x;
  this->y = t.y;
  this->z = t.z;
}

Vector3 Vector3::RandomInUnitSphere() {
  while (true) {
    Vector3 p = Vector3::Random(-1, 1);

    if (p.LengthSquared() < 1) {
      return p;
    }
  }
}

Vector3 Vector3::RandomUnitVector() {
  return UnitVector(RandomInUnitSphere());
}

bool Triplet::NearZero() {
  double s = 1e-8;
  return (x < s) && (y < s) && (z < s);
}

Vector3 Vector3::RandomOnHmisphere(Vector3 normal) {
  Vector3 onUnitSphere = RandomUnitVector();
  if (Dot(onUnitSphere, normal) > 0.0) // Same hemisphere as the normal
  {
    return onUnitSphere;
  } else {
    return -onUnitSphere;
  }
}

Vector3 Vector3::Reflect(Vector3 v, Vector3 n) {
  return v - 2 * Dot(v, n) * n;
}

double Vector3::Dot(Vector3 vector1, Vector3 vector2) {
  return vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z;
}

Vector3 Vector3::UnitVector(Vector3 vector) {
  return vector / vector.Length();
}

// Operator overloads to change functionality when doing math on 2 vectors
// +
Vector3 Vector3::operator+(Vector3 otherVector) {
  return Vector3(x + otherVector.x, y + otherVector.y, z + otherVector.z);
}

// -
Vector3 Vector3::operator-(Vector3 otherVector) {
  return Vector3(x - otherVector.x, y - otherVector.y, z - otherVector.z);
}

Vector3 Vector3::operator-() {
  return Vector3(-x, -y, -z);
}

// *
Vector3 Vector3::operator*(Vector3 otherVector) {
  return Vector3(x * otherVector.x, y * otherVector.y, z * otherVector.z);
}

Vector3 Vector3::operator*(double t) {
  return Vector3(x * t, y * t, z * t);
}

// /
Vector3 Vector3::operator/(double t) {
  return Vector3(x / t, y / t, z / t);
}

Vector3 operator*(double t, const Vector3 &v) {
  return Vector3(v.x * t, v.y * t, v.z * t);
}