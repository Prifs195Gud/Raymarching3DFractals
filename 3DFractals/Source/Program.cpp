
#include <Program.h>

Program *Program::singleton = nullptr;

void Program::CommonConstructor()
{
	initialized = false;

	pressedPause = false;
	paused = false;

	pressedSaveImage = false;
	saveImage = false;

	pressedHeatmapMode = false;
	heatmapMode = false;

	quitted = false;

	pressedLightingMode = false;
	lightingMode = true;

	pressedAOMode = false;
	AOMode = true;

	pressedDitherMode = false;
	ditherMode = true;

	currentMinRayStep = MIN_DISTANCE;

	currentMaxRaySteps = MAX_RAY_STEPS;
	currentThreadsPerBlock = THREAD_COUNT;
	currentScene = 12;

	cameraPos = Vector3(-0.164029f, 1.00324f, -1.006772f);
	cameraRot = Vector3(0.265318f, -0.988902f, 0.0f);

	deltatime = 1.0f;
}

Program::Program()
{
	CommonConstructor();

	Initialize();
	MainLoop();
}

Program::Program(vector<string> arguments)
{
	CommonConstructor();

	if (arguments.size() == 0)
	{
		Initialize();
		MainLoop();
		return;
	}

	ReadArguments(arguments);
	Initialize();
	ProcessJobs();
	SaveResults();
	Quit();
}

void Program::ReadArguments(vector<string> arguments)
{
	if (arguments.size() == 0)
		return;

	for (size_t i = 0; i < arguments.size(); i++)
	{
		MetaJob newMetaJob;
		newMetaJob.Load(arguments[i]);
		metaJobs.push_back(newMetaJob);
	}
}

void Program::SaveResults()
{
	ofstream write("results.txt");

	for (size_t i = 0; i < metaJobs.size(); i++)
		write << metaJobs[i].GetResults();

	write.close();
}

void Program::Start(vector<string> arguments)
{
	if (singleton != nullptr)
		return;

	singleton = new Program(arguments);
}

void Program::Initialize()
{
	if (initialized)
		return;

	initialized = true;

	SDLWindow = new SDLWIN(BASE_RESOLUTION_X, BASE_RESOLUTION_Y);
	pixelBuffer = new SDL_Color[BASE_RESOLUTION_X * BASE_RESOLUTION_Y];

	fpsText = new Text("0");
	posRotText = new Text("0 0 0 : 0 0 0", Vector2(0, BASE_RESOLUTION_Y - 32));
}

