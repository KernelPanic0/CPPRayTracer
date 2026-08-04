// #include "../Camera/Camera.hpp"
#include "../GLFW/Input.hpp"
#include "./Graphics/GraphicsManager.hpp"
#include "Raytracing/Renderer.hpp"
#include <omp.h>

class Engine {
  private:
    std::shared_ptr<Window> pWindow;
    std::unique_ptr<GraphicsManager> pGraphicsManager;
    std::unique_ptr<UI> pUserInterface;
    std::unique_ptr<ActiveRenderer> pRenderer;
    std::vector<RawSphereData> spheres;
    std::vector<RawTriangleData> triangles;
    std::vector<RawModelData> models;
    WorldData world;

  public:
    Engine();
    void RenderFrame();
    void MainLoop();
};
