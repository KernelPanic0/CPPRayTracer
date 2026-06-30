#pragma once
#include "Hittable.hpp"
#include "Interval.hpp"
#include "Ray.hpp"
#include "Vector.hpp"
#include <fstream>
#include <iostream>
#include <string>
#include <atomic>
#include <thread>

class Camera {
public:
  double aspectRatio = 16.0 / 9.0;
  int imageWidth = 400;
  double imageHeight;
  int samplesPerPixel = 400;
  int maxDepth = 40;
  std::atomic<double> progress = 0;
  std::vector<uint8_t> pixels;
  Triplet backgroundColor;

  Camera(Hittable &world);

  // Renders the scene and writes to a PPM file
  void Render(std::stop_token st);

private:
  Vector3 centre;
  Vector3 pixel00Loc;
  Vector3 pixelDeltaHorizontal;
  Vector3 pixelDeltaVertical;
  Hittable &world;

  void InitialiseProperties();
  Ray GetRay(int i, int j);
  Vector3 PixelSampleSquare();
  double ComputeColor(double color, int samplesPerPixel);
  double LinearToGamma(double color);
  Triplet RayColor(const Ray &ray, int depth);
};