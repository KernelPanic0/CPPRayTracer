#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(pWindow)), pRenderer(std::make_unique<CudaRenderer>(400, 225)) {
    // Light source
    world.push_back({Vector3(0, 2.8, -2), 1.0, {MaterialType::DiffuseLight, Triplet(1, 1, 1), 0.0, 1.0}});

    // Cornell box walls
    world.push_back({Vector3(0, -50002, -5), 50000.0, {MaterialType::Lambertian, Triplet(1, 1, 1)}});         // floor
    world.push_back({Vector3(0, 50002, -5), 50000.0, {MaterialType::Lambertian, Triplet(1, 1, 1)}});          // ceiling
    world.push_back({Vector3(0, 0, -50003), 50000.0, {MaterialType::Lambertian, Triplet(1, 1, 1)}});          // back wall
    world.push_back({Vector3(0, 0, 50003), 50000.0, {MaterialType::Lambertian, Triplet(1, 1, 1)}});           // front wall
    world.push_back({Vector3(-50002, 0, -5), 50000.0, {MaterialType::Metal, Triplet(1, 0.188, 0.188), 0.0}}); // left wall  (red)
    world.push_back({Vector3(50002, 0, -5), 50000.0, {MaterialType::Lambertian, Triplet(0.023, 0.360, 0)}});  // right wall (green)

    // Scene objects
    world.push_back({Vector3(-1, -1.5, -2.5), 0.5, {MaterialType::Lambertian, Triplet(1, 0.549, 0)}});    // left   (orange)
    world.push_back({Vector3(0, -1.5, -2), 0.5, {MaterialType::Metal, Triplet(0.2705, 0.356, 1), 0.05}}); // middle (blue metal)
    world.push_back({Vector3(1, -1.5, -2.5), 0.5, {MaterialType::Metal, Triplet(0.8, 0.8, 0.8), 0.0}});   // right  (silver)
}

void Engine::RenderFrame() {
    pGraphicsManager->RenderObjects(pWindow, pUserInterface, pRenderer, world); // not good, but function needs to use window, not own it
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
