#pragma once

#include <math.h>
#include <CVector.cuh>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

// ***************************************************
// Primitives

// Primitives code source: https://iquilezles.org/articles/distfunctions/

// Primitive cube
__device__ float SDF_Box(CVector3 point, CVector3 boxPos, CVector3 scale);
__device__ float SDF_Box(CVector3 point, CVector3 scale);

// Primitive spheres
__device__ float SDF_Sphere(CVector3 point, CVector3 spherePos, float radius);
__device__ float SDF_Sphere(CVector3 point, float radius); // Assume sphere position = X:0 Y:0 Z:0
__device__ float R_SDF_Sphere(CVector3 point, float radius, float repeat); // Infinite repetition

// Tetrahedron
// https://www.shadertoy.com/view/Ws23zt
__device__ float SDF_Tetrahedron(CVector3 point); // Assume object position = X:0 Y:0 Z:0

// Infinite plane
__device__ float SDF_Plane(CVector3 point);



// ***************************************************
// Fractals

// Sierpinski Tetrahedron
// https://www.shadertoy.com/view/wsVBz1
// Fold a point across a plane defined by a point and a normal. The normal should face the side to be reflected
__device__ CVector3 Fold(CVector3 point, CVector3 pointOnPlane, CVector3 planeNormal);
__device__ float SDF_Sierpinski(CVector3 point, int level);

// Mandelbulb
// http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/
__device__ float Mandelbulb(CVector3 pos, int Iterations, float power, float bailout);

// Menger Sponge
// https://github.com/Angramme/fractal_viewer/blob/master/fractals/menger_sponge.glsl
__device__ float MengerSponge(CVector3 p, int n);
__device__ float MengerSponge(CVector3 p, int n, float scale);