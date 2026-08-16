#pragma once

// Single HIP source tree, compiled by hipcc for either backend
// (HIP_PLATFORM=amd or HIP_PLATFORM=nvidia picks the target at build time).
#include "Hittable.cuh"
#include "Material.cuh"
#include "RawSphereData.hpp"
#include "Renderer.cuh"
#include "Sphere.cuh"
#include "Vector.cuh"

using ActiveRenderer = CudaRenderer;