#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(pWindow)), pRenderer(std::make_unique<ActiveRenderer>(400, 225)), objParser(OBJParser()) {
    spheres.push_back({Vector3(0, 50003.5, -4), 50000.0, {MaterialType::Lambertian, Triplet(0.08, 0.08, 0.1)}});  // Ceiling
    spheres.push_back({Vector3(0, -50003.5, -4), 50000.0, {MaterialType::Lambertian, Triplet(0.08, 0.08, 0.1)}}); // Floor
    spheres.push_back({Vector3(0, 0, -50005.5), 50000.0, {MaterialType::Lambertian, Triplet(0.08, 0.08, 0.1)}});  // Back
    spheres.push_back({Vector3(0, 0, 50003.5), -50000.0, {MaterialType::Lambertian, Triplet(0.08, 0.08, 0.1)}});  // Front (Behind Camera)
    spheres.push_back({Vector3(-50005.5, 0, 0), 50000.0, {MaterialType::Lambertian, Triplet(1, 0.21, 0.31)}});    // Left
    spheres.push_back({Vector3(50005.5, 0, 0), 50000.0, {MaterialType::Lambertian, Triplet(0.15, 0.52, 0.09)}});  // Right

    spheres.push_back({Vector3(0, 4.5, -3), 2.0, {MaterialType::DiffuseLight, Triplet(1, 1, 1), 0.0, 10}}); // Soft overhead

    spheres.push_back({Vector3(-1, -1, -4), 0.5, {MaterialType::Metal, Triplet(0.1, 0.0, 0.1), 0.1}});
    spheres.push_back({Vector3(0, -1, -4), 0.5, {MaterialType::Lambertian, Triplet(0.1, 0.1, 0.8)}});
    spheres.push_back({Vector3(1, -1, -4), 0.5, {MaterialType::Sheen, Triplet(0.08, 0.98, 0.1)}});

    world.spheres = spheres.data();
    world.sphereCount = spheres.size();

    triangles = objParser.ReadFile("models/diamond.obj");
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
