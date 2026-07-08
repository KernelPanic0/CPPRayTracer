#include <iostream>
#include <stdint.h>
#include "Renderer.cuh"
#include "Vector.cuh"

#define checkCudaErrors(val) check_cuda((val), #val, __FILE__, __LINE__)
void check_cuda(cudaError_t result, char const *const func, const char *const file, int const line) {
  if (result) {
    std::cerr << "CUDA error = " << static_cast<unsigned int>(result) << " at " << file << ":" << line << " '" << func << "' \n";
    // Make sure we call CUDA Device Reset before exiting
    cudaDeviceReset();
    exit(99);
  }
}

__global__ void render(uint8_t *fb, int maxX, int maxY) {
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  int j = threadIdx.y + blockIdx.y * blockDim.y;

  if ((i >= maxX) || (j >= maxY))
    return;

  int pixel_index = j * maxX * 3 + i * 3;

  int r = (int)(255.999 * double(i) / maxX);
  int g = (int)(255.999 * double(j) / maxY);
  int b = (int)(255.999 * 0.2);

  fb[pixel_index + 0] = (uint8_t)r;
  fb[pixel_index + 1] = (uint8_t)g;
  fb[pixel_index + 2] = (uint8_t)b;
}

uint8_t *StartRender(int imageHeight, int imageWidth) {
  int numPixels = (int)imageHeight * imageWidth;
  size_t fbSize = 3 * numPixels * sizeof(uint8_t);

  uint8_t *fb;
  checkCudaErrors(cudaMallocManaged((void **)&fb, fbSize));

  int tx = 8;
  int ty = 8;

  // Render our buffer
  dim3 blocks(imageWidth / tx + 1, imageHeight / ty + 1);
  dim3 threads(tx, ty);

  render<<<blocks, threads>>>(fb, imageWidth, imageHeight);
  checkCudaErrors(cudaGetLastError());
  checkCudaErrors(cudaDeviceSynchronize());

  return fb;
}