void Program::CatchUserInput()
{
	bool pressed = false;
	if (GetAsyncKeyState('A'))
	{
		speedVec += Vector3::RotateByY(Vector3::left * acceleration * deltatime, cameraRot.y);
		pressed = true;
	}
	else if (GetAsyncKeyState('D'))
	{
		speedVec += Vector3::RotateByY(Vector3::right * acceleration * deltatime, cameraRot.y);
		pressed = true;
	}

	if (GetAsyncKeyState('W'))
	{
		speedVec += Vector3::RotateByY(Vector3::forwards * acceleration * deltatime, cameraRot.y);
		pressed = true;
	}
	else if (GetAsyncKeyState('S'))
	{
		speedVec += Vector3::RotateByY(Vector3::backwards * acceleration * deltatime, cameraRot.y);
		pressed = true;
	}

	if (GetAsyncKeyState('E'))
	{
		speedVec += Vector3::RotateByY(Vector3::up * acceleration * deltatime, cameraRot.y);
		pressed = true;
	}
	else if (GetAsyncKeyState('Q'))
	{
		speedVec += Vector3::RotateByY(Vector3::down * acceleration * deltatime, cameraRot.y);
		pressed = true;
	}

	if (pressed)
	{
		if (speedVec.Magnitude() > maxSpeed)
			speedVec = speedVec.Normalize() * maxSpeed;
	}
	else
		speedVec = Vector3();

	if(GetAsyncKeyState(VK_LSHIFT))
		cameraPos += speedVec * 10.0f * deltatime;
	else
		cameraPos += speedVec * deltatime;

	pressed = false;

	if (GetAsyncKeyState(VK_UP))
	{
		rotationalVec.x += -rotAcceleration * deltatime;
		pressed = true;
	}
	else if (GetAsyncKeyState(VK_DOWN))
	{
		rotationalVec.x += rotAcceleration * deltatime;
		pressed = true;
	}

	if (GetAsyncKeyState(VK_LEFT))
	{
		rotationalVec.y += -rotAcceleration * deltatime;
		pressed = true;
	}
	else if (GetAsyncKeyState(VK_RIGHT))
	{
		rotationalVec.y += rotAcceleration * deltatime;
		pressed = true;
	}

	if (pressed)
	{
		if (rotationalVec.Magnitude() > maxRotSpeed)
			rotationalVec = rotationalVec.Normalize() * maxRotSpeed;
	}
	else
	{
		if (rotationalVec.Magnitude() < rotationalVec.Magnitude() * rotAcceleration * deltatime)
			rotationalVec = Vector3();
		else
			rotationalVec = rotationalVec - rotationalVec * rotAcceleration * deltatime;
	}

	cameraRot += rotationalVec * deltatime;

	if (GetAsyncKeyState('H')) // Heatmap mode
	{
		if (!pressedHeatmapMode)
			heatmapMode = !heatmapMode;

		pressedHeatmapMode = true;
	}
	else
		pressedHeatmapMode = false;

	if (GetAsyncKeyState('L')) // Lighting mode
	{
		if (!pressedLightingMode)
			lightingMode = !lightingMode;

		pressedLightingMode = true;
	}
	else
		pressedLightingMode = false;

	if (GetAsyncKeyState('O')) // Ambient occlusion mode
	{
		if (!pressedAOMode)
			AOMode = !AOMode;

		pressedAOMode = true;
	}
	else
		pressedAOMode = false;

	if (GetAsyncKeyState('I')) // Dithering mode
	{
		if (!pressedDitherMode)
			ditherMode = !ditherMode;

		pressedDitherMode = true;
	}
	else
		pressedDitherMode = false;

	for (int i = 0; i <= 9; i++)
		if (GetAsyncKeyState(i + '0'))
			currentScene = i;
}

void Program::MainLoop()
{
	while (!GetAsyncKeyState(VK_ESCAPE))
	{
		SDL_Event event;
		if (SDL_PollEvent(&event) && event.type == SDL_QUIT) // Quit
			break;

		CatchPause();
		CatchSave();

		if (saveImage)
		{
			saveImage = false;
			TakeAScreenshot(SAVE_IMAGE_RESOLUTION_X, SAVE_IMAGE_RESOLUTION_Y);
		}

		if (paused)
			continue;

		Tick();
	}

	Quit();
}

void Program::Quit()
{
	if (quitted || !initialized)
		return;
	quitted = true;

	delete fpsText;
	delete posRotText;

	FreeVideoMemory();
	delete[] pixelBuffer;
	SDLWindow->SDLQuit();
	delete SDLWindow;
}

void Program::CatchPause()
{
	if (GetAsyncKeyState('P')) // Pause
	{
		if (!pressedPause)
			paused = !paused;

		pressedPause = true;
	}
	else
		pressedPause = false;
}

void Program::CatchSave()
{
	if (GetAsyncKeyState('T')) // Take a picture
	{
		if (!pressedSaveImage)
			saveImage = true;

		pressedSaveImage = true;
	}
	else
		pressedSaveImage = false;
}

void Program::Tick()
{
	CatchUserInput();

	auto t1 = chrono::steady_clock::now();
	RenderImage(pixelBuffer, BASE_RESOLUTION_X, BASE_RESOLUTION_Y, true);
	DisplayImage(pixelBuffer);
	auto t2 = chrono::steady_clock::now();

	deltatime = (float)(chrono::duration_cast<chrono::microseconds>(t2 - t1).count() / 1000000.f);
	fpsText->SetText(to_string((int)(1.0f / deltatime)) + "FPS "  + to_string(deltatime * 1000) + "ms");

	posRotText->SetText("POS: "+cameraPos.ToString() + "  ROT: " + cameraRot.ToString());
}

void Program::RenderImage(SDL_Color *pixelBuff, int width, int height, bool copyPixelsFromGPU)
{
	SceneParameters params{};

	params.pixelBuffer = pixelBuff;

	params.cx = cameraPos.x;
	params.cy = cameraPos.y;
	params.cz = cameraPos.z;

	params.rx = cameraRot.x;
	params.ry = cameraRot.y;

	params.lrx = -45.0f;
	params.lry = 135.0f;

	params.width = width;
	params.height = height;

	params.heatmapMode = heatmapMode;

	params.minRayStep = currentMinRayStep;
	params.maxRaySteps = currentMaxRaySteps;
	params.threadsPerBlock = currentThreadsPerBlock;
	params.scene = currentScene;

	params.lightingMode = lightingMode;
	params.AOMode = AOMode;
	params.ditherMode = ditherMode;

	ApplyShader(params, copyPixelsFromGPU);
}

void Program::DisplayImage(SDL_Color* pixelBuff)
{
	SDLWIN::RenderClear();
	SDLWindow->SDLDraw(pixelBuffer, BASE_RESOLUTION_X);
	Text::RenderAllTexts();
	SDLWIN::RenderPresent();
}

void Program::TakeAScreenshot(int width, int height)
{
	SDL_Color* pixels = new SDL_Color[width * height];
	RenderImage(pixels, width, height, true);

	SaveImage("screenshot", pixels, width, height);

	delete[] pixels;
}

void Program::SaveImage(string filename, SDL_Color* pixels, int width, int height)
{
	SDL_Surface* surf = SDL_CreateRGBSurfaceWithFormatFrom(pixels, width, height, 8, width * 4, SDL_PIXELFORMAT_RGB888);

	if (surf == NULL)
		return;

	filename += ".bmp";

	SDL_LockSurface(surf);
	SDL_SaveBMP(surf, filename.c_str());
	SDL_FreeSurface(surf);
}

void Program::ProcessJobs()
{
	// Initialize CUDA
	SDL_Color* pixels = new SDL_Color[16 * 16];
	RenderImage(pixels, 16, 16, false);
	delete[] pixels;

	// Do the jobs
	for (size_t i = 0; i < metaJobs.size(); i++)
	{
		vector<Job>* jobs = metaJobs[i].GetJobs();
		for (size_t j = 0; j < jobs->size(); j++)
		{
			Job* job = &jobs->at(j);
			for (size_t z = 0; z < job->repeatCount; z++)
			{
				int resX = job->resolutionX;
				int resY = job->resolutionY;
				
				currentScene = job->scene;
				currentThreadsPerBlock = job->threadsPerBlock;
				currentMaxRaySteps = job->maxRaySteps;
				currentMinRayStep = job->minRayStep;

				cameraPos = job->camPos;
				cameraRot = job->camRot;

				AOMode = job->AOOn;
				lightingMode = job->lightingOn;
				ditherMode = job->ditheringOn;

				SDL_Color* pixels = new SDL_Color[resX * resY];

				auto t1 = chrono::steady_clock::now();
				RenderImage(pixels, resX, resY, z == 0 && job->saveImage);
				auto t2 = chrono::steady_clock::now();

				if (z == 0 && job->saveImage)
					SaveImage(to_string(j)+"_"+job->name + "_" + to_string(resX) + "x" + to_string(resY), pixels, resX, resY);

				delete[] pixels;

				float deltatime = (float)(chrono::duration_cast<chrono::microseconds>(t2 - t1).count() / 1000000.f);
				job->AddTime(deltatime);
			}
		}
	}
}