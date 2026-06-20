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
  bool NearZero();

  // Operator overloads
  // +
  Triplet operator+(Triplet otherTriplet);
  // -
  Triplet operator-(Triplet otherTriplet);
  Triplet operator-();
  // *
  Triplet operator*(Triplet otherTriplet);
  Triplet operator*(double t);
  friend Triplet operator*(double t, const Triplet &v);
  // /
  Triplet operator/(double t);
};

struct Vector3 : Triplet {
  Vector3(double x, double y, double z);
  Vector3(Triplet t);

  double Length();
  double LengthSquared();
  static Vector3 RandomInUnitSphere();
  static Vector3 RandomUnitVector();
  static Vector3 RandomOnHmisphere(Vector3 normal);
  static Vector3 Reflect(Vector3 v, Vector3 n);
  static double Dot(Vector3 vector1, Vector3 vector2);
  static Vector3 UnitVector(Vector3 vector);

  // Operator overloads
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