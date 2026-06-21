#pragma once
#include "Constants.hpp"
#include <math.h>
#include <random>

// Generic Triplet type for storing things like colors to differentiate from vectors
struct Triplet {
  double x;
  double y;
  double z;

  Triplet(double x, double y, double z);
  Triplet();

  static Triplet Random();
  static Triplet Random(double min, double max);
  bool NearZero() const;

  // Operator overloads
  // +
  Triplet operator+(const Triplet &otherTriplet) const;
  // -
  Triplet operator-(const Triplet &otherTriplet) const;
  Triplet operator-();
  // *
  Triplet operator*(const Triplet &otherTriplet) const;
  Triplet operator*(double t);
  friend Triplet operator*(double t, const Triplet &v);
  // /
  Triplet operator/(double t);
};

struct Vector3 : Triplet {
  Vector3();
  Vector3(double x, double y, double z);
  Vector3(const Triplet &t);

  double Length() const;
  double LengthSquared() const;
  static Vector3 RandomInUnitSphere();
  static Vector3 RandomUnitVector();
  static Vector3 RandomOnHmisphere(const Vector3 &normal);
  static Vector3 Reflect(const Vector3 &v, const Vector3 &n);
  static double Dot(const Vector3 &vector1, const Vector3 &vector2);
  static Vector3 UnitVector(const Vector3 &vector);

  // Operator overloads
  // +
  Vector3 operator+(Vector3 otherVector);
  // -
  Vector3 operator-(Vector3 otherVector) const;
  Vector3 operator-() const;
  // *
  Vector3 operator*(Vector3 otherVector);
  Vector3 operator*(double t);
  friend Vector3 operator*(double t, const Vector3 &v);
  // /
  Vector3 operator/(double t) const;
};