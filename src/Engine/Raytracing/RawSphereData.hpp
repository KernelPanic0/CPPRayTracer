#pragma once
#include "Vector.cuh"
#include "Material.cuh"

enum class MaterialType { Lambertian,
                          Metal,
                          DiffuseLight };

struct RawMaterialData {
    MaterialType type;
    Triplet albedo;
    double fuzz = 0.0;      // Metal only
    double intensity = 1.0; // DiffuseLight only

    __device__ Material *Build() {
        switch (type) {
        case MaterialType::Lambertian:
            return new Lambertian(albedo);
        case MaterialType::Metal:
            return new Metal(albedo, fuzz);
        case MaterialType::DiffuseLight:
            return new DiffuseLight(albedo, intensity);
        default:
            return nullptr;
        }
    };
};

struct RawTriangleData {
    Vector3 vertices[3];
    RawMaterialData material;
};

struct RawSphereData {
    Vector3 center;
    double radius;
    RawMaterialData material;
};

struct WorldData {
    RawSphereData *spheres = nullptr;
    int sphereCount;
    void InsertSpheres(std::vector<RawSphereData> &rawSpheres) {
        sphereCount = rawSpheres.size();
        size_t spheresSize = sphereCount * sizeof(RawSphereData);
        spheres = (RawSphereData *)realloc(spheres, spheresSize);
        memcpy(spheres, rawSpheres.data(), spheresSize);
    };

    RawTriangleData *triangles = nullptr;
    int triangleCount;
    void InsertTriangles(std::vector<RawTriangleData> &rawTriangles) {
        triangleCount = rawTriangles.size();
        size_t triangleSize = triangleCount * sizeof(RawTriangleData);
        triangles = (RawTriangleData *)realloc(spheres, triangleSize);
        memcpy(triangles, rawTriangles.data(), triangleSize);
    };

    ~WorldData() {
        free(spheres);
        free(triangles);
    }
};