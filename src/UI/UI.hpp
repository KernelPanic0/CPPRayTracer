#pragma once
#include "../../includes/imgui/imgui.h"
#include "../../includes/imgui/imgui_impl_glfw.h"
#include "../../includes/imgui/imgui_impl_opengl3.h"
#include "../GLFW/Window.hpp"
#include "../misc/stb_image.h"
#include "ImageViewer.hpp"
#include <iostream>
#include "../Engine/Raytracing/Renderer.cuh"
#include <memory>
#include "../includes/stb_image_write.h"
#include <thread>

struct RawSphereData;

class UI {
  private:
    bool visible = true;
    std::shared_ptr<Window> pWindow;
    std::jthread workerThread;

  public:
    UI(std::shared_ptr<Window> &pWindow);
    void Render(ImTextureID texture, std::unique_ptr<CudaRenderer> &pRenderer, std::vector<RawSphereData> &pWorld);
};
