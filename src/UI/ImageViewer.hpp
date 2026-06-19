#pragma once
#include "../../includes/imgui/imgui.h"

class ImageViewer {
private:
public:
  struct ImageViewerData {
    ImU32 ImageBgColor = IM_COL32(100, 100, 100, 255);
    ImU32 GridColor = IM_COL32(255, 255, 255, 100);
    bool GridEnabled = false;
    bool ViewReset = true;
    ImVec2 ViewOffset; // in image space
    float Zoom = 10.0f;
    float ZoomMin = 1.0f;
    float ZoomMax = 10000.0f;
  };

  static ImageViewerData data;

  static void DrawCanvas(ImVec2 canvas_size, ImTextureRef image_tex_ref, int image_w, int image_h);
  static void DrawOptions();
};