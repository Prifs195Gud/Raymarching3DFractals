
#include <Shader.cuh>

SDL_Color* dev_pixels = nullptr;

//https://forum.openframeworks.cc/t/hsv-color-setting/770
// H [0, 360] S and V [0.0, 1.0].
__device__ CVector3 HSVToColor(float h, float s, float v)
{
	int i = (int)floor(h / 60.0f) % 6;
	float f = h / 60.0f - floor(h / 60.0f);
	float p = v * (float)(1 - s);
	float q = v * (float)(1 - s * f);
	float t = v * (float)(1 - (1 - f) * s);
	switch (i) 
	{
	case 0: return CVector3(v, t, p);
		break;
	case 1: return CVector3(q, v, p);
		break;
	case 2: return CVector3(p, v, t);
		break;
	case 3: return CVector3(p, q, v);
		break;
	case 4: return CVector3(t, p, v);
		break;
	case 5: return CVector3(v, p, q);
	}
}

__device__ float DistanceUnion(float d1, float d2) { return min(d1, d2); }

__device__ float DistanceSubtraction(float d1, float d2) { return max(-d1, d2); }

__device__ float DistanceIntersection(float d1, float d2) { return max(d1, d2); }

__device__ float DistanceEstimator(CVector3 &point, unsigned int &scene)
{
	switch (scene)
	{
	default: // Plane
		return point.y;

	case 0:
		return SDF_Sphere(point, 1);

	case 1:
		return SDF_Box(point, CVector3(1, 1, 1));

	case 2:
		return SDF_Tetrahedron(point);

	case 4:
		return SDF_Sierpinski(point, 6);

	case 5:
		return MengerSponge(point, 6, 5);

	case 6:
		return Mandelbulb(point, 20, 8.0f, 4.0f);

	case 7: // Mandelbulb with plane
		return min(Mandelbulb(point, 20, 8.0f, 4.0f), point.y + 4.0f);

	case 8: // 3 Primitives
		float minDist = SDF_Box(point, CVector3(-2.5, 0, 0), CVector3(1, 1, 1));
		minDist = min(minDist, SDF_Sphere(point, CVector3(2.5, 0, 0), 1));
		minDist = min(minDist, SDF_Tetrahedron(point));
		return minDist;

	case 9: // Repeating spheres without a plane
		return R_SDF_Sphere(point, 0.3f, 4.0f);

	case 10: // Repeating spheres with a plane
		return min(R_SDF_Sphere(point, 0.3f, 1.0f), SDF_Plane(point));

	case 11: // Cut Mandelbulb with box
		return DistanceSubtraction(SDF_Box(point, CVector3(0.6, 0, 0), CVector3(0.5, 1.25, 1.25)), Mandelbulb(point, 20, 8.0f, 4.0f));

	case 12: // Blender comparison
		return min(Mandelbulb(point - CVector3(0, 4 ,0), 20, 8.0f, 4.0f), point.y);
	}

	return point.y;
}

__constant__ FColor skyColBottom{ 0.643f,0.858f,0.952f };
__constant__ FColor skyColTop{ 0.235f,0.552f,0.725f };
__device__ CVector3 GetSkyColor(CVector3 &dir)
{
	CVector3 colT = CVector3(skyColTop.r, skyColTop.g, skyColTop.b);
	CVector3 colB = CVector3(skyColBottom.r, skyColBottom.g, skyColBottom.b);

	dir = dir.Normalize();

	float a = dir.Scalar(CVector3(0, 1, 0)) * 2.f;

	if (a < 0.f)
		return colB;
	else if (a > 1.f)
		return colT;

	return CVector3::Lerp(colB, colT, a);
}

__device__ CVector3 GetNormal(CVector3& point, unsigned int& scene)
{
	float distance = DistanceEstimator(point, scene);
	CVector2 e = CVector2(LIGHT_NORMAL_EPSILON, 0.f);

	CVector3 n = CVector3(
		distance - DistanceEstimator(point - CVector3(e.x, e.y, e.y), scene),
		distance - DistanceEstimator(point - CVector3(e.y, e.x, e.y), scene),
		distance - DistanceEstimator(point - CVector3(e.y, e.y, e.x), scene));

	return n.Normalize();
}

//https://www.desmos.com/calculator/wcfuquljqq
__device__ float Sigmoid(float x, float multiplier, float offset)
{
	return 1 / (1 + expf(-(x * multiplier + offset)));
}

