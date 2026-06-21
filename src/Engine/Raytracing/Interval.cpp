#include "Interval.hpp"

Interval::Interval(double min, double max) {
  this->min = min;
  this->max = max;
}

bool Interval::Contains(double x) { return x >= min && x <= max; }

bool Interval::Surrounds(double x) { return x > min && x < max; }

double Interval::Clamp(double x) {
  if (x < min)
    return min;
  if (x > max)
    return max;
  return x;
}