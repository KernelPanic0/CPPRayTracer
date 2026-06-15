#include "GraphicsManager.hpp"
GraphicsManager::GraphicsManager() {
  shader = std::make_unique<Shader>("./src/Engine/Graphics/Shaders/shader.vert", "./src/Engine/Graphics/Shaders/shader.frag");

  //   shader->use();
  // shader->setVec3("objectColor", 1.0f, 1.0f, 0.0f);
  shader->setVec3("lightColor", 1.0, 0.733, 0.529);
  shader->setVec3("lightPos", 10, 20, 10);
}

GraphicsManager::~GraphicsManager() {
  shader.reset();
}

void GraphicsManager::RenderObjects(const std::pair<glm::mat4, glm::mat4> viewProjection, glm::vec3 cameraPos, Window &window, UI userInterface) // TEMPORARY TEST
{
  glClearColor(0.09f, 0.09f, 0.43f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_TEST);

  //   shader->use();

  userInterface.Render((ImTextureID)(intptr_t)0);

  // render everything
  glfwSwapBuffers(window.window);
}

unsigned int GraphicsManager::GenerateTexture(std::string path) {
  int width, height, nrChannels;
  stbi_set_flip_vertically_on_load(true);
  unsigned char *textureData = stbi_load(path.c_str(), &width, &height, &nrChannels, 0);

  unsigned int textureToGen;
  glGenTextures(1, &textureToGen);

  glBindTexture(GL_TEXTURE_2D, textureToGen);
  // set wrapping / filtering options
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  // This might need to be optimised later as not all textures need to be
  // RGBA.
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
  // temporary disabled because of edge-bleeding bug
  glGenerateMipmap(GL_TEXTURE_2D);

  stbi_image_free(textureData);

  return textureToGen;
}