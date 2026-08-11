#pragma once
#include <fstream>
#include <vector>
#include <string_view>
#include <ranges>
#include <sstream>
#include "Raytracing/Renderer.hpp"
#include <boost/algorithm/string.hpp>
#include <iostream>
#include <string>

class OBJParser {
  public:
    OBJParser();
    std::vector<RawTriangleData> ReadFile(const char *path);
};