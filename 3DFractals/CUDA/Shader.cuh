#pragma once

#include <SDL.h>

#include <CudaFunctions.cuh>
#include <CVector.cuh>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <SDF.cuh>

#define THREAD_COUNT 128

#define MAX_RAY_STEPS 200

#define MAX_DISTANCE 100.0f
#define MIN_DISTANCE 0.001f

#define MAX_LIGHT_DISTANCE MAX_DISTANCE * 1
#define LIGHT_NORMAL_EPSILON 0.0001f

#define FOG_DENSITY 0.03f
#define SOFT_SHADOW_FACTOR 16.0f

#define AMBIENT_OCCLUSION_MULTIPLIER 2.0f
#define AMBIENT_OCCLUSION_STEP 0.001f
#define AMBIENT_OCCLUSION_SAMPLES 10

#define CAMERA_FOV 1

struct FColor
{
	float r;
	float g;
	float b;
};

struct SceneParameters
{
	SDL_Color* pixelBuffer;

	int width, height;

	float cx, cy, cz;
	float rx, ry;

	float lrx, lry;

	bool heatmapMode;
	bool lightingMode;
	bool AOMode;
	bool ditherMode;

	unsigned int scene;
	unsigned int threadsPerBlock;
	unsigned int minRayStep;
	unsigned int maxRaySteps;
};

void ApplyShader(SceneParameters params, bool copyPixelsFromGPU);
void FreeVideoMemory();