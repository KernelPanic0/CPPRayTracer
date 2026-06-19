#include "UI.hpp"
#define IM_MAX(A, B) (((A) >= (B)) ? (A) : (B))

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

    ImGui::Begin("##fullscreen", nullptr, flags);

    unsigned char hi[1200 * 1200];

    for (int x = 0; x < 400; x++) {
      for (int y = 0; y < 1200; y++) {
        int pixelIndex = x * 3;

        hi[pixelIndex + (1200 * y)] = x * 255 / 400; // R
        hi[(pixelIndex + 1) + (1200 * y)] = 0;       // G
        hi[(pixelIndex + 2) + (1200 * y)] = 0;       // B
      }
    }

    GLuint tx;
    glGenTextures(1, &tx);
    glBindTexture(GL_TEXTURE_2D, tx);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 400, 400, 0, GL_RGB, GL_UNSIGNED_BYTE, hi);

    ImGui::BeginChild("Viewport", ImVec2(ImGui::GetContentRegionAvail().x - 230, 0), true);
    ImGui::Text("Viewport");
    int tex_w = 400;
    int tex_h = 400;
    ImageViewer::DrawOptions();
    ImVec2 canvas_size = ImGui::GetContentRegionAvail();
    ImVec2 canvas_min_size = ImGui::IsWindowAppearing() ? ImVec2(3.0f * tex_w, 4.0f * tex_h) : ImVec2(1.0f, 1.0f);
    canvas_size = ImVec2(IM_MAX(canvas_size.x, canvas_min_size.x), IM_MAX(canvas_size.y, canvas_min_size.y));
    ImageViewer::DrawCanvas(canvas_size, (ImTextureID)(intptr_t)tx, tex_w, tex_h);
    ImGui::EndChild();

    ImGui::SameLine();

    // Right: Controls
    ImGui::BeginChild("Controls", ImVec2(220, 0), true);

    ImGui::Text("Rendering...");
    ImGui::Separator();

    ImGui::Text("Progress");
    ImGui::ProgressBar(0.5); // float 0.0 - 1.0

    ImGui::Separator();
    ImGui::Text("Settings");
    // ImGui::SliderInt("Samples", nullptr, 1, 64);
    // ImGui::SliderInt("Max Depth", nullptr, 1, 50);

    ImGui::Separator();
    ImGui::Text("Stats");
    ImGui::Text("Resolution: %dx%d", 200, 200);
    ImGui::Text("Rays cast: %dk", 5 / 1000);

    ImGui::Separator();
    // if (ImGui::Button("Reset Accumulation", ImVec2(-1, 0))) {
    //   // ClearAccumulationBuffer();
    // }
    // if (ImGui::Button("Save to PPM", ImVec2(-1, 0))) {

    //   // SavePPM();
    // }
    // if (ImGui::Button("Stop Render", ImVec2(-1, 0))) {

    //   // StopRender();
    // }

    ImGui::EndChild();
    // ImGui::ShowDemoWindow(&Settings::uiVisible);
  }

  ImGui::End();

  // ImGui rendering
  ImGui::Render();
  ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}