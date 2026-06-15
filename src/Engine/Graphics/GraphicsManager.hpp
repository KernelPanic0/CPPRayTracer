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
private:
  std::unique_ptr<Shader> shader;
  std::unordered_map<std::string, int> textureCache; // prevents reloading already loaded textures

  unsigned int GenerateTexture(std::string path);

public:
  GraphicsManager();
  ~GraphicsManager();
  void RenderObjects(const std::pair<glm::mat4, glm::mat4> viewProjection, glm::vec3 cameraPosition, Window &window, UI userInterface);
};
