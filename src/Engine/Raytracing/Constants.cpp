#include "Constants.hpp"

std::mt19937 Constants::gen{std::random_device{}()};
std::uniform_real_distribution<double> Constants::dist{0.0, 1.0};

const double Constants::DegreesToRadians(double degrees) {
  return degrees * pi / 180.0;
}

const double Constants::RandomDouble() {
  return (double)gen() / (double)std::mt19937::max();
}