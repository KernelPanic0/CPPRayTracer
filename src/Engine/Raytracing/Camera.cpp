#include "Camera.hpp"

Camera::Camera(Hittable &world) : world(world) {}

void Camera::Render(const std::string &outputFile) {
  InitialiseProperties();

#pragma omp parallel for schedule(dynamic)
  for (int y = 0; y < (int)imageHeight; y++) {
    std::cout << "\rRows remaining: " << ((int)imageHeight - y) << " " << std::flush;

    for (int x = 0; x < imageWidth; x++) {
      Triplet pixelColor(0, 0, 0);
      for (int sample = 0; sample < samplesPerPixel; sample++) {
        Ray ray = GetRay(x, y);
        pixelColor += RayColor(ray, maxDepth);
      }
      double r = ComputeColor(pixelColor.x, samplesPerPixel);
      double g = ComputeColor(pixelColor.y, samplesPerPixel);
      double b = ComputeColor(pixelColor.z, samplesPerPixel);

      int index = (y * imageWidth + x) * 3;
      pixels[index + 0] = r;
      pixels[index + 1] = g;
      pixels[index + 2] = b;
    }
  }
  std::cout << "\nDone!" << "\n";
}

void Camera::InitialiseProperties() {
  pixels.resize(imageWidth * (int)imageHeight * 3);

  imageHeight = imageWidth / aspectRatio;
  imageHeight = (imageHeight < 1) ? 1 : imageHeight;
  centre = Vector3(0, 0, 0);

  double focalLength = 1.0;
  double viewportHeight = 2.0;
  double viewportWidth = viewportHeight * ((double)imageWidth / imageHeight);

  Vector3 cameraCenter(0, 0, 0);
  Vector3 viewportHorizontal(viewportWidth, 0, 0);
  Vector3 viewportVertical(0, -viewportHeight, 0); // Y inverted to match image coordinates

  pixelDeltaHorizontal = viewportHorizontal / imageWidth;
  pixelDeltaVertical = viewportVertical / imageHeight;

  Vector3 viewportTopLeft = (Vector3)cameraCenter - Vector3(0, 0, focalLength) - viewportHorizontal / 2 - viewportVertical / 2;

  pixel00Loc = viewportTopLeft + 0.5 * (pixelDeltaHorizontal + pixelDeltaVertical);
}

Ray Camera::GetRay(int i, int j) {
  Vector3 pixelCentre = (Vector3)pixel00Loc + (i * pixelDeltaHorizontal) + (j * pixelDeltaVertical);
  Vector3 pixelSample = pixelCentre + PixelSampleSquare();
  Vector3 rayOrigin = centre;
  Vector3 rayDirection = pixelSample - (Vector3)rayOrigin;
  return Ray(rayOrigin, rayDirection);
}

Vector3 Camera::PixelSampleSquare() {
  double pX = -0.5 + Constants::RandomDouble();
  double pY = -0.5 + Constants::RandomDouble();
  return (pX * pixelDeltaHorizontal) + (pY * pixelDeltaVertical);
}

double Camera::ComputeColor(double color, int samplesPerPixel) {
  double scale = 1.0 / samplesPerPixel;
  color *= scale;
  color = LinearToGamma(color);
  Interval intensity(0.000, 0.999);
  return 255.999 * intensity.Clamp(color);
}

double Camera::LinearToGamma(double color) {
  return std::sqrt(color);
}

Triplet Camera::RayColor(const Ray &ray, int depth) {
  if (depth <= 0)
    return Triplet(0, 0, 0);

  HitRecord hitRecord;
  Interval rayTInterval(0.001, Constants::infinity);

  if (!world.Hit(ray, rayTInterval, hitRecord))
    return backgroundColor;

  Ray scattered(Vector3(0, 0, 0), Vector3(0, 0, 0));
  Triplet attenuation(0, 0, 0);
  Triplet colorFromEmission = hitRecord.material->Emitted(0, 0, hitRecord.point);

  if (!hitRecord.material->Scatter(ray, hitRecord, attenuation, scattered))
    return colorFromEmission;

  Triplet colorFromScatter = attenuation * RayColor(scattered, depth - 1);
  return colorFromEmission + colorFromScatter;
}