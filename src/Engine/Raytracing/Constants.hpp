#pragma once
#include <limits>
#include <math.h>
#include <random>

class Constants {
private:
  static std::mt19937 gen;
  static std::uniform_real_distribution<double> dist;

public:
  static const double infinity = std::numeric_limits<double>::max();
  static const double pi = M_PI;

  static const double DegreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static const double RandomDouble() {
    return dist(gen);
  }
};