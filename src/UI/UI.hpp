#pragma once
#include "../../includes/imgui/imgui.h"
#include "../../includes/imgui/imgui_impl_glfw.h"
#include "../../includes/imgui/imgui_impl_opengl3.h"
#include "../GLFW/Window.hpp"
#include "../misc/stb_image.h"
#include "ImageViewer.hpp"
#include <iostream>
#include "../Engine/Raytracing/Camera.hpp"
#include <memory>
#include <thread>

class UI {
private:
  bool visible = true;
  Window &pWindow;
  std::jthread workerThread;

public:
  UI(Window &window);
  void Render(ImTextureID texture, std::unique_ptr<Camera> &pCamera);
};
