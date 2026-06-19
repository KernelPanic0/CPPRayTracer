#include "ImageViewer.hpp"
#define IM_CLAMP(V, MN, MX) ((V) < (MN) ? (MN) : (V) > (MX) ? (MX) \
                                                            : (V))
ImageViewer::ImageViewerData ImageViewer::data = {};

void ImageViewer::DrawCanvas(ImVec2 canvas_size, ImTextureRef image_tex_ref, int image_w, int image_h) {
  ImGuiIO &io = ImGui::GetIO();
  ImGuiPlatformIO &platform_io = ImGui::GetPlatformIO();
  ImDrawList *draw_list = ImGui::GetWindowDrawList();
  IM_ASSERT(canvas_size.x >= 0.0f && canvas_size.y >= 0.0f);

  // Layout canvas
  ImGui::InvisibleButton("##Canvas", canvas_size);
  ImVec2 canvas_min = ImGui::GetItemRectMin();
  ImVec2 canvas_max = ImGui::GetItemRectMax();

  if (data.ViewReset)
    data.ViewOffset = ImVec2((canvas_size.x * 0.5f / data.Zoom) - 0.5f, (canvas_size.y * 0.5f / data.Zoom) - 0.5f); // Add half a pixel padding
  data.ViewReset = false;

  // Handle inputs
  if (ImGui::SetItemKeyOwner(ImGuiKey_MouseWheelY))
    if (io.MouseWheel != 0.0f)
      data.Zoom = IM_CLAMP(data.Zoom * (1.0f + io.MouseWheel * 0.10f), data.ZoomMin, data.ZoomMax);
  float zoom = data.Zoom; // (float)(int)ViewZoom;
  if (ImGui::IsItemActive() && ImGui::IsMouseDragging(0)) {
    data.ViewOffset.x -= io.MouseDelta.x / zoom;
    data.ViewOffset.y -= io.MouseDelta.y / zoom;
  }

  // Display image
  ImVec2 image_min, image_max;
  image_min.x = (float)(int)((canvas_min.x - (data.ViewOffset.x * zoom)) + (canvas_size.x * 0.5f));
  image_min.y = (float)(int)((canvas_min.y - (data.ViewOffset.y * zoom)) + (canvas_size.y * 0.5f));
  image_max.x = (float)(int)(image_min.x + image_w * zoom);
  image_max.y = (float)(int)(image_min.y + image_h * zoom);
  draw_list->AddRect(ImVec2(canvas_min.x - 1.0f, canvas_min.y - 1.0f), ImVec2(canvas_max.x + 1.0f, canvas_max.y + 1.0f), IM_COL32(255, 255, 255, 255));
  draw_list->PushClipRect(canvas_min, canvas_max, true);
  draw_list->AddRectFilled(image_min, image_max, data.ImageBgColor);
  if (platform_io.DrawCallback_SetSamplerNearest != NULL)
    draw_list->AddCallback(platform_io.DrawCallback_SetSamplerNearest);
  draw_list->AddImage(image_tex_ref, image_min, image_max);
  if (platform_io.DrawCallback_SetSamplerLinear != NULL)
    draw_list->AddCallback(ImGui::GetPlatformIO().DrawCallback_SetSamplerLinear);

  // Display grid lines for visible pixels
  if (data.GridEnabled && zoom > 6.0f) {
    const float step = (float)zoom;
    for (int px = (int)((canvas_min.x - image_min.x) / step); px <= (int)((canvas_max.x - image_min.x) / step); px++)
      draw_list->AddLineV(image_min.x + px * step, canvas_min.y, canvas_max.y, data.GridColor, 1.0f);
    for (int py = (int)((canvas_min.y - image_min.y) / step); py <= (int)((canvas_max.y - image_min.y) / step); py++)
      draw_list->AddLineH(canvas_min.x, canvas_max.x, image_min.y + py * step, data.GridColor, 1.0f);
  }
  draw_list->PopClipRect();
}

void ImageViewer::DrawOptions() {
  ImGui::SetNextItemShortcut(ImGuiKey_G, ImGuiInputFlags_Tooltip); // | ImGuiInputFlags_RouteGlobal
  ImGui::Checkbox("Grid", &data.GridEnabled);
  ImGui::SameLine();
  ImGui::SetNextItemWidth(ImGui::GetFontSize() * 10.0f);
  float zoom_100 = data.Zoom * 100.0f;
  if (ImGui::DragFloat("##Zoom", &zoom_100, 5.0f, data.ZoomMin * 100.0f, data.ZoomMax * 100.0f, "%.0f%%", ImGuiSliderFlags_AlwaysClamp))
    data.Zoom = zoom_100 / 100.0f;
}