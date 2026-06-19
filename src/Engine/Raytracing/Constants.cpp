#include "Constants.hpp"

std::mt19937 Constants::gen{std::random_device{}()};
std::uniform_real_distribution<double> Constants::dist{0.0, 1.0};