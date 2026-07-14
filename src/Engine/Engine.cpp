#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(*pWindow)), pRtCamera(std::make_unique<Camera>()) {
}

void Engine::RenderFrame() {
  pGraphicsManager->RenderObjects(*pWindow, *pUserInterface, pRtCamera); // not good, but function needs to use window, not own it
}

void Engine::MainLoop() {
  while (!glfwWindowShouldClose(pWindow->window)) {
    Input::ProcessInput(pWindow->window, Settings::uiVisible);
    Settings::updateDeltaTime();

    // compute ray tracing logic

    // render
    RenderFrame();
  }
}
