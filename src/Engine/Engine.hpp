// #include "../Camera/Camera.hpp"
#include <omp.h>
#include "../GLFW/Input.hpp"
#include "./Graphics/GraphicsManager.hpp"

#include "./Raytracing/Hittable.hpp"
#include "./Raytracing/Camera.hpp"
#include "./Raytracing/Material.hpp"
#include "./Raytracing/Sphere.hpp"
#include "./Raytracing/Vector.hpp"

class Engine {
private:
  std::shared_ptr<Window> pWindow;
  std::unique_ptr<GraphicsManager> pGraphicsManager;
  std::unique_ptr<UI> pUserInterface;
  std::unique_ptr<Camera> pRtCamera;
  std::unique_ptr<HittableList> pRaytracingScene;

public:
  Engine();
  void RenderFrame();
  void MainLoop();
};
