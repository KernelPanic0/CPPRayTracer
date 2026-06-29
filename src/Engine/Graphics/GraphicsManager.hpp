#pragma once
#include "../../../includes/glad/glad.h"
#include "../../GLFW/Window.hpp"
#include "../../UI/UI.hpp"
#include "../../misc/stb_image.h"
#include "Buffers.hpp"
#include "memory"
#include <unordered_map>
#include <vector>

class GraphicsManager {
public:
  GraphicsManager();
  ~GraphicsManager();
  void RenderObjects(Window &window, UI &userInterface, std::vector<unsigned char> pixels, int width, int height);
};
