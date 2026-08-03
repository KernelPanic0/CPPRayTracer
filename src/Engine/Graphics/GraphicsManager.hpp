#pragma once
#include "../../../includes/glad/glad.h"
#include "../../GLFW/Window.hpp"
#include "../../UI/UI.hpp"
#include "../../misc/stb_image.h"
#include "../Raytracing/Renderer.hpp"
#include "Buffers.hpp"
#include "memory"
#include <unordered_map>
#include <vector>

#ifndef __CUDACC__
#define __device__
#endif

class GraphicsManager {
  public:
    GraphicsManager();
    void InitTextures(int width, int height);
    ~GraphicsManager();
    void RenderObjects(std::shared_ptr<Window> &window, std::unique_ptr<UI> &userInterface, std::unique_ptr<ActiveRenderer> &pRenderer, WorldData &pWorld);

  private:
    GLuint outputBufferTexture;
};