//https://iquilezles.org/articles/rmshadows/
__device__ float ShadowLevel(CVector3 &pos, CVector3 &dir, float k, unsigned int& scene)
{
	float res = 1.0;
	float ph = 1e20;

	for (float t = 0.05f; t < 1.0f; )
	{
		float h = DistanceEstimator(pos + dir * t, scene);
		if (h < 0.001)
			return 0.0;
		float y = h * h / (2.0 * ph);
		float d = sqrt(h * h - y * y);
		res = fminf(res, k * d / fmaxf(0.0, t - y));
		ph = h;
		t += h;
	}
	return res;
}

__device__ float AmbientOcclusion(CVector3 &pos, CVector3 &normal, unsigned int& scene)
{
	float acc = 0.0;

	for (int i = 1; i <= AMBIENT_OCCLUSION_SAMPLES; ++i)
	{
		float d = DistanceEstimator(pos + normal * AMBIENT_OCCLUSION_STEP * i, scene);
		acc += powf(2.0f, -i) * (i * AMBIENT_OCCLUSION_STEP - max(d, 0.0f));
	}

	return min(1.0f - AMBIENT_OCCLUSION_MULTIPLIER * acc, 1.0f);
}

__device__ float AdvancedLight(CVector3& pos, CVector3& normal, CVector3& lightDirection, unsigned int& scene)
{
	float shadow = ShadowLevel(pos, lightDirection, 10, scene);

	if (shadow < 0.05f)
		shadow = 0.0f;
	else if (shadow > 1.f)
		shadow = 1.f;

	float diffuse = lightDirection.Scalar(normal) * shadow;

	if (diffuse > 1.f)
		return 1.f;
	else if (diffuse < 0.f)
		return 0.f;

	return diffuse;
}

__device__ float SimpleLight(CVector3 &normal, CVector3 &lightDirection)
{
	float diffuse = lightDirection.Scalar(normal);

	if (diffuse > 1.f)
		return 1.f;
	else if (diffuse < 0.f)
		return 0.f;

	return diffuse;
}

__device__ float RayMarch(float rayOffset, float &AO, CVector3 from, CVector3 direction, int &steps, SceneParameters& params)
{
	float totalDistance = rayOffset;
	for (steps = 0; steps < params.maxRaySteps; steps++)
	{
		CVector3 point = from + direction * totalDistance;

		float distance = fabsf(DistanceEstimator(point, params.scene));
		totalDistance += distance;

		if (distance < MIN_DISTANCE || distance > MAX_DISTANCE)
			break;
	}

	AO = 1.0f - float(steps) / float(MAX_RAY_STEPS);
	AO = Clamp(powf(AO, 2.0f), 0, 1);
	return totalDistance;
}

__device__ CVector3 GetRayDir(int &screenCoordX, int &screenCoordY, SceneParameters &params)
{
	CVector2 screenCoord = CVector2(screenCoordX, screenCoordY);

	CVector2 iResolution = CVector2(params.width, params.height);

	CVector2 uv = (screenCoord - iResolution * 0.5f) / iResolution.y;

	CVector3 rayDir = CVector3(uv.x, -uv.y, CAMERA_FOV).Normalize();

	rayDir = CVector3::RotateByX(rayDir, params.rx);
	rayDir = CVector3::RotateByY(rayDir, params.ry);

	return rayDir;
}

__device__ float GetLight(float &dist, float& reflectRatio, float &specular, CVector3 &reflectSkyCol, CVector3 &rayDir, CVector3 &point, SceneParameters &params)
{
	/*if (dist - 1.f > MAX_DISTANCE)
		return 0.f;

	return 1 - (dist / 10.0f);*/

	CVector3 normal = GetNormal(point, params.scene);

	CVector3 lightDir = CVector3(0.0f, 0.0f, 1.0f);
	lightDir = CVector3::RotateByX(lightDir, params.lrx);
	lightDir = CVector3::RotateByY(lightDir, params.lry);
	lightDir = lightDir.Normalize();

	float light = 1.f;

	if (params.lightingMode && dist < MAX_LIGHT_DISTANCE)
		light = AdvancedLight(point, normal, lightDir, params.scene);
		//light = SimpleLight(normal, lightDir);
	light = pow(light, 0.45454545454f); // Gamma light level correction

	specular = powf(CVector3::Similarity(lightDir, normal), 25.0f);
	reflectSkyCol = GetSkyColor(CVector3::Reflect(rayDir, normal));
	reflectRatio = Clamp01(1.0f - CVector3::Similarity(-rayDir, normal) * 0.5f);

	return light;
}

// https://blog.demofox.org/2020/05/10/ray-marching-fog-with-blue-noise/
// https://www.shadertoy.com/view/WsfBDf
__device__ float InterleavedGradientNoise(float screenCoordX, float screenCoordY)
{
	float a = 0.06711056f * screenCoordX + 0.00583715f * screenCoordY;
	a = fmodf(a, 1);
	a = 52.9829189f * a;
	a = fmodf(a, 1);
	return a;
}

