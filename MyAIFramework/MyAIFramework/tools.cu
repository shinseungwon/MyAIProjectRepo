#include "tools.cuh"

using namespace std;

float* mal_cpy_dev(float* data, int size) {
	float* res = mal_dev(size);
	cpy_dev(res, data, size);
	return res;
}

float* mal_cpy_host(float* data, int size) {
	float* res = new float[size];
	cpy_host(res, data, size);
	return res;
}

float* mal_dev(int size) {
	float* res;

	cudaError_t error;
	error = cudaMalloc((void**)&res, size * sizeof(float));
	if (error != cudaSuccess) {
		throw new exception("Cuda Malloc Failed");
	}

	error = cudaMemset(res, 0, size * sizeof(float));
	if (error != cudaSuccess) {
		throw new exception("Cuda Memset Failed");
	}

	return res;
}

void free_dev(float* data) {
	cudaError_t error;
	error = cudaFree(data);
	if (error != cudaSuccess) {
		throw new exception("Cuda Free Failed");
	}
}

void cpy_host(float* dst, float* src, int size) {
	cudaError_t error;
	error = cudaMemcpy(dst, src, size * sizeof(float), cudaMemcpyDeviceToHost);
	if (error != cudaSuccess) {
		throw new exception("Cuda Memcpy Failed");
	}
}

void cpy_dev(float* dst, float* src, int size) {
	cudaError_t error;
	error = cudaMemcpy(dst, src, size * sizeof(float), cudaMemcpyHostToDevice);
	if (error != cudaSuccess) {
		throw new exception("Cuda Memcpy Failed");
	}
}

void cpy_dev_to_dev(float* dst, float* src, int size) {
	cudaError_t error;
	error = cudaMemcpy(dst, src, size * sizeof(float), cudaMemcpyDeviceToDevice);
	if (error != cudaSuccess) {
		throw new exception("Cuda Memcpy Failed");
	}
}

void generate_weight(float* weight, int size, float mean, float dist) {
	normal_distribution<float> distribution(mean, dist);
	default_random_engine generator;
	generator.seed(rand());
	float* weight_gen = new float[size];
	for (int i = 0; i < size; i++) {
		weight_gen[i] = distribution(generator);
	}
	cpy_dev(weight, weight_gen, size);
}

//<<<m, p>>> matrix, {n == o} (m x n) x (o x p) = (m x p)
void matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res) {

	if (res == nullptr) {
		res = mal_dev(m * p);
	}

	k_matrix_multiplication << <m, p >> > (a, m, n, b, o, p, res);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		throw new exception("Function 'matrix_multiplication' Failed");
	}
}

void matrix_convolution_multiplication(float* a, int m, float* b, int n, float* c) {
	int dst_width = m - n + 1;
	k_matrix_convolution_multiplication<<<dst_width, dst_width>>>(a, m, b, n, c);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		throw new exception("Function 'matrix_convolution_multiplication' Failed");
	}
}

void matrix_transpose(float* a, int m, int n, float* b) {
	k_matrix_transpose<<<m, n>>>(a, m, n, b);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		throw new exception("Function 'matrix_transpose' Failed");
	}
}

void matrix_reverse(float* a, float* b, int m, int n) {
	k_matrix_reverse<<<n, m>>>(a, b, m);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		throw new exception("Function 'matrix_reverse' Failed");
	}
}

void make_padding_matrix(float* a, int n, float* b, int p) {
	k_make_padding_matrix<<<n, n>>>(a, n, b, p);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		throw new exception("Function 'make_padding_matrix' Failed");
	}
}

