
#include <CudaFunctions.cuh>

void SendErrorLog(string str)
{
	cout << str << '\n';
}

string CudaGetErrorString(cudaError_t errCode)
{
	return string(cudaGetErrorString(errCode));
}

bool CudaSetDevice()
{
	cudaError_t err = cudaSetDevice(0);

	if (err != cudaSuccess)
		SendErrorLog("cudaSetDevice failed! Do you have a CUDA-capable GPU installed? " + CudaGetErrorString(err));

	return err == cudaSuccess;
}

bool CCudaMalloc(void** devPtr, size_t size)
{
	cudaError_t err = cudaMalloc(devPtr, size);

	if (err != cudaSuccess)
		SendErrorLog("cudaMalloc failed! " + CudaGetErrorString(err));

	return err == cudaSuccess;
}

bool CudaDeviceSynchronize()
{
	cudaError_t err = cudaDeviceSynchronize();

	if (err != cudaSuccess)
		SendErrorLog("cudaDeviceSynchronize failed! " + CudaGetErrorString(err));

	return err == cudaSuccess;
}

bool CudaCopyFromGPU(void* host_ptr, void* gpu_ptr, size_t size)
{
	cudaError_t err = cudaMemcpy(host_ptr, gpu_ptr, size, cudaMemcpyDeviceToHost);

	if (err != cudaSuccess)
		SendErrorLog("cudaMemcpy from device failed! " + CudaGetErrorString(err));

	return err == cudaSuccess;
}

bool CudaCopyToGPU(void* host_ptr, void* gpu_ptr, size_t size)
{
	cudaError_t err = cudaMemcpy(gpu_ptr, host_ptr, size, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
		SendErrorLog("cudaMemcpy to device failed! " + CudaGetErrorString(err));

	return err == cudaSuccess;
}

void CudaErrorCheck()
{
	cudaError_t err = cudaGetLastError();

	if (err == cudaSuccess)
		return;

	SendErrorLog("Cuda error! " + CudaGetErrorString(err));
}