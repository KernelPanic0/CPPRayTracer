#pragma once
#include "../../includes/glad/glad.h"
#include "../../includes/glm/glm.hpp"
#include "../../includes/glm/gtc/matrix_transform.hpp"
#include "../../includes/glm/gtc/type_ptr.hpp"
#include "../Camera/Camera.hpp"
#include "../misc/Settings.hpp"
#include <GLFW/glfw3.h> // System-installed GLFW

void framebuffer_size_callback(GLFWwindow *window, int width, int height);
class Window {
public:
  // Sets up callbacks and returns window pointer
  Window();
  GLFWwindow *window;

private:
};
