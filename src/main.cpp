#include "./Engine/Engine.hpp"
#include "./Engine/Raytracing/Hittable.hpp"
#include "./Engine/Raytracing/Camera.hpp"
#include "./Engine/Raytracing/Material.hpp"
#include "./Engine/Raytracing/Sphere.hpp"
#include "./Engine/Raytracing/Vector.hpp"

int main() {
  Engine engine;

  engine.MainLoop();
}