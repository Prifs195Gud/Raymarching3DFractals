#pragma once

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <string>

using namespace std;

bool CudaSetDevice();

#define CudaMalloc(x,y) CCudaMalloc((void**)&x,y)
bool CCudaMalloc(void** devPtr, size_t size);

bool CudaDeviceSynchronize();

bool CudaCopyFromGPU(void* host_ptr, void* gpu_ptr, size_t size);
bool CudaCopyToGPU(void* host_ptr, void* gpu_ptr, size_t size);

void CudaErrorCheck();