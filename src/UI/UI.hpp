#pragma once
#include "../../includes/imgui/imgui.h"
#include "../../includes/imgui/imgui_impl_glfw.h"
#include "../../includes/imgui/imgui_impl_opengl3.h"
#include "../Engine/Raytracing/Renderer.hpp"
#include "../GLFW/Window.hpp"
#include "../includes/stb_image_write.h"
#include "../misc/stb_image.h"
#include "ImageViewer.hpp"
#include <iostream>
#include <memory>
#include <thread>
#include <vector>

struct RawSphereData;

class UI {
  private:
    bool visible = true;
    std::shared_ptr<Window> pWindow;
    std::jthread workerThread;

  public:
    UI(std::shared_ptr<Window> &pWindow);
    void Render(ImTextureID texture, std::unique_ptr<ActiveRenderer> &pRenderer, std::vector<RawSphereData> &pWorld);
};
