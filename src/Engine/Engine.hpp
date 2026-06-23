// #include "../Camera/Camera.hpp"
#include "../GLFW/Input.hpp"
#include "./Graphics/GraphicsManager.hpp"

class Engine {
private:
  std::shared_ptr<Window> pWindow;
  std::shared_ptr<GraphicsManager> pGraphicsManager;
  std::unique_ptr<UI> UserInterface;

public:
  Engine();
  void RenderFrame();
  void MainLoop();
};
