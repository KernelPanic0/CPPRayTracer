#include "GraphicsManager.hpp"
GraphicsManager::GraphicsManager() {}

GraphicsManager::~GraphicsManager() {}

void GraphicsManager::RenderObjects(Window &window, UI &userInterface) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_TEST);

  userInterface.Render((ImTextureID)(intptr_t)0);

  // render everything
  glfwSwapBuffers(window.window);
}