// #include "../Camera/Camera.hpp"
#include "../GLFW/Input.hpp"
#include "./Graphics/GraphicsManager.hpp"
#include "Raytracing/Renderer.hip.h"
#include "OBJParser.hpp"

class Engine {
  private:
    std::shared_ptr<Window> pWindow;
    std::unique_ptr<GraphicsManager> pGraphicsManager;
    std::unique_ptr<UI> pUserInterface;
    std::unique_ptr<Renderer> pRenderer;
    std::vector<RawSphereData> spheres;
    std::vector<RawTriangleData> triangles;
    WorldData world;
    OBJParser objParser;

  public:
    Engine();
    void RenderFrame();
    void MainLoop();
};
