#pragma once

#include <SDL.h>
#include <SDLWin.h>

#include <Program.h>

#include <string>
#include <vector>

using namespace std;

int main(int argc, char** argv)
{
	vector<string> arguments;
	for (size_t i = 1; i < argc; i++)
		arguments.push_back(string(argv[i]));
	//arguments.push_back("D:\\Users\\dovyasf\\Desktop\\School\\University\\Bakalauras\\TyrimasDithering\\KubasDithering.txt");
	Program::Start(arguments);
	return 0;
}