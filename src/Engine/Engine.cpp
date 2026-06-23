#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), UserInterface(std::make_unique<UI>(*pWindow)) {
}

void Engine::RenderFrame() {
  pGraphicsManager->RenderObjects(*pWindow, *UserInterface); // not good, but function needs to use window, not own it
}

void Engine::MainLoop() {
  while (!glfwWindowShouldClose(pWindow->window)) {
    Input::ProcessInput(pWindow->window, Settings::uiVisible);
    Settings::updateDeltaTime();

    // render
    RenderFrame();
  }
}
