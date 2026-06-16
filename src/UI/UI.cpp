#include "UI.hpp"
#include "../misc/stb_image.h"
#include <iostream>

UI::UI(const std::shared_ptr<Window> &window) {
  this->pWindow = window;
  // Camera *camera = static_cast<Camera *>(glfwGetWindowUserPointer(window->window));
  // this->camera = camera;

  IMGUI_CHECKVERSION();
  ImGui::CreateContext();

  ImGuiIO &io = ImGui::GetIO();
  (void)io;
  io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
  io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;     // Enable Keyboard Controls

  ImGui_ImplGlfw_InitForOpenGL(window->window, true);
  ImGui_ImplOpenGL3_Init("#version 330");
  ImGui::StyleColorsDark();
}

void UI::Render(ImTextureID texture) {
  ImGui_ImplOpenGL3_NewFrame();
  ImGui_ImplGlfw_NewFrame();
  // ImGui::SetNextWindowViewport(viewport->ID);

  ImGui::NewFrame();
  if (Settings::uiVisible) {
    const ImGuiViewport *viewport = ImGui::GetMainViewport();
    ImGui::SetNextWindowPos(viewport->WorkPos);
    ImGui::SetNextWindowSize(viewport->WorkSize);

    // Set window flags for fullscreen UI
    ImGuiWindowFlags flags = ImGuiWindowFlags_NoDecoration |
                             ImGuiWindowFlags_NoMove |
                             ImGuiWindowFlags_NoSavedSettings |
                             ImGuiWindowFlags_NoBringToFrontOnFocus;
    ImGui::SetNextWindowBgAlpha(1.0f);
    ImGui::Begin("##fullscreen", nullptr, flags);

    ImGui::BeginTabBar("Viewport");
    if (ImGui::BeginTabItem("Viewport")) {

      unsigned char hi[1200 * 1200];

      for (int x = 0; x < 400; x++) {
        for (int y = 0; y < 1200; y++) {
          int pixelIndex = x * 3;

          hi[pixelIndex + (1200 * y)] = x * 255 / 400; // R
          hi[(pixelIndex + 1) + (1200 * y)] = 0;       // G
          hi[(pixelIndex + 2) + (1200 * y)] = 255;     // B
        }
      }

      printf("%d", hi[1]);
      std::cout << hi[2] << std::endl;

      GLuint tx;
      glGenTextures(1, &tx);
      glBindTexture(GL_TEXTURE_2D, tx);
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 400, 400, 0, GL_RGB, GL_UNSIGNED_BYTE, hi);

      ImGui::Image((ImTextureID)tx, ImVec2(400, 400));
      ImGui::EndTabItem();
    }
    if (ImGui::BeginTabItem("Info")) {
      ImGui::Text("Hi");
      ImGui::Text("Hello this is a test %d", 123);
      ImGui::Text("Camera position: ");
      ImGui::Text("FPS: %d", (int)(1 / Settings::deltaTime));

      ImGui::Image(texture, ImVec2(320, 240), ImVec2(0, 1), ImVec2(1, 0));

      ImGui::EndTabItem();
    }
    ImGui::EndTabBar();

    // // std::cout << camera->cameraPos.x << "\n";
    // ImGui::Text("x: %f", camera->cameraPos.x);
    // ImGui::Text("y: %f", camera->cameraPos.y);
    // ImGui::Text("z: %f", camera->cameraPos.z);
    // ImGui::ShowDemoWindow(&Settings::uiVisible);

    ImGui::End();
  }

  // ImGui rendering
  ImGui::Render();
  int display_w, display_h;
  glfwGetFramebufferSize(pWindow->window, &display_w, &display_h);
  glViewport(0, 0, display_w, display_h);
  // ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
  // glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
  // glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}