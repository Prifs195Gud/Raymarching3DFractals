
#include <SDLWin.h>

SDLWIN* SDLWIN::singleton = nullptr;

SDLWIN::SDLWIN(int width, int height)
{
	window = nullptr;
	renderer = nullptr;
	renderTexture = nullptr;

	singleton = this;

	SDLInitialize(width, height);
}

void SDLWIN::SDLInitialize(int width, int height)
{
	SDL_Init(SDL_INIT_EVERYTHING);
	SDL_CreateWindowAndRenderer(width, height, 0, &window, &renderer);

	TTF_Init();
	Font* newFont = new Font("FreeSans.ttf");

	renderTexture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STREAMING, width, height);
}

void SDLWIN::SDLQuit()
{
	Font::DeleteFonts();
	TTF_Quit();

	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();
}

void SDLWIN::SDLDraw(SDL_Color* pixelBuffer, int width)
{
	SDL_UpdateTexture(renderTexture, NULL, pixelBuffer, width * 4); // 4 bytes per pixel * width
	SDL_RenderCopy(renderer, renderTexture, NULL, NULL);
}

SDL_Renderer* SDLWIN::GetRenderer()
{
	return singleton->renderer;
}

void SDLWIN::RenderClear()
{
	SDL_RenderClear(singleton->renderer);
}

void SDLWIN::RenderPresent()
{
	SDL_RenderPresent(singleton->renderer);
}
