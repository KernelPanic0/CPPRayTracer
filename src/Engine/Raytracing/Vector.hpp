#pragma once
#include "Constants.hpp"
#include <math.h>
#include <random>

struct Vector3 {
  double x;
  double y;
  double z;

  Vector3(double x, double y, double z);

  double Length();
  double LengthSquared();
  static Vector3 Random();
  static Vector3 Random(double min, double max);
  static Vector3 RandomInUnitSphere();
  static Vector3 RandomUnitVector();
  bool NearZero();
  static Vector3 RandomOnHmisphere(Vector3 normal);
  static Vector3 Reflect(Vector3 v, Vector3 n);
  static double Dot(Vector3 vector1, Vector3 vector2);
  static Vector3 UnitVector(Vector3 vector);

  // Operator overloads to change functionality when doing math on 2 vectors
  // +
  Vector3 operator+(Vector3 otherVector);
  // -
  Vector3 operator-(Vector3 otherVector);
  Vector3 operator-();
  // *
  Vector3 operator*(Vector3 otherVector);
  Vector3 operator*(double t);
  friend Vector3 operator*(double t, const Vector3 &v);
  // /
  Vector3 operator/(double t);
};