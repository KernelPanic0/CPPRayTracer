#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), UserInterface(std::make_unique<UI>(pWindow)) {
}

void Engine::RenderFrame() {
  pGraphicsManager->RenderObjects(std::pair(glm::mat4(0), glm::mat4(0)), glm::vec3(0, 0, 0), *pWindow.get(), *UserInterface.get()); // not good, but function needs to use window, not own it
}

void Engine::MainLoop() {
  while (!glfwWindowShouldClose(pWindow->window)) {
    Input::ProcessInput(pWindow->window, Settings::uiVisible);
    // really this shouldn't be in "Settings".
    Settings::updateDeltaTime();

    // render
    RenderFrame();
  }
}
