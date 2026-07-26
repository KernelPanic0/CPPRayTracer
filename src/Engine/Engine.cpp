#include "Engine.hpp"

Engine::Engine() : pWindow(std::make_shared<Window>()), pGraphicsManager(std::make_unique<GraphicsManager>()), pUserInterface(std::make_unique<UI>(pWindow)), pRenderer(std::make_unique<CudaRenderer>(400, 225)) {
    // 1. Mirrored dark stage & soft ambient light
    world.push_back({Vector3(0, -50002.5, -4), 50000.0, {MaterialType::Lambertian, Triplet(0.08, 0.08, 0.1)}}); // Floor
    world.push_back({Vector3(0, 10, -4), 3.0, {MaterialType::DiffuseLight, Triplet(1, 1, 1), 0.0, 0.8}});       // Soft overhead

    // 2. Lorenz System Parameters
    double x = 0.1, y = 0.0, z = 0.0;
    double sigma = 10.0;
    double rho = 28.0;
    double beta = 8.0 / 3.0;
    double dt = 0.007;
    double scale = 0.065;

    int numSteps = 700;

    for (int i = 0; i < numSteps; i++) {
        // Lorenz differential equations:
        // dx/dt = sigma * (y - x)
        // dy/dt = x * (rho - z) - y
        // dz/dt = x * y - beta * z
        double dx = sigma * (y - x);
        double dy = x * (rho - z) - y;
        double dz = x * y - beta * z;

        x += dx * dt;
        y += dy * dt;
        z += dz * dt;

        // Transform raw coordinates to camera space
        // Center Z at 25.0 and re-orient axes for best view
        Vector3 pos(x * scale, (z - 25.0) * scale, -4.5 + (y * scale));

        // Dynamic color gradient across the trajectory (Cyan -> Magenta -> Gold)
        double progress = (double)i / numSteps;
        Triplet glowColor(
            0.5 + 0.5 * std::sin(progress * 6.28),
            0.3 + 0.3 * std::cos(progress * 6.28),
            0.8 + 0.2 * std::sin(progress * 3.14));

        // Every 3rd step is an emissive light bead; others are polished chrome
        if (i % 3 == 0) {
            world.push_back({pos, 0.07, {MaterialType::DiffuseLight, glowColor, 0.0, 3.0}});
        } else {
            world.push_back({pos, 0.05, {MaterialType::Metal, Triplet(0.9, 0.95, 1.0), 0.0}});
        }
    }
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
