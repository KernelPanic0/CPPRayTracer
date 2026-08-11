#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(pWindow)), pRenderer(std::make_unique<ActiveRenderer>(400, 225)), objParser(OBJParser()) {
    spheres.push_back({Vector3(0, -50002.5, -4), 50000.0, {MaterialType::Lambertian, Triplet(0.08, 0.08, 0.1)}}); // Floor
    spheres.push_back({Vector3(0, 6.5, -4), 3.0, {MaterialType::DiffuseLight, Triplet(1, 1, 1), 0.0, 2.8}});      // Soft overhead
    spheres.push_back({Vector3(-4, -1, -6), 1.0, {MaterialType::Metal, Triplet(0.08, 0.08, 0.1), 0.01}});
    spheres.push_back({Vector3(4, -1, -6), 1.0, {MaterialType::DiffuseLight, Triplet(0.08, 0.98, 0.1), 0.01}});

    world.spheres = spheres.data();
    world.sphereCount = spheres.size();

    triangles = objParser.ReadFile("models/utah_teapot2.obj");
    world.triangles = triangles.data();
    world.triangleCount = triangles.size();
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
