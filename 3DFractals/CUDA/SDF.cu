
#include <SDF.cuh>

__device__ float SDF_Box(CVector3 point, CVector3 boxPos, CVector3 scale)
{
	CVector3 q = (point - boxPos).Absolute() - scale;
	return q.Maximum(0.0f).Magnitude() + fmin(fmax(q.x, fmax(q.y, q.z)), 0.0f);
}
__device__ float SDF_Box(CVector3 point, CVector3 scale)
{
	return SDF_Box(point, CVector3(), scale);
}

__device__ float SDF_Sphere(CVector3 point, CVector3 spherePos, float radius)
{
	return (spherePos - point).Magnitude() - radius;
}

__device__ float SDF_Sphere(CVector3 point, float radius)
{
	return point.Magnitude() - radius;
}

__device__ float SDF_Plane(CVector3 point)
{
	return point.y + 0.5f;
}


__device__ float R_SDF_Sphere(CVector3 point, float radius, float repeat)
{
	if (point.x > 0.0f)
		point.x = fmodf(point.x, repeat) - repeat * 0.5f;
	else
		point.x = -fmodf(point.x, repeat) - repeat * 0.5f;

	if (point.z > 0.0f)
		point.z = fmodf(point.z, repeat) - repeat * 0.5f;
	else
		point.z = -fmodf(point.z, repeat) - repeat * 0.5f;

	return point.Magnitude() - radius;
}

//http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/
__device__ float R_Tetrahedron(CVector3 point, int Iterations, float Scale) // ?, 10, 2.0f
{
	CVector3 a1 = CVector3(10, 10, 10);
	CVector3 a2 = CVector3(-10, -10, 10);
	CVector3 a3 = CVector3(10, -10, -10);
	CVector3 a4 = CVector3(-10, 10, -10);
	CVector3 c;

	int n = 0;
	float dist, d;

	while (n < Iterations)
	{
		c = a1;
		dist = (point - a1).Magnitude();

		d = (point - a2).Magnitude();
		if (d < dist) { c = a2; dist = d; }

		d = (point - a3).Magnitude();
		if (d < dist) { c = a3; dist = d; }

		d = (point - a4).Magnitude();
		if (d < dist) { c = a4; dist = d; }

		point = point * Scale - c * (Scale - 1.0f);
		n++;
	}

	return point.Magnitude() * powf(Scale, float(-n));
}

// Folding Space Tetrahedron
__device__ float RF_Tetrahedron(CVector3 z, int Iterations, float Scale) // ?, 10, 2.0f
{
	int n = 0;
	while (n < Iterations)
	{
		// fold 1
		if (z.x + z.y < 0)
		{
			float a = z.x;
			z.x = -z.y;
			z.y = -a;
		}

		// fold 2
		if (z.x + z.z < 0)
		{
			float a = z.x;
			z.x = -z.z;
			z.z = -a;
		}

		// fold 3	
		if (z.y + z.z < 0)
		{
			float a = z.z;
			z.z = -z.y;
			z.y = -a;
		}

		z = z * Scale - CVector3(1.f, 1.f, 1.f) * (Scale - 1.0f);

		n++;
	}

	return z.Magnitude() * powf(Scale, -float(n));
}

// https://www.shadertoy.com/view/wsVBz1
// Sierpinski Tetrahedron

// Signed distance to a tetrahedron within canonical cube
// https://www.shadertoy.com/view/Ws23zt
__device__ float SDF_Tetrahedron(CVector3 point)
{
	return (fmaxf(
		abs(point.x + point.y) - point.z,
		abs(point.x - point.y) + point.z) - 1.0f) / sqrt(3.f);
}

// Fold a point across a plane defined by a point and a normal
// The normal should face the side to be reflected
__device__ CVector3 Fold(CVector3 point, CVector3 pointOnPlane, CVector3 planeNormal)
{
	// Center plane on origin for distance calculation
	float distToPlane = (point - pointOnPlane).Scalar(planeNormal);

	// We only want to reflect if the dist is negative
	distToPlane = fminf(distToPlane, 0.0f);
	return point - planeNormal * 2.0f * distToPlane;
}

__device__ float SDF_Sierpinski(CVector3 point, int level)
{
	float scale = 1.0f;

	const CVector3 vertices[4] =
	{ CVector3(1.0, 1.0, 1.0),
		CVector3(-1.0, 1.0, -1.0),
		CVector3(-1.0, -1.0, 1.0),
		CVector3(1.0, -1.0, -1.0) };

	for (int i = 0; i < level; i++)
	{
		// Scale point toward corner vertex, update scale accumulator
		point = point - vertices[0];
		point = point * 2.0f;
		point = point + vertices[0];

		scale *= 2.0f;

		// Fold point across each plane
		for (int i = 1; i <= 3; i++)
		{
			// The plane is defined by:
			// Point on plane: The vertex that we are reflecting across
			// Plane normal: The direction from said vertex to the corner vertex
			CVector3 temp = vertices[0];
			CVector3 normal = (temp - vertices[i]).Normalize();
			point = Fold(point, vertices[i], normal);
		}
	}
	// Now that the space has been distorted by the IFS,
	// just return the distance to a tetrahedron
	// Divide by scale accumulator to correct the distance field
	return SDF_Tetrahedron(point) / scale;
}


// http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/
// Mandelbulb
__device__ float Mandelbulb(CVector3 pos, int Iterations, float power, float bailout)
{
	CVector3 z = pos;
	float dr = 1.0f;
	float r = 0.0f;

	for (int i = 0; i < Iterations; i++)
	{
		r = z.Magnitude();
		if (r > bailout)
			break;

		// convert to polar coordinates
		float theta = acos(z.y / r);
		float phi = atanf(z.z / z.x);
		dr = pow(r, power - 1.0f) * power * dr + 1.0f;

		// scale and rotate the point
		float zr = pow(r, power);
		theta = theta * power;
		phi = phi * power;

		// convert back to cartesian coordinates
		z = CVector3(sin(theta) * cos(phi), cos(theta), sin(phi) * sin(theta)) * zr;
		z = z + pos;
	}

	return 0.5f * log(r) * r / dr;
}

// Menger Sponge
// https://github.com/Angramme/fractal_viewer/blob/master/fractals/menger_sponge.glsl

__device__ float Truncate(float x, float t, float s)
{
	if (abs(x) < s * 0.5f && abs(x) <= t) 
		return 0.0f;

	return x > 0.0f ? s : -s;
}

__device__ float MengerSponge(CVector3 p, int n, float scale)
{
	p = p * 1.5f;

	for (int i = 0; i < n; i++)
	{
		CVector3 ap = p.Absolute();
		float mid = fmin(ap.x, fmin(ap.y, ap.z));

		CVector3 boxP = CVector3(
			Truncate(p.x, mid, scale),
			Truncate(p.y, mid, scale),
			Truncate(p.z, mid, scale)
		);

		p = p - boxP;
		scale *= 0.33333333333333f;
	}

	scale *= 3.0f;

	return (SDF_Box(p, CVector3(scale, scale, scale))) / 1.5f;
}

__device__ float MengerSponge(CVector3 p, int n)
{
	return MengerSponge(p, n, 1.0f);
}