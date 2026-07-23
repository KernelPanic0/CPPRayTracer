#pragma once
#include "../../../includes/glad/glad.h"
#include "../../GLFW/Window.hpp"
#include "../../UI/UI.hpp"
#include "../../misc/stb_image.h"
#include "Buffers.hpp"
#include "memory"
#include <unordered_map>
#include <vector>
#include "../Raytracing/RawSphereData.hpp"
#include "../Raytracing/Renderer.cuh"

#ifndef __CUDACC__
#define __device__
#endif

class GraphicsManager {
  public:
    GraphicsManager();
    void InitTextures(int width, int height);
    ~GraphicsManager();
    void RenderObjects(std::shared_ptr<Window> &window, std::unique_ptr<UI> &userInterface, std::unique_ptr<CudaRenderer> &pRenderer, std::vector<RawSphereData> &pWorld);

  private:
    GLuint outputBufferTexture;
};
