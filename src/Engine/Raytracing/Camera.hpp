#pragma once
#include "Hittable.hpp"
#include "Interval.hpp"
#include "Ray.hpp"
#include "Vector.hpp"
#include <fstream>
#include <iostream>
#include <string>

class Camera {
public:
  double aspectRatio = 16.0 / 9.0;
  int imageWidth = 400;
  double imageHeight;
  int samplesPerPixel = 50;
  int maxDepth = 40;
  std::vector<unsigned char> pixels;
  Triplet backgroundColor;

  Camera(Hittable &world);

  // Renders the scene and writes to a PPM file
  void Render(const std::string &outputFile = "output.ppm");

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