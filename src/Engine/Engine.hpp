// #include "../Camera/Camera.hpp"
#include <omp.h>
#include "../GLFW/Input.hpp"
#include "./Graphics/GraphicsManager.hpp"

#include "./Raytracing/Hittable.cuh"
#include "./Raytracing/Camera.hpp"
#include "./Raytracing/Material.cuh"
#include "./Raytracing/Sphere.cuh"
#include "./Raytracing/Vector.cuh"

class Engine {
private:
  std::shared_ptr<Window> pWindow;
  std::unique_ptr<GraphicsManager> pGraphicsManager;
  std::unique_ptr<UI> pUserInterface;
  std::unique_ptr<Camera> pRtCamera;
  std::vector<RawSphereData> world;

public:
  Engine();
  void RenderFrame();
  void MainLoop();
};