__device__ CVector3 GetColor(int& index, SceneParameters& params)
{
	int screenCoordY = index / params.width;
	int screenCoordX = index - params.width * screenCoordY;

	CVector3 rayDir = GetRayDir(screenCoordX, screenCoordY, params);
	CVector3 cam = CVector3(params.cx, params.cy, params.cz);

	int steps;

	float AO, rayOffset = InterleavedGradientNoise(screenCoordX, screenCoordY) * 0.01f;

	if (!params.ditherMode)
		rayOffset = 0;

	float dist = RayMarch(rayOffset, AO, cam, rayDir, steps, params);
	//AO = Clamp(AO, 0.5f, 1.0f);

	CVector3 skyColor = GetSkyColor(rayDir);
	if (dist - 1.f > MAX_DISTANCE)
		return skyColor;

	if (params.heatmapMode)
		return HSVToColor((1 - (steps / (float)MAX_RAY_STEPS)) * 243.0f, 1, 1);

	float specular, reflectRatio;
	float fog = (1 / exp2f(FOG_DENSITY * dist)); // Double exp fog
	CVector3 reflectSkyCol;

	CVector3 point = cam + rayDir * dist;
	float light = GetLight(dist, reflectRatio, specular, reflectSkyCol, rayDir, point, params);

	CVector3 objectCol = CVector3(1.0f, 1.0f, 1.0f);
	CVector3 col = CVector3::Lerp(objectCol, reflectSkyCol, Clamp(reflectRatio, 0.5f, 0.75f)); // Ambient light
	col = CVector3::Lerp(col, objectCol, light); // Object color
	col = CVector3::Lerp(col, reflectSkyCol * 0.1f, 1.0f - Clamp(light, 0.1f, 1.0f)); // Add shadows

	if(params.AOMode)
		col = col * Lerp(AO, 1, reflectRatio); // Add ambient occlusion

	col = CVector3::Lerp(col, skyColor, 1 - fog); // Add fog

	return col;
}

__global__ void Shader(SceneParameters params)
{
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	//int index = blockIdx.x * blockDim.x * blockDim.y + threadIdx.y * blockDim.x + threadIdx.x;

	if (index >= params.width * params.height) // Offscreen
		return;

	CVector3 col = GetColor(index, params);

	if (col.x < 0.f)
		col.x = 0.f;
	else if (col.x > 1.f)
		col.x = 1.f;

	if (col.y < 0.f)
		col.y = 0.f;
	else if (col.y > 1.f)
		col.y = 1.f;

	if (col.z < 0.f)
		col.z = 0.f;
	else if (col.z > 1.f)
		col.z = 1.f;

	SDL_Color* pixel = &params.pixelBuffer[index];
	pixel->r = (int)(col.z * 255);
	pixel->g = (int)(col.y * 255);
	pixel->b = (int)(col.x * 255);
}

int lastWidth = 0, lastHeight = 0;
void Initialize(int width, int height)
{
	lastWidth = width;
	lastHeight = height;
	CudaMalloc(dev_pixels, sizeof(SDL_Color) * width * height);
}

void FreeVideoMemory()
{
	cudaFree(dev_pixels);
	CudaErrorCheck();
}

void ApplyShader(SceneParameters params, bool copyPixelsFromGPU)
{
	int totalPixels = params.width * params.height;

	//int sqrThreads = (int)lround(sqrt(params.threadsPerBlock)); // 2D mode

	int blockCount = (int)ceil((float)totalPixels / (float)params.threadsPerBlock);

	if (dev_pixels == nullptr || params.width != lastWidth || params.height != lastHeight)
	{
		if(dev_pixels != nullptr)
			FreeVideoMemory();
		Initialize(params.width, params.height);
		CudaErrorCheck();
	}

	SceneParameters shaderParams = params;
	shaderParams.pixelBuffer = dev_pixels;

	dim3 threadsPerBlock(params.threadsPerBlock, 1, 1); // 1D mode
	//dim3 threadsPerBlock(sqrThreads, sqrThreads, 1); // 2D mode
	Shader <<<blockCount, threadsPerBlock >>> (shaderParams);
	CudaErrorCheck();

	CudaDeviceSynchronize();
	CudaErrorCheck();

	if (copyPixelsFromGPU)
	{
		CudaCopyFromGPU(params.pixelBuffer, dev_pixels, sizeof(SDL_Color) * totalPixels);
		CudaErrorCheck();
	}
}