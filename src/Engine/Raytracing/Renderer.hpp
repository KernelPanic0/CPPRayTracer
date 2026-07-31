#pragma once

// pick between HIP and CUDA
#if defined(USE_HIP)
#define __HIP_PLATFORM_AMD__
#include "hip/Hittable.cuh"
#include "hip/Material.cuh"
#include "hip/RawSphereData.hpp"
#include "hip/Renderer.cuh"
#include "hip/Sphere.cuh"
#include "hip/Vector.cuh"
using ActiveRenderer = CudaRenderer;
#elif defined(USE_CUDA)
#define __HIP_PLATFORM_NVIDIA__
#include "Hittable.cuh"
#include "Material.cuh"
#include "RawSphereData.hpp"
#include "Renderer.cuh"
#include "Sphere.cuh"
#include "Vector.cuh"
using ActiveRenderer = CudaRenderer;
#endif

using ActiveRenderer = CudaRenderer;