#pragma once

#include <SDL.h>
#include <SDLWin.h>

#include <Windows.h>
#include <chrono>
#include <vector>
#include <string>
#include <fstream>

#include <Text.h>
#include <Vector.h>
#include <Shader.cuh>
#include <Job.h>

using namespace std;

#define BASE_RESOLUTION_X 1920 
#define BASE_RESOLUTION_Y 1080 
#define BASE_RESOLUTION Vector2(BASE_RESOLUTION_X, BASE_RESOLUTION_Y)

#define SAVE_IMAGE_RESOLUTION_X 3840 // 4K
#define SAVE_IMAGE_RESOLUTION_Y 2160 
#define SAVE_IMAGE_RESOLUTION Vector2(SAVE_IMAGE_RESOLUTION_X, SAVE_IMAGE_RESOLUTION_Y)

class Program
{
private:
	static Program *singleton;

	Program();
	Program(vector<string> arguments);

	void CommonConstructor();
	void Initialize();
	void ReadArguments(vector<string> arguments);
	void SaveResults();
	void MainLoop();
	void Tick();
	void Quit();

	void CatchUserInput();
	void CatchPause();
	void CatchSave();

	void RenderImage(SDL_Color* pixelBuff, int width, int height, bool copyPixelsFromGPU);
	void DisplayImage(SDL_Color* pixelBuff);
	void TakeAScreenshot(int width, int height);
	void SaveImage(string filename, SDL_Color* pixels, int width, int height);
	void ProcessJobs();

	bool initialized;

	SDLWIN* SDLWindow;
	SDL_Color* pixelBuffer;

	Vector3 cameraPos;
	Vector3 speedVec;

	Vector3 cameraRot; // Euler in PI
	Vector3 rotationalVec;

	vector<MetaJob> metaJobs;

	Text* fpsText;
	Text* posRotText;

	float deltatime;

	bool quitted;

	bool pressedPause;
	bool paused;

	bool pressedSaveImage;
	bool saveImage;

	bool pressedHeatmapMode;
	bool heatmapMode;

	bool pressedLightingMode;
	bool lightingMode;

	bool pressedAOMode;
	bool AOMode;

	bool pressedDitherMode;
	bool ditherMode;

	unsigned int currentScene;
	unsigned int currentThreadsPerBlock;
	unsigned int currentMaxRaySteps;

	float currentMinRayStep;

	const float maxSpeed = 3.0f;
	const float acceleration = 20.0f;

	const float maxRotSpeed = PI / 1.75f;
	const float rotAcceleration = PI * 20.f;

public:
	static void Start(vector<string> arguments);
};