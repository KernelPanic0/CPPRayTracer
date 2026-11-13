#pragma once
#include "Vector.hip"
#include "Material.hip"
#include "MaterialType.hpp"

struct RawMaterialData {
    MaterialType type;
    Triplet albedo;
    float fuzz = 0.0;      // Metal only
    float intensity = 1.0; // DiffuseLight only
};

struct RawTriangleData {
    Vector3 vertices[3];
    RawMaterialData material;
};

struct RawSphereData {
    Vector3 center;
    float radius;
    RawMaterialData material;
};

struct RawModelData {
    RawTriangleData *triangles = nullptr;
    int triangleCount = 0;
};

struct WorldData {
    RawSphereData *spheres = nullptr;
    int sphereCount = 0;
    RawTriangleData *triangles = nullptr;
    int triangleCount = 0;
};