#include "UI.hpp"
#define IM_MAX(A, B) (((A) >= (B)) ? (A) : (B))

UI::UI(Window &window) : pWindow(window) {
  // Camera *camera = static_cast<Camera *>(glfwGetWindowUserPointer(window->window));
  // this->camera = camera;

  IMGUI_CHECKVERSION();
  ImGui::CreateContext();

  ImGuiIO &io = ImGui::GetIO();
  (void)io;
  io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
  io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;     // Enable Keyboard Controls

  ImGui_ImplGlfw_InitForOpenGL(window.window, true);
  ImGui_ImplOpenGL3_Init("#version 330");
  ImGui::StyleColorsDark();
}

void UI::Render(ImTextureID texture, std::unique_ptr<Camera> &pCamera) {
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

    ImGui::BeginChild("Viewport", ImVec2(ImGui::GetContentRegionAvail().x - 230, 0), true);
    ImGui::Text("Viewport");
    int tex_w = 400;
    int tex_h = 400;
    ImageViewer::DrawOptions();
    ImVec2 canvas_size = ImGui::GetContentRegionAvail();
    ImVec2 canvas_min_size = ImGui::IsWindowAppearing() ? ImVec2(3.0f * tex_w, 4.0f * tex_h) : ImVec2(1.0f, 1.0f);
    canvas_size = ImVec2(IM_MAX(canvas_size.x, canvas_min_size.x), IM_MAX(canvas_size.y, canvas_min_size.y));

    int imageHeight = pCamera->imageWidth / (pCamera->aspectRatio.first / pCamera->aspectRatio.second);
    ImageViewer::DrawCanvas(canvas_size, texture, pCamera->imageWidth, imageHeight);
    ImGui::EndChild();

    ImGui::SameLine();

    // Right: Controls
    ImGui::BeginChild("Controls", ImVec2(220, 0), true);

    ImGui::Text("Rendering...");
    ImGui::Separator();

    ImGui::Text("Progress");
    ImGui::ProgressBar(pCamera->progress); // float 0.0 - 1.0

    ImGui::Separator();
    ImGui::Text("Settings");
    ImGui::DragInt("Image Width", &pCamera->imageWidth, 1);
    ImGui::SliderInt("Samples", &pCamera->samplesPerPixel, 1, 1000);
    ImGui::SliderInt("Max Depth", &pCamera->maxDepth, 1, 200);

    ImGui::Separator();
    ImGui::Text("Stats");
    ImGui::Text("Resolution: %dx%d", pCamera->imageWidth, (int)(pCamera->imageWidth / (pCamera->aspectRatio.first / pCamera->aspectRatio.second)));
    ImGui::Text("Rays cast: %d", pCamera->raysCast.load());
    ImGui::Text("Aspect Ratio: %d:%d", (int)pCamera->aspectRatio.first, (int)pCamera->aspectRatio.second);

    ImGui::Separator();

    if (ImGui::Button("Start Render", ImVec2(-1, 0))) {
      if (workerThread.joinable()) {
        workerThread.request_stop();
        workerThread.detach();
      }

      workerThread = std::jthread([&pCamera](std::stop_token st) {
        pCamera->pixels.clear();
        pCamera->progress = 0;
        pCamera->Render(st);
      });
    }
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