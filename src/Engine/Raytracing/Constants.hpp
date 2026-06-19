#pragma once
#include <limits>
#include <math.h>
#include <random>

class Constants {
public:
  static const double infinity = std::numeric_limits<double>::max();
  static const double pi = M_PI;

  static const double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
};