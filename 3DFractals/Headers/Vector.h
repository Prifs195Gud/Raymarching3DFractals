#pragma once

#include <math.h>
#include <cmath>

#include <string>

# define PI 3.14159265358979323846f
const static float Deg2Rad = (PI * 2.f) / 360.f;
const static float Rad2Deg = 360.f / (PI * 2.f);

class Vector2
{
public:
	static Vector2 up, down, right, left, zero, one;

	float x, y;

	Vector2();
	Vector2(float X, float Y);
	~Vector2();

	Vector2 operator +(Vector2 foo);
	Vector2 operator -(Vector2 foo);

	Vector2 operator -();

	Vector2 operator *(float foo);
	Vector2 operator /(float foo);

	void operator +=(Vector2 foo);
	void operator -=(Vector2 foo);

	bool operator ==(Vector2 foo);
	bool operator !=(Vector2 foo);

	Vector2 Normalize();
	Vector2 Absolute();
	float Scalar(Vector2 foo);

	float VectorAngle(Vector2 foo);

	float Magnitude();

	std::string ToString();
};

class Vector3
{
public:
	float x, y, z;

	static Vector3 up, down, right, left, forwards, backwards, zero, one;

	Vector3();
	Vector3(Vector2 vec);
	Vector3(float X, float Y, float Z);

	~Vector3();

	Vector3 operator +(Vector3 foo);
	Vector3 operator -(Vector3 foo);

	Vector3 operator -();

	Vector3 operator *(float foo);
	Vector3 operator /(float foo);

	void operator +=(Vector3 foo);
	void operator -=(Vector3 foo);

	bool operator ==(Vector3 foo);
	bool operator !=(Vector3 foo);

	Vector3 Normalize();
	Vector3 Absolute();

	float VectorAngle(Vector3 foo);
	float Scalar(Vector3 foo);

	float Magnitude();

	std::string ToString();

	static Vector3 RotateByX(Vector3 vec, float alpha)
	{
		float Y = vec.y;
		float Z = vec.z;

		vec.y = Y * cos(alpha) - Z * sin(alpha);
		vec.z = Y * sin(alpha) + Z * cos(alpha);

		return vec;
	}

	static Vector3 RotateByY(Vector3 vec, float alpha)
	{
		float X = vec.x;
		float Z = vec.z;

		vec.x = X * cos(alpha) + Z * sin(alpha);
		vec.z = -X * sin(alpha) + Z * cos(alpha);

		return vec;
	}

	static Vector3 RotateByZ(Vector3 vec, float alpha)
	{
		float X = vec.x;
		float Y = vec.y;

		vec.x = X * cos(alpha) - Y * sin(alpha);
		vec.y = X * sin(alpha) + Y * cos(alpha);

		return vec;
	}
};

/*Vector2 operator*(float bar, const Vector2& foo)
{
	return Vector2(bar * foo.x, bar * foo.y);
}

Vector2 operator*(float bar, const Vector2& foo)
{
	return Vector2((float)bar * foo.x, (float)bar * foo.y);
}*/