
#include <Text.h>

std::vector<Font*> Font::fonts;

Font::Font()
{
	font = nullptr;
}

Font::Font(std::string fontPath)
{
	font = TTF_OpenFont(fontPath.c_str(), 24);
	fonts.push_back(this);
}

Font::~Font()
{
	if (font != nullptr)
	{
		fonts.erase(std::remove(fonts.begin(), fonts.end(), this), fonts.end());
		TTF_CloseFont(font);
		font = nullptr;
	}
}

bool Font::ChangeFont(std::string fontPath)
{
	TTF_Font* newFont = TTF_OpenFont(fontPath.c_str(), 24);
	if (newFont == nullptr)
		return false;

	if (font == nullptr)
	{
		font = newFont;
		fonts.push_back(this);
		return true;
	}

	TTF_CloseFont(font);
	font = newFont;

	return true;
}

TTF_Font* Font::GetFirstFont()
{
	for (size_t i = 0; i < fonts.size(); i++)
		if (fonts[i]->font != nullptr)
			return fonts[i]->font;

	return nullptr;
}

void Font::DeleteFonts()
{
	for (size_t i = 0; i < fonts.size(); i++)
		delete fonts[i];
}


std::vector<Text*> Text::texts;

void GetTextAndRect(SDL_Renderer* renderer, int x, int y, char* text, TTF_Font* font, SDL_Texture** texture, SDL_Rect* rect) 
{
	int text_width;
	int text_height;
	SDL_Surface* surface;
	SDL_Color textColor = { 255, 255, 255, 0 };

	surface = TTF_RenderText_Solid(font, text, textColor);
	*texture = SDL_CreateTextureFromSurface(renderer, surface);
	text_width = surface->w;
	text_height = surface->h;
	SDL_FreeSurface(surface);
	rect->x = x;
	rect->y = y;
	rect->w = text_width;
	rect->h = text_height;
}

void Text::InitializeRenderText()
{
	SDL_Surface* surface = TTF_RenderText_Solid(Font::GetFirstFont(), text.c_str(), color);
	if (surface == nullptr)
		return;

	texture = SDL_CreateTextureFromSurface(SDLWIN::GetRenderer(), surface);
	rect.w = surface->w;
	rect.h = surface->h;
	SDL_FreeSurface(surface);
}

void Text::Initialize(Vector2 position, Vector2 scale)
{
	if (initialized)
		return;
	initialized = true;

	texts.push_back(this);

	color = SDL_Color();
	color.r = color.g = color.b = color.a = 255;

	rect.x = (int)position.x;
	rect.y = (int)position.y;

	InitializeRenderText();
}

Text::Text() : initialized(false)
{
	Initialize(Vector2(), Vector2(1, 1));
}

Text::Text(std::string Text) : initialized(false)
{
	text = Text;
	Initialize(Vector2(), Vector2(1, 1));
}

Text::Text(std::string Text, Vector2 position) : initialized(false)
{
	text = Text;
	Initialize(position, Vector2(1, 1));
}

Text::Text(std::string Text, Vector2 position, Vector2 scale) : initialized(false)
{
	text = Text;
	Initialize(position, scale);
}

Text::~Text()
{
	texts.erase(std::remove(texts.begin(), texts.end(), this), texts.end());
	SDL_DestroyTexture(texture);
}

void Text::Render(SDL_Renderer* renderer)
{
	if(texture != nullptr)
		SDL_RenderCopy(renderer, texture, NULL, &rect);
}

void Text::SetText(std::string newText)
{
	if (text == newText)
		return;
	text = newText;
	InitializeRenderText();
}

void Text::RenderAllTexts()
{
	SDL_Renderer* renderer = SDLWIN::GetRenderer();
	for (size_t i = 0; i < texts.size(); i++)
		texts[i]->Render(renderer);
}
