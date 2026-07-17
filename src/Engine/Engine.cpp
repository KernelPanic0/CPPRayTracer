#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(*pWindow)), pRtCamera(std::make_unique<Camera>()) {
  // light
  world.push_back({Vector3(0, 2.8, -2), 1.0, {MaterialType::DiffuseLight, Triplet(1, 1, 1), 0.0, 3.0}});

  // Floor
  world.push_back({Vector3(0, -50002, -5), 50000.0, {MaterialType::Lambertian, Triplet(1, 1, 1)}});

  // Little dude
  world.push_back({Vector3(0, -1.5, -2), 0.5, {MaterialType::Metal, Triplet(0.2705, 0.356, 1), 0.4}});
}

void Engine::RenderFrame() {
  pGraphicsManager->RenderObjects(*pWindow, *pUserInterface, pRtCamera, world); // not good, but function needs to use window, not own it
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
