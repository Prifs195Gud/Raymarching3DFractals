
#include <Job.h>

Job::Job()
{
	scene = 0;
	threadsPerBlock = THREAD_COUNT;
	lightingOn = true;
	ignoredFirst = false;
	repeatCount = 1;

	resolutionX = 128;
	resolutionY = 128;

	AOOn = true;
	ditheringOn = true;
	maxRaySteps = MAX_RAY_STEPS;
	minRayStep = MIN_DISTANCE;
	saveImage = false;
}

Vector3 ReadVector3(stringstream& ss)
{
	float tempX, tempY, tempZ;

	ss >> tempX;
	ss >> tempY;
	ss >> tempZ;

	return Vector3(tempX, tempY, tempZ);
}

bool Job::Load(string str)
{
	if (str == "")
		return false;

	stringstream readStream(str);
	readStream.exceptions(stringstream::failbit | stringstream::badbit);

	try
	{
		readStream >> scene;

		readStream >> resolutionX;
		readStream >> resolutionY;

		readStream >> threadsPerBlock;
		readStream >> repeatCount;

		readStream >> maxRaySteps;
		readStream >> minRayStep;

		camPos = ReadVector3(readStream);
		camRot = ReadVector3(readStream);

		readStream >> lightingOn;
		readStream >> ditheringOn;
		readStream >> AOOn;

		readStream >> saveImage;

		if (threadsPerBlock > 1024)
			threadsPerBlock = 1024;
		else if(threadsPerBlock == 0)
			threadsPerBlock = 1;

		repeatCount++; // Because we ignore the first result

		if (maxRaySteps == 0 || maxRaySteps > 1024)
			maxRaySteps = MAX_RAY_STEPS;

		if (minRayStep == 0)
			minRayStep = MIN_DISTANCE;

		if (repeatCount > 1024)
			repeatCount = 1024;
		else if (repeatCount == 0)
			repeatCount = 1;

		if (resolutionX > 4096)
			resolutionX = 4096;

		if (resolutionY > 4096)
			resolutionY = 4096;
	}
	catch (stringstream::failure e)
	{
		SDL_Log(e.what());
		return false;
	}

	return true;
}

void Job::AddTime(float time)
{
	if (!ignoredFirst)
	{
		ignoredFirst = true;
		return;
	}
	times.push_back(time * 1000);
}

float Job::GetAverageTime()
{
	if (times.size() == 0)
		return 0;

	float sum = 0;
	for (size_t i = 0; i < times.size(); i++)
		sum += times[i];
	return sum / times.size();
}

string Job::GetTimesString()
{
	if (times.size() == 0)
		return "";

	string str = "";
	for (size_t i = 0; i < times.size() - 1; i++)
		str += to_string(times[i]) + ",";
	str += to_string(times[times.size() - 1]) + "";
	return str;
}

MetaJob::MetaJob()
{
	name = "No name";
}

void MetaJob::Load(string filePath)
{
	name = GetFileName(filePath);
	filePath = RemoveQuotes(filePath);

	ifstream read(filePath);

	if (!read.is_open())
		return;

	string line;
	while (getline(read, line))
	{
		if (line.length() < 5 || line[0] == '/' || line[0] == '#')
			continue;

		Job newJob;
		newJob.name = name;
		if (newJob.Load(line))
			jobs.push_back(newJob);
	}

	read.close();
}

string MetaJob::GetResults()
{
	string str = "Job: " + name + "\n";

	if (jobs.size() > 0)
	{
		for (size_t i = 0; i < jobs.size() - 1; i++)
			str += jobs[i].GetTimesString() + "\n";
		str += jobs[jobs.size() - 1].GetTimesString();
	}

	str += "\n";

	return str;
}

vector<Job>* MetaJob::GetJobs()
{
	return &jobs;
}
