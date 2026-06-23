#include "./Engine/Engine.hpp"
#include "./Engine/Raytracing/Hittable.hpp"
#include "./Engine/Raytracing/Camera.hpp"
#include "./Engine/Raytracing/Material.hpp"
#include "./Engine/Raytracing/Sphere.hpp"
#include "./Engine/Raytracing/Vector.hpp"

int main() {
  Engine engine;

  // rtx
  DiffuseLight diffuseLight = DiffuseLight(Triplet(1, 1, 1), 3);
  Sphere lightSource(Vector3(0, 2.8, -2), 1, &diffuseLight);

  Lambertian mSurface(Triplet(1, 1, 1));
  Sphere floor(Vector3(0, -50002, -5), 50000, &mSurface);

  Metal mSphere(Triplet(0.2705, 0.356, 1), 0.4);
  Sphere middleSphere(Vector3(0, -1.5, -2), .5, &mSphere);

  HittableList world;
  world.Add(lightSource);
  world.Add(floor);
  world.Add(middleSphere);

  Camera camera(world);
  camera.Render();

  engine.MainLoop();
}