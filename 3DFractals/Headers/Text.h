#pragma once

#include <string>
#include <vector>

#include <SDL_ttf.h>

#include <SDLWin.h>
#include <Vector.h>

class Font
{
private:
	std::string fontName;
	TTF_Font* font;

	static std::vector<Font*> fonts;

public:
	Font();
	Font(std::string fontPath);
	~Font();

	bool ChangeFont(std::string fontPath);

	static TTF_Font* GetFirstFont();
	static void DeleteFonts();
};

class Text
{
private:
	std::string text;
	SDL_Color color;

	SDL_Rect rect;
	SDL_Texture* texture;

	bool initialized;

	static std::vector<Text*> texts;

	void InitializeRenderText();
	void Initialize(Vector2 position, Vector2 scale);

public:
	Text();
	Text(std::string Text);
	Text(std::string Text, Vector2 position);
	Text(std::string Text, Vector2 position, Vector2 scale);
	~Text();

	void Render(SDL_Renderer* renderer);
	void SetText(std::string newText);

	static void RenderAllTexts();
};