void update_delta(float* weight, float* changes, int w, int h, float lr) {
	k_update_delta<<<w, h>>>(weight, changes, w, lr);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'update_delta' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void add_bias(int n, float* dst, float* bias) {
	k_add_bias<<<1, n>>>(n, dst, bias);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'add_bias' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void add_bias_array(int n, float* dst, float* bias) {
	k_add_bias_array<<<1, n>>>(n, dst, bias);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'add_bias_array' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void relu(int n, float* a) {
	k_relu<<<1, n>>>(n, a);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'relu' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void relu_backward(float* dy, float* y, int m, int n) {
	k_relu_backward<<<m, n>>>(dy, y, m, n);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'relu_backward' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void pooling(float* a, int m, int n, float* b) {
	int pooling_size = m / n;
	k_pooling<<<pooling_size, pooling_size>>>(a, m, n, b);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'pooling' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void pooling_backward(float* d, float* a, int m, float* b, int n, float* c) {
	k_pooling_backward<<<n, n>>>(d, a, m, b, n, c);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'pooling_backward' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void get_dist_worker(int size, float avg, float* data, float* data_sub_avg, float* data_sub_avg_sq) {
	//Æò±Õ »©ÁÖ°í Á¦°ö ÇØÁÖ°í
	k_get_dist_worker<<<1, size>>>(size, avg, data, data_sub_avg, data_sub_avg_sq);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'get_dist_worker' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void batch_norm_worker(int size
	, float* data
	, float* data_sub_avg
	, float* data_sub_avg_sq
	, float* data_caret
	, float* data_caret_mul_g
	, float* data_caret_mul_g_add_b
	, float avg, float dist, float g, float b) {
	float dist_sqrt = sqrt(dist + 10e-7);
	k_batch_norm_worker<<<1, size>>>(size, data_sub_avg, data_caret, data_caret_mul_g, data_caret_mul_g_add_b, dist_sqrt, g, b);
}

void batch_norm(float* a, int size, float avg, float disp, float g, float b) {
	k_batch_norm<<<1, size>>>(a, avg, disp, g, b);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'batch_norm' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void dropout(float* data, float* mask, int size) {
	k_dropout<<<1, size>>>(data, mask);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'dropout' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void softmax(float* a, float* b, int n) {
	int i;
	float max = 0, expsum = 0;
	for (i = 0; i < n; i++) {
		if (a[i] > max) {
			max = a[i];
		}
		b[i] = a[i];
	}
	for (i = 0; i < n; i++) {
		b[i] -= max;
		expsum += exp(b[i]);
	}

	for (i = 0; i < n; i++) {
		b[i] = exp(b[i]) / expsum;
	}
}

float get_cross_entrophy_error(float* answer, float* output, int size) {
	float res = 0;
	int i;

	for (i = 0; i < size; i++) {
		res += answer[i] * log(output[i] + 1e-7);
	}

	return -res;
}

int* mini_batch(int n, int count) {
	int i, x;
	vector<int>* mbatch = new vector<int>();
	int* arr = new int[n];
	for (i = 0; i < n; i++) {
		arr[i] = i;
	}
	for (i = n; i > n - count; i--) {
		x = rand() % i;
		mbatch->push_back(arr[x]);
		arr[x] = arr[i - 1];
	}
	delete[] arr;
	return &mbatch->at(0);
}

float* mini_batch_mask(int n, int count) {
	int i;
	float* res = new float[n];
	for (i = 0; i < n; i++) {
		res[i] = 1;
	}
	
	int* mbatch = mini_batch(n, count);
	for (int i = 0; i < count; i++) {
		res[mbatch[i]] = 0;		
	}
	return res;
}

void print(char* title, float* data, int size, int width) {
	float* tmp = new float[size];
	cpy_host(tmp, data, size);

	printf("%s (%d items)\n", title, size);
	printf("----------------------------------------------------------------------------------------------------\n");
	for (int i = 0; i < size; i++) {
		if (i % width == 0 && i != 0) {
			printf("(%d)\n", i);
		}
		printf("%.4f ", tmp[i]);
	}
	printf("(%d)\n----------------------------------------------------------------------------------------------------\n", size);
	delete[] tmp;
}

void set_weight_changes(float* weight, float* weight_grad, int h, int w, float lr) {
	k_set_weight_changes<<<h, w>>>(weight, weight_grad, h, w, lr);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'set_weight_changes' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}

void set_bias_changes(float* bias, float* bias_grad, int n, float lr) {
	k_set_bias_changes<<<1, n>>>(bias, bias_grad, n, lr);
	cudaError_t error = cudaDeviceSynchronize();
	if (error != cudaSuccess) {
		cout << "Function 'set_weight_changes' Failed" << endl;
		throw exception(cudaGetErrorString(error));
	}
}