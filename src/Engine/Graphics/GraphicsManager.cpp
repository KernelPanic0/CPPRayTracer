#include "GraphicsManager.hpp"
GraphicsManager::GraphicsManager() {}

GraphicsManager::~GraphicsManager() {}

void GraphicsManager::RenderObjects(Window &window, UI &userInterface, std::unique_ptr<Camera> &pCamera) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_TEST);

  // create ray tracing output texture
  GLuint tx;
  glGenTextures(1, &tx);
  glBindTexture(GL_TEXTURE_2D, tx);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, pCamera->imageWidth, pCamera->imageHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, pCamera->pixels.data());

  userInterface.Render((ImTextureID)(intptr_t)tx, pCamera);

  // render everything
  glfwSwapBuffers(window.window);
}