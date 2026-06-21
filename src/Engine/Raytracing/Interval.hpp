#pragma once

struct Interval {
public:
  double min, max;

  Interval(double min, double max);
  bool Contains(double x);
  bool Surrounds(double x);
  double Clamp(double x);
};