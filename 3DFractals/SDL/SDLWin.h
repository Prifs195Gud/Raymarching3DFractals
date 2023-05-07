#pragma once

#include <SDL.h>
#include <SDL_ttf.h>

#include <Text.h>
#include <Vector.h>

class SDLWIN
{
private:
	SDL_Window* window;
	SDL_Renderer* renderer;
	SDL_Texture* renderTexture;

public:
	SDLWIN(int width, int height);
	~SDLWIN() {};

	static SDLWIN* singleton;

	void SDLInitialize(int width, int height);
	void SDLQuit();
	void SDLDraw(SDL_Color* pixelBuffer, int width);

	static SDL_Renderer* GetRenderer();
	static void RenderClear();
	static void RenderPresent();
};