
#include <SDL.h>
#include <Shader.cuh>

#include <vector>
#include <string>
#include <sstream>
#include <algorithm>
#include <fstream>

#include <Files.h>
#include <Vector.h>

using namespace std;

class Job
{
private:
	bool ignoredFirst;
	vector<float> times;

public:
	string name;

	unsigned int scene;

	unsigned int resolutionX;
	unsigned int resolutionY;

	unsigned int threadsPerBlock;
	unsigned int repeatCount;

	unsigned int maxRaySteps;
	float minRayStep;

	Vector3 camPos;
	Vector3 camRot;

	bool lightingOn; // L
	bool ditheringOn; // I
	bool AOOn; // O

	bool saveImage;

	Job();
	bool Load(string str);

	void AddTime(float time);

	float GetAverageTime();
	string GetTimesString();
};

class MetaJob
{
private:
	string name;
	vector<Job> jobs;

public:
	MetaJob();

	void Load(string filePath);
	string GetResults();

	vector<Job>* GetJobs();
};