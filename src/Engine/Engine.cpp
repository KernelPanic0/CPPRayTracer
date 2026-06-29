#include "Engine.hpp"
#include <thread>

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(*pWindow)), pRaytracingScene(std::make_unique<HittableList>()), pRtCamera(std::make_unique<Camera>(*pRaytracingScene)) {
  // ray tracing
  auto diffuseLight = std::make_shared<DiffuseLight>(Triplet(1, 1, 1), 3);
  auto lightSource = std::make_shared<Sphere>(Vector3(0, 2.8, -2), 1, diffuseLight);

  auto mSurface = std::make_shared<Lambertian>(Triplet(1, 1, 1));
  auto floor = std::make_shared<Sphere>(Vector3(0, -50002, -5), 50000, mSurface);

  auto mSphere = std::make_shared<Metal>(Triplet(0.2705, 0.356, 1), 0.4);
  auto middleSphere = std::make_shared<Sphere>(Vector3(0, -1.5, -2), .5, mSphere);

  pRaytracingScene->Add(lightSource);
  pRaytracingScene->Add(floor);
  pRaytracingScene->Add(middleSphere);

  std::jthread workerThread([this]() {
    pRtCamera->Render();
  });

  workerThread.detach();
}

void Engine::RenderFrame() {
  pGraphicsManager->RenderObjects(*pWindow, *pUserInterface, pRtCamera->pixels, pRtCamera->imageWidth, pRtCamera->imageHeight); // not good, but function needs to use window, not own it
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
