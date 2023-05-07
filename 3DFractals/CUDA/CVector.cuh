#pragma once

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

//#include <math.h>
//#include <cmath>
//
//# define PI 3.14159265358979323846f  /* pi */
//const static float Deg2Rad = (PI * 2.f) / 360.f;
//const static float Rad2Deg = 360.f / (PI * 2.f);

class CVector2
{
public:
	//static CVector2 up, down, right, left, zero, one;

	float x, y;

	__device__ CVector2()
	{
		x = 0.f;
		y = 0.f;
	}
	__device__ CVector2(float X, float Y)
	{
		x = X;
		y = Y;
	}
	//__device__ ~CVector2();

	__device__ CVector2 operator +(CVector2 foo)
	{
		return CVector2(x + foo.x, y + foo.y);
	}
	__device__ CVector2 operator -(CVector2 foo)
	{
		return CVector2(x - foo.x, y - foo.y);
	}

	//__device__ CVector2 operator -();

	__device__ CVector2 operator *(float foo)
	{
		return CVector2(x * foo, y * foo);
	}
	__device__ CVector2 operator /(float foo)
	{
		return CVector2(x / foo, y / foo);
	}

	//__device__ void operator +=(CVector2 foo);
	//__device__ void operator -=(CVector2 foo);

	//__device__ bool operator ==(CVector2 foo);
	//__device__ bool operator !=(CVector2 foo);

	//__device__ CVector2 Normalize();
	//__device__ CVector2 Absolute();
	//__device__ float Scalar(CVector2 foo);

	//__device__ float VectorAngle(CVector2 foo);

	//__device__ float Magnitude();
};

class CVector3
{
public:
	float x, y, z;

	//static CVector3 up, down, right, left, forwards, backwards, zero, one;

	__device__ CVector3()
	{
		x = 0.f;
		y = 0.f;
		z = 0.f;
	}
	//__device__ CVector3(CVector2 vec);
	__device__ CVector3(float X, float Y, float Z)
	{
		x = X;
		y = Y;
		z = Z;
	}

	//~CVector3();

	__device__ CVector3 operator+(CVector3 foo)
	{
		return CVector3(x + foo.x, y + foo.y, z + foo.z);
	}

	__device__ CVector3 operator+(float foo)
	{
		return CVector3(x + foo, y + foo, z + foo);
	}

	__device__ CVector3 operator-(CVector3 foo)
	{
		return CVector3(x - foo.x, y - foo.y, z - foo.z);
	}
	__device__ CVector3 operator-(float foo)
	{
		return CVector3(x - foo, y - foo, z - foo);
	}

	__device__ CVector3 operator -()
	{
		return CVector3(-x, -y, -z);
	}

	__device__ CVector3 operator %(float foo)
	{
		return CVector3(fmodf(x,  foo), fmodf(y, foo), fmodf(z, foo)); // fmodf = Calculate the floating-point remainder of x / y.
	}

	__device__ CVector3 operator *(float foo)
	{
		return CVector3(x * foo, y * foo, z * foo);
	}

	__device__ CVector3 operator *(CVector3 foo)
	{
		return CVector3(x * foo.x, y * foo.y, z * foo.z);
	}

	__device__ CVector3 Absolute()
	{
		return CVector3(abs(x), abs(y), abs(z));
	}

	__device__ CVector3 Maximum(float bar)
	{
		return CVector3(max(x, bar), max(y, bar), max(z, bar));
	}
	//__device__ CVector3 operator /(float foo);

	//__device__ void operator +=(CVector3 foo);
	//__device__ void operator -=(CVector3 foo);

	//__device__ bool operator ==(CVector3 foo);
	//__device__ bool operator !=(CVector3 foo);

	__device__ float Magnitude()
	{
		return sqrt(x * x + y * y + z * z);
	}

	__device__ CVector3 Normalize()
	{
		CVector3 normalizedVec = *this;
		float magnitude = normalizedVec.Magnitude();

		CVector3 newVec(normalizedVec.x / magnitude, normalizedVec.y / magnitude, normalizedVec.z / magnitude);
		return newVec;
	}

	//__device__ float VectorAngle(CVector3 foo);
	__device__ float Scalar(CVector3 foo)
	{
		return x * foo.x + y * foo.y + z * foo.z;
	}

	//__device__ float Magnitude();

	__device__ static CVector3 RotateByX(CVector3 vec, float alpha)
	{
		float Y = vec.y;
		float Z = vec.z;

		vec.y = Y * cos(alpha) - Z * sin(alpha);
		vec.z = Y * sin(alpha) + Z * cos(alpha);

		return vec;
	}

	__device__ static CVector3 RotateByY(CVector3 vec, float alpha)
	{
		float X = vec.x;
		float Z = vec.z;

		vec.x = X * cos(alpha) + Z * sin(alpha);
		vec.z = -X * sin(alpha) + Z * cos(alpha);

		return vec;
	}

	//static CVector3 RotateByZ(CVector3 vec, float alpha)
	//{
	//	float X = vec.x;
	//	float Y = vec.y;

	//	vec.x = X * cos(alpha) - Y * sin(alpha);
	//	vec.y = X * sin(alpha) + Y * cos(alpha);

	//	return vec;
	//}

	__device__ static CVector3 Reflect(CVector3 ray, CVector3 normal)
	{
		normal = normal.Normalize();

		return ray - normal * ray.Scalar(normal) * 2;
	}

	__device__ static CVector3 Lerp(CVector3 foo, CVector3 bar, float a)
	{
		return foo * (1.0f - a) + bar * a;
	}

	__device__ static float Similarity(CVector3 foo, CVector3 bar)
	{
		foo = foo.Normalize();
		bar = bar.Normalize();
		return foo.Scalar(bar) * 0.5f + 0.5f;
	}
};

__device__ static float Lerp(float foo, float bar, float a)
{
	return foo * (1.0f - a) + bar * a;
}

__device__ static float Clamp(float x, float a, float b)
{
	return fmaxf(a, fminf(b, x));
}

__device__ static float Clamp01(float x)
{
	return fmaxf(0.0f, fminf(1.0f, x));
}