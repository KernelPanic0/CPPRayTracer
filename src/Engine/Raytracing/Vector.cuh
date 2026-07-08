#pragma once
#include "Constants.hpp"
#include <math.h>
#include <random>

#ifndef __CUDACC__
#define __host__
#define __device__
#endif

// Generic Triplet type for storing things like colors to differentiate from vectors
struct Triplet {
  double x{0}, y{0}, z{0};

  __host__ __device__ Triplet() = default;
  __host__ __device__ Triplet(double x, double y, double z) : x(x), y(y), z(z) {}

  __host__ __device__ static inline Triplet Random() {
    double x = Constants::RandomDouble();
    double y = Constants::RandomDouble();
    double z = Constants::RandomDouble();
    return Triplet(x, y, z);
  }

  __host__ __device__ static inline Triplet Random(double min, double max) {
    double x = Constants::RandomDouble() * (max - min) + min;
    double y = Constants::RandomDouble() * (max - min) + min;
    double z = Constants::RandomDouble() * (max - min) + min;
    return Triplet(x, y, z);
  }

  __host__ __device__ inline bool NearZero() const {
    constexpr double s = 1e-8;
    return (fabs(x) < s) && (fabs(y) < s) && (fabs(z) < s);
  }

  // Operator overloads
  // +
  __host__ __device__ inline Triplet operator+(const Triplet &otherTriplet) const {
    return Triplet(x + otherTriplet.x, y + otherTriplet.y, z + otherTriplet.z);
  }

  __host__ __device__ inline Triplet &operator+=(const Triplet &otherTriplet) {
    x += otherTriplet.x;
    y += otherTriplet.y;
    z += otherTriplet.z;
    return *this;
  }

  // -
  __host__ __device__ inline Triplet operator-(const Triplet &otherTriplet) const {
    return Triplet(x - otherTriplet.x, y - otherTriplet.y, z - otherTriplet.z);
  }

  __host__ __device__ inline Triplet operator-() const {
    return Triplet(-x, -y, -z);
  }

  // *
  __host__ __device__ inline Triplet operator*(const Triplet &otherTriplet) const {
    return Triplet(x * otherTriplet.x, y * otherTriplet.y, z * otherTriplet.z);
  }

  __host__ __device__ inline Triplet operator*(double t) const {
    return Triplet(x * t, y * t, z * t);
  }

  __host__ __device__ friend inline Triplet operator*(double t, const Triplet &v) {
    return Triplet(v.x * t, v.y * t, v.z * t);
  }

  // /
  __host__ __device__ inline Triplet operator/(double t) const {
    return Triplet(x / t, y / t, z / t);
  }
};

struct Vector3 : Triplet {
  __host__ __device__ inline Vector3() : Triplet(0, 0, 0) {}

  __host__ __device__ inline Vector3(double x, double y, double z) : Triplet(x, y, z) {}

  __host__ __device__ inline Vector3(const Triplet &t) : Triplet(t.x, t.y, t.z) {}

  __host__ __device__ inline double Length() const {
    return sqrt(LengthSquared());
  }

  __host__ __device__ inline double LengthSquared() const {
    return x * x + y * y + z * z;
  }

  __host__ __device__ static inline Vector3 RandomInUnitSphere() {
    while (true) {
      Vector3 p = Vector3::Random(-1, 1);
      if (p.LengthSquared() < 1) {
        return p;
      }
    }
  }

  __host__ __device__ static inline Vector3 RandomUnitVector() {
    return UnitVector(RandomInUnitSphere());
  }

  __host__ __device__ static inline Vector3 RandomOnHmisphere(const Vector3 &normal) {
    Vector3 onUnitSphere = RandomUnitVector();
    if (Dot(onUnitSphere, normal) > 0.0) {
      return onUnitSphere;
    } else {
      return -onUnitSphere;
    }
  }

  __host__ __device__ static inline Vector3 Reflect(const Vector3 &v, const Vector3 &n) {
    return v - 2 * Dot(v, n) * n;
  }

  __host__ __device__ static inline double Dot(const Vector3 &vector1, const Vector3 &vector2) {
    return vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z;
  }

  __host__ __device__ static inline Vector3 UnitVector(const Vector3 &vector) {
    return vector / vector.Length();
  }

  // Operator overloads
  // +
  __host__ __device__ inline Vector3 operator+(Vector3 otherVector) const {
    return Vector3(x + otherVector.x, y + otherVector.y, z + otherVector.z);
  }

  // -
  __host__ __device__ inline Vector3 operator-(Vector3 otherVector) const {
    return Vector3(x - otherVector.x, y - otherVector.y, z - otherVector.z);
  }

  __host__ __device__ inline Vector3 operator-() const {
    return Vector3(-x, -y, -z);
  }

  // *
  __host__ __device__ inline Vector3 operator*(Vector3 otherVector) const {
    return Vector3(x * otherVector.x, y * otherVector.y, z * otherVector.z);
  }

  __host__ __device__ inline Vector3 operator*(double t) const {
    return Vector3(x * t, y * t, z * t);
  }

  __host__ __device__ friend inline Vector3 operator*(double t, const Vector3 &v) {
    return Vector3(v.x * t, v.y * t, v.z * t);
  }

  // /
  __host__ __device__ inline Vector3 operator/(double t) const {
    return Vector3(x / t, y / t, z / t);
  }
};