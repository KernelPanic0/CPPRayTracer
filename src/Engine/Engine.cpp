#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(*pWindow)), pRtCamera(std::make_unique<Camera>()), pRaytracingScene(std::make_unique<HittableList>()) {
  // ray tracing
  DiffuseLight diffuseLight = DiffuseLight(Triplet(1, 1, 1), 3);
  Sphere lightSource(Vector3(0, 2.8, -2), 1, &diffuseLight);

  Lambertian mSurface(Triplet(1, 1, 1));
  Sphere floor(Vector3(0, -50002, -5), 50000, &mSurface);

  Metal mSphere(Triplet(0.2705, 0.356, 1), 0.4);
  Sphere middleSphere(Vector3(0, -1.5, -2), .5, &mSphere);

  pRaytracingScene->Add(lightSource);
  pRaytracingScene->Add(floor);
  pRaytracingScene->Add(middleSphere);

  pRtCamera->Render();
}

void Engine::RenderFrame() {
  pGraphicsManager->RenderObjects(*pWindow, *pUserInterface); // not good, but function needs to use window, not own it
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
