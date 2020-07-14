#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <vector>
#include <random>
#include <fstream>
#include <time.h>

using namespace std;

//prepare test data
#define IMAGE_PATH "mnist\\train-images.idx3-ubyte"
#define LABEL_PATH "mnist\\train-labels.idx1-ubyte"

#define BIAS_WEIGHT_PATH "mnist\\biasweight.txt" //learned data

#define IMAGE_HEADER_SIZE 16
#define LABEL_HEADER_SIZE 8

#define TOTAL_SIZE 100 // <= 60000
#define MINI_BATCH_SIZE 100 // <= TOTAL_IMG_SIZE

#define INPUT_SIZE 784
//~prepare test data

#define LEARN_COUNT 10

enum layer_type { AFF, CONV, POOLING };

void read_image_label();
void mini_batch(int n, int count);

__global__ void update_delta(int n, float* weight, float* delta, float lr);
__global__ void add_bias(int n, float* a, float* bias);
__global__ void add_bias_array(int n, float* a, float* bias);
__global__ void relu(int n, float* a);
__global__ void relu_backward(float* dy, float* y, int m, int n);
__global__ void pooling(float* a, int m, int n, float* b);
__global__ void pooling_backward(float* d, float* a, int m, float* b, int n, float* c);
__global__ void matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res);
__global__ void matrix_convolution_multiplication(float* a, int m, float* b, int n, float* c);
__global__ void matrix_transpose(float* a, int m, int n, float* b);
__global__ void matrix_reverse(float* a, float* b, int n);
__global__ void make_padding_matrix(float* a, int n, float* b, int p);
__global__ void set_weight_changes(float* ws, float* wds, int h, int w, float lr);
__global__ void set_bias_changes(float* bs, float* bds, int n, float lr);
__global__ void batch_norm(float* a, float avg, float disp, float g, float b);

class layer {
public:
	layer_type type;
	float* data;
	float* weight;
	float* bias = 0;

	float* data_grad;
	float* weight_grad;
	float* bias_grad;

	int data_size = 0;
	int weight_size = 0;
	int x;
	int y;
	int z;
	int w;

	float lr = 0.1;

	//batch_normalization
	float dst_avg = 0;
	float dst_dist = 1;
	float g = 1;
	float dg = 0;
	float b = 0;
	float db = 0;

	//output
	float* output_1;
	float* output_2;
	float* output_dev;
	float* answer;
	float* output_grad;

	layer(layer_type type, int x, int y, int z, int w) {
		this->type = type;
		this->x = x;
		this->y = y;
		this->z = z;
		this->w = w;
		this->data_size = x * y;
		this->weight_size = z * w;

		cudaError_t error;

		error = cudaMalloc((void**)&data, data_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMemset(data, 0, data_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMalloc((void**)&data_grad, data_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMemset(data_grad, 0, data_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMalloc((void**)&weight, weight_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMemset(weight, 0, weight_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMalloc((void**)&weight_grad, weight_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMemset(weight_grad, 0, weight_size * sizeof(float));
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		int bias_size;

		if (type == AFF) {
			bias_size = data_size * sizeof(float);
		}
		else if (type == CONV) {
			bias_size = sizeof(float);
		}
		else if (type == POOLING) {
			bias_size = 0;
		}

		error = cudaMalloc((void**)&bias, bias_size);
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMemset(bias, 0, bias_size);
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMalloc((void**)&bias_grad, bias_size);
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}

		error = cudaMemset(bias_grad, 0, bias_size);
		if (error != cudaSuccess) {
			throw exception(cudaGetErrorString(error));
		}
	}

	void set_data(float* data, int size) {
		if (this->data_size != size) {
			throw exception("Size not match");
		}
		cudaError_t error = cudaMemcpy(this->data, data, size * sizeof(float), cudaMemcpyDeviceToDevice);
		if (error != cudaSuccess) {
			cout << "set_data error" << endl;
			throw exception(cudaGetErrorString(error));
		}
	}

	void generate_weight(float mean, float dist) {
		normal_distribution<float> distribution(mean, dist);
		default_random_engine generator;
		generator.seed(rand());
		float* weight_gen = new float[weight_size];
		for (int i = 0; i < weight_size; i++) {
			weight_gen[i] = distribution(generator);
		}
		cudaError_t error = cudaMemcpy(weight, weight_gen, weight_size * sizeof(float), cudaMemcpyHostToDevice);
		if (error != cudaSuccess) {
			cout << "generate_weight error" << endl;
			throw exception(cudaGetErrorString(error));
		}
	}

	void change_weight(float* changes, float lr) {
		update_delta << <this->z, this->w >> > (weight_size, weight, changes, lr);
		cudaError_t error = cudaDeviceSynchronize();
		if (error != cudaSuccess) {
			cout << "error occured" << endl;
			throw exception(cudaGetErrorString(error));
		}
	}

	void change_bias(float* changes, float lr) {
		int bias_size;
		if (this->type == AFF) {
			bias_size = data_size;
		}
		else if (this->type == CONV) {
			bias_size = 1;
		}
		update_delta << <1, bias_size >> > (1, bias, changes, lr);
		cudaError_t error = cudaDeviceSynchronize();
		if (error != cudaSuccess) {
			cout << "error occured" << endl;
			throw exception(cudaGetErrorString(error));
		}
	}

	void forward(float* dst) {
		cudaError_t error;
		if (this->type == AFF) {
			matrix_multiplication << <1, w >> > (data, this->x, this->y, weight, this->z, this->w, dst);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			add_bias_array << <1, y >> > (y, dst, bias);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			//batchn			
			set_avg_dist(dst, w);
			batch_norm << <1, w >> > (dst, dst_avg, dst_dist, g, b);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
			//~batchn

			relu << <1, y >> > (y, dst);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
		}
		else if (this->type == CONV) {
			int dst_width = x - z + 1;
			matrix_convolution_multiplication << <dst_width, dst_width >> > (data, x, weight, z, dst);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			add_bias << <dst_width, dst_width >> > (dst_width, dst, bias);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			//batchn
			int dst_size = dst_width * dst_width;
			set_avg_dist(dst, dst_size);
			batch_norm << <1, dst_size >> > (dst, dst_avg, dst_dist, g, b);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
			//~batchn

			relu << <dst_width, dst_width >> > (dst_width, dst);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
		}
		else if (this->type == POOLING) {
			int pooling_size = x / z;
			pooling << <pooling_size, pooling_size >> > (data, x, z, dst);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}
		}
	}

	void backward(float* delta, float* _data = nullptr) {
		cudaError_t error;
		if (this->type == AFF) {
			relu_backward << <this->x, this->y >> > (data_grad, data, x, y);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			batch_norm_backward(data_grad, _data, w);

			float* weight_trans;
			error = cudaMalloc((void**)&weight_trans, weight_size * sizeof(float));
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			matrix_transpose << <z, w >> > (weight, z, w, weight_trans);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			matrix_multiplication << <1, data_size >> > (delta, 1, w, weight_trans, w, z, data_grad);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			matrix_multiplication << <z, w >> > (data, y, 1, delta, 1, w, weight_grad);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			set_weight_changes << <z, w >> > (weight, weight_grad, z, w, this->lr);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			set_bias_changes << <1, y >> > (bias, delta, w, this->lr);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			error = cudaFree(weight_trans);
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
		}
		else if (this->type == CONV) {
			relu_backward << <this->x, this->y >> > (data_grad, data, x, y);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
			
			int delta_width = x - z + 1;
			int delta_size = delta_width * delta_width;
			float* delta_host = new float[delta_size];
			batch_norm_backward(data_grad, _data, delta_size);

			//1. get weight grad
			error = cudaMemcpy(delta_host, delta, delta_size * sizeof(float), cudaMemcpyDeviceToHost);
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			float bias_host = 0;
			for (int i = 0; i < delta_size; i++) {
				bias_host += delta_host[i];
			}
			error = cudaMemcpy(bias_grad, &bias_host, sizeof(float), cudaMemcpyHostToDevice);
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			matrix_convolution_multiplication << <z, w >> > (data, x, delta, delta_width, weight_grad);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			//2. apply changes
			set_weight_changes << <z, w >> > (weight, weight_grad, z, w, this->lr);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			//3. perpare padding matrix
			int padding_matrix_width = delta_width + 2 * (z - 1);
			int padding_matrix_size = padding_matrix_width * padding_matrix_width;
			float* padding_matrix;
			error = cudaMalloc((void**)&padding_matrix, padding_matrix_size * sizeof(float));
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			error = cudaMemset(padding_matrix, 0, padding_matrix_size * sizeof(float));
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			make_padding_matrix << <delta_width, delta_width >> > (delta, delta_width, padding_matrix, z - 1);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			//4. prepare reverse matrix
			float* weight_reverse_matrix;
			error = cudaMalloc((void**)&weight_reverse_matrix, weight_size * sizeof(float));
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			matrix_reverse << <z, w >> > (weight, weight_reverse_matrix, z);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			//5. cnn 3 and 4
			matrix_convolution_multiplication << <x, x >> > (padding_matrix, padding_matrix_width, weight_reverse_matrix, z, data_grad);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
		}
		else if (this->type == POOLING) {
			int pooling_size = x / z;
			pooling_backward << <x, y >> > (delta, _data, pooling_size, data, x, weight);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
		}
	}

	void set_result() {

		if (this->type == AFF) {
			cudaError_t error;			
			cudaMalloc((void**)&output_dev, data_size * sizeof(float));
			matrix_multiplication << <1, w >> > (data, this->x, this->y, weight, this->z, this->w, output_dev);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			add_bias_array << <1, y >> > (y, output_dev, bias);
			error = cudaDeviceSynchronize();
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			int output_size = w;
			output_1 = new float[output_size];
			output_2 = new float[output_size];
			error = cudaMemcpy(output_1, output_dev, output_size * sizeof(float), cudaMemcpyDeviceToHost);
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}

			softmax(output_1, output_2, output_size);

			error = cudaMemcpy(output_dev, output_2, output_size * sizeof(float), cudaMemcpyHostToDevice);
			if (error != cudaSuccess) {
				cout << "error occured" << endl;
				throw exception(cudaGetErrorString(error));
			}
		}
		else {
			throw exception("Only affine layer gets result");
		}
	}

	void set_answer(float* answer) {
		this->answer = answer;
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

	float cross_entrophy_error() {
		float res = 0;
		int i, output_size = w;

		for (i = 0; i < output_size; i++) {
			res += answer[i] * log(output_2[i] + 1e-7);
		}

		return -res;
	}

	void result_backward() {
		int result_size = w;
		cudaError_t error = cudaMalloc((void**)&output_grad, result_size * sizeof(float));
		if (error != cudaSuccess) {
			cout << "error occured" << endl;
			throw exception(cudaGetErrorString(error));
		}

		float* dy = new float[result_size];
		for (int i = 0; i < result_size; i++) {
			dy[i] = output_2[i] - answer[i];
		}
		cudaMemcpy(output_grad, dy, result_size * sizeof(float), cudaMemcpyHostToDevice);
	}

	void set_avg_dist(float* dst, int size) {
		float* data_host = new float[size];
		cudaError_t error = cudaMemcpy(data_host, dst, size * sizeof(float), cudaMemcpyDeviceToHost);

		dst_avg = 0;
		for (int i = 0; i < size; i++) {
			dst_avg += data_host[i];
		}
		dst_avg /= size;

		dst_dist = 1;
		for (int i = 0; i < size; i++) {
			float tmp = data_host[i] - dst_avg;
			dst_dist += tmp * tmp;
		}
		dst_dist /= size;

		delete data_host;
	}

	void batch_norm_backward(float* delta, float* _data, int size) {
		cudaError_t error;
		int i, j, k;

		float* delta_host = new float[size];
		error = cudaMemcpy(delta_host, delta, size * sizeof(float), cudaMemcpyDeviceToHost);
		if (error != cudaSuccess) {
			cout << "error occured" << endl;
			throw exception(cudaGetErrorString(error));
		}

		float* data_host = new float[size];
		error = cudaMemcpy(data_host, _data, size * sizeof(float), cudaMemcpyDeviceToHost);
		if (error != cudaSuccess) {
			cout << "error occured" << endl;
			throw exception(cudaGetErrorString(error));
		}

		db = 0;
		for (i = 0; i < size; i++) {
			db += delta_host[i];
		}

		dg = 0;
		for (i = 0; i < size; i++) {
			dg += (data_host[i] - b) / g * delta_host[i];
		}

		float* dxu1 = new float[size];
		float* divar = new float[size]; //ivar = dist^2 - 10e-7
		float ivar = 1 / sqrt(dst_dist * dst_dist - 10e-7);
		for (i = 0; i < size; i++) {
			dxu1[i] = delta_host[i] * ivar;
			divar[i] = delta_host[i] * (data_host[i] - dst_avg);
		}

		float* dsqrtvar = new float[size];
		float sqrtvar = 1 / ivar;
		for (i = 0; i < size; i++) {
			dsqrtvar[i] = divar[i] * (-1 / sqrtvar * sqrtvar);
		}

		float* dvar = new float[size];
		float var = dst_dist * dst_dist;
		for (i = 0; i < size; i++) {
			dvar[i] = 0.5 * dsqrtvar[i] / sqrt(var + 10e-7);
		}

		float* dsq = new float[size];
		for (i = 0; i < size; i++) {
			dsq[i] = dvar[i];
		}

		float* dxu2 = new float[size];
		float xu = dst_dist;
		for (i = 0; i < size; i++) {
			dxu2[i] = 2 * xu * dsq[i];
		}

		float* dx1 = new float[size];
		float* du = new float[size];
		for (i = 0; i < size; i++) {
			dx1[i] = dxu1[i] + dxu2[i];
			du[i] = -dx1[i];
		}

		float* dx2 = new float[size];
		for (i = 0; i < size; i++) {
			dx2[i] = du[i];
		}

		float* dx = new float[size];
		for (i = 0; i < size; i++) {
			dx[i] = dx1[i] + dx2[i];
		}

		for (i = 0; i < size; i++) {
			delta_host[i] = dx[i];
		}

		error = cudaMemcpy(delta, delta_host, size * sizeof(float), cudaMemcpyHostToDevice);
		if (error != cudaSuccess) {
			cout << "error occured" << endl;
			throw exception(cudaGetErrorString(error));
		}

		b += db * lr;
		g += dg * lr;

		delete delta_host;
		delete data_host;
		delete dxu1;
		delete divar;
		delete dsqrtvar;
		delete dvar;
		delete dsq;
		delete dxu2;
		delete dx1;
		delete du;
		delete dx2;
		delete dx;
	}

	void print_data(int lb = 10, bool grad = 0) {
		float* tmp = new float[data_size];
		cudaError_t error;
		if (grad) {
			error = cudaMemcpy(tmp, data_grad, data_size * sizeof(float), cudaMemcpyDeviceToHost);
		}
		else {
			error = cudaMemcpy(tmp, data, data_size * sizeof(float), cudaMemcpyDeviceToHost);
		}

		if (error != cudaSuccess) {
			cout << "print_data copy failed" << endl;
			throw exception(cudaGetErrorString(error));
		}

		printf("%d items\n", data_size);
		printf("----------------------------------------------------------------------------------------------------\n");
		for (int i = 0; i < data_size; i++) {
			if (i % lb == 0 && i != 0) {
				printf("(%d)\n", i);
			}
			printf("%.4f ", tmp[i]);
		}
		printf("(%d)\n----------------------------------------------------------------------------------------------------\n", data_size);
		delete tmp;
	}

	void print_weight(int lb = 10, bool grad = 0) {
		float* tmp = new float[weight_size];
		cudaError_t error;
		if (grad) {
			error = cudaMemcpy(tmp, weight_grad, weight_size * sizeof(float), cudaMemcpyDeviceToHost);
		}
		else {
			error = cudaMemcpy(tmp, weight, weight_size * sizeof(float), cudaMemcpyDeviceToHost);
		}

		if (error != cudaSuccess) {
			cout << "print_weight copy failed" << endl;
			throw exception(cudaGetErrorString(error));
		}

		printf("%d items\n", weight_size);
		printf("----------------------------------------------------------------------------------------------------\n");
		for (int i = 0; i < weight_size; i++) {
			if (i % lb == 0 && i != 0) {
				printf("(%d)\n", i);
			}
			printf("%.4f ", tmp[i]);
		}
		printf("(%d)\n----------------------------------------------------------------------------------------------------\n", weight_size);
		delete tmp;
	}
};

//variables
vector<float*>* images;
vector<int>* labels;
vector<int>* mbatch;

int main()
{
	srand(static_cast<unsigned int>(time(NULL)));
	read_image_label();

	//input(784 - 28 * 28) - conv(5 - 24 * 24) - conv(5 - 20 * 20) - aff(400 * 100 - 1 * 100) - aff(100 * 10 - 1 * 10) - result

	int i, j, k;
	layer* input = new layer(CONV, 28, 28, 5, 5);
	input->generate_weight(0.5, sqrt(2 / 50.0));
	layer* conv1 = new layer(CONV, 24, 24, 5, 5);
	conv1->generate_weight(0.5, sqrt(2 / 50.0));

	//layer* aff1 = new layer(AFF, 1, 400, 400, 100);
	//aff1->generate_weight(0.5, sqrt(1 / 50.0));
	layer* pool1 = new layer(POOLING, 20, 20, 2, 2);

	layer* output = new layer(AFF, 1, 100, 100, 10);
	output->generate_weight(0.5, sqrt(1 / 50.0));

	float* answer;
	float cross_entrophy_error;
	for (i = 0; i < images->size(); i++) {
		input->set_data(images->at(i), 784); //set input

		//set answer
		answer = new float[10];
		memset(answer, 0, 10 * sizeof(float));
		answer[labels->at(i)] = 1;
		output->set_answer(answer);
		//~set answer

		for (j = 0; j < LEARN_COUNT; j++) {
			//predict
			input->forward(conv1->data);
			//input->print_data(28);

			//conv1->forward(aff1->data);
			//aff1->forward(output->data);
			conv1->forward(pool1->data);
			//conv1->print_data(24);

			pool1->forward(output->data);
			//pool1->print_data(20);

			output->set_result();
			//output->print_data();

			//for (k = 0; k < 10; k++) {
			//	cout << output->output_1[k] << ' ';
			//}
			//cout << endl;

			//for (k = 0; k < 10; k++) {
			//	cout << output->output_2[k] << ' ';
			//}
			//cout << endl;

			if (j == 0) {
				cross_entrophy_error = output->cross_entrophy_error();
				cout << i << " - cross entrophy error : " << cross_entrophy_error;
			}
			else if (j == LEARN_COUNT - 1) {
				cross_entrophy_error = output->cross_entrophy_error();
				cout << " to " << cross_entrophy_error << endl;
			}
			//~predict		

			output->result_backward();
			output->backward(output->output_grad, output->output_dev);
			//output->print_weight(10, 1);
			//output->print_weight(10, 0);

			//aff1->backward(output->data_grad);
			//aff1->print_weight(10, 1);

			pool1->backward(output->data_grad, output->data);

			//conv1->backward(aff1->data_grad);
			conv1->backward(pool1->data_grad, pool1->data);
			//conv1->print_weight(10, 0);
			//conv1->print_weight(10, 1);

			input->backward(conv1->data_grad, conv1->data);
			//input->print_weight(10, 0);
			//input->print_weight(10, 1);
		}
	}

	mini_batch(TOTAL_SIZE, MINI_BATCH_SIZE);
	int correct = 0;

	for (i = 0; i < mbatch->size(); i++) {
		input->set_data(images->at(mbatch->at(i)), 784); //set input
		input->forward(conv1->data);
		conv1->forward(pool1->data);
		pool1->forward(output->data);
		output->set_result();
		float max = 0;
		int max_idx = -1;
		for (j = 0; j < 10; j++) {
			if (output->output_2[j] > max) {
				max = output->output_2[j];
				max_idx = j;
			}
		}
		cout << "predict : " << max_idx << " answer : " << labels->at(mbatch->at(i)) << endl;
		if (labels->at(mbatch->at(i)) == max_idx) {
			correct++;
		}
	}
	float total = TOTAL_SIZE;
	cout << "accuracy : " << correct / total * 100 << '%' << endl;

	cudaDeviceReset();

	return 0;
}

void read_image_label() {
	images = new vector<float*>();
	labels = new vector<int>();

	int header = 0, row = 0, col = 0, n, m, i = 0, j = 0, k = 0, l = 0, count = 0;

	//read image
	ifstream input_image(IMAGE_PATH, ios::binary);
	vector<char> bytes_i;
	char headerbuffer[IMAGE_HEADER_SIZE];
	input_image.read(headerbuffer, IMAGE_HEADER_SIZE);
	for (j = 0; j < IMAGE_HEADER_SIZE; j++) {
		bytes_i.push_back(headerbuffer[j]);
	}

	for (j = 0; j < TOTAL_SIZE; j++) {
		char* imagebuffer = new char[INPUT_SIZE];
		input_image.read(imagebuffer, INPUT_SIZE);
		for (k = 0; k < INPUT_SIZE; k++) {
			bytes_i.push_back(imagebuffer[k]);
		}
	}

	//read label
	ifstream input_label(LABEL_PATH, ios::binary);
	vector<char> bytes_l;
	char labelbuffer[LABEL_HEADER_SIZE + TOTAL_SIZE];
	input_label.read(labelbuffer, LABEL_HEADER_SIZE + TOTAL_SIZE);
	for (j = 0; j < LABEL_HEADER_SIZE + TOTAL_SIZE; j++) {
		bytes_l.push_back(labelbuffer[j]);
	}

	n = bytes_i.size();
	m = bytes_l.size();

	cout << "image header : ";
	for (j = 0; j < IMAGE_HEADER_SIZE; j++) {
		cout << (int)(unsigned char)bytes_i[i++] << ' ';
	}
	cout << endl;

	cout << "label header : ";
	for (j = 0; j < LABEL_HEADER_SIZE; j++) {
		cout << (int)(unsigned char)bytes_l[l++] << ' ';
	}
	cout << endl;

	float* img;
	while (i < n && l < m && count < TOTAL_SIZE) {
		labels->push_back((int)(unsigned char)bytes_l[l++]);
		img = new float[INPUT_SIZE];

		for (j = 0; j < INPUT_SIZE; j++) {
			img[j] = (float)(unsigned char)bytes_i[i++] / 256.0;
		}
		float* imgDev;
		cudaMalloc((void**)&imgDev, INPUT_SIZE * sizeof(float));
		cudaMemcpy(imgDev, img, INPUT_SIZE * sizeof(float), cudaMemcpyHostToDevice);
		images->push_back(imgDev);
		count++;
	}

	cout << images->size() << " images" << endl;

	input_image.close();
	input_label.close();
}

void mini_batch(int n, int count) {
	int i, x;
	mbatch = new vector<int>();
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
}



//n : col count ( thread count )
__global__ void update_delta(int n, float* weight, float* delta, float lr) {
	int idx = blockIdx.x * n + threadIdx.x;
	weight[idx] -= lr * delta[idx];
}

__global__ void add_bias(int n, float* a, float* bias) {
	int idx = blockIdx.x * n + threadIdx.x;	
	a[idx] += *bias;
}

__global__ void add_bias_array(int n, float* a, float* bias) {
	int idx = blockIdx.x * n + threadIdx.x;
	a[idx] += bias[idx];
}

__global__ void relu(int n, float* a) {
	int idx = blockIdx.x * n + threadIdx.x;
	if (a[idx] < 0) a[idx] = 0;
}

__global__ void relu_backward(float* dy, float* y, int m, int n) {
	int i = blockIdx.x, j = threadIdx.x, seq = n * i + j;
	dy[seq] *= y[seq] < 0 ? 0 : 1;
}

__global__ void pooling(float* a, int m, int n, float* b) {
	int bl = blockIdx.x, th = threadIdx.x;
	int bs = bl * n, ts = th * n, rs = bl * (m / n) + th, tmp;
	int i, j;
	b[rs] = 0;
	for (i = bs; i < bs + n; i++) {
		for (j = ts; j < ts + n; j++) {
			tmp = i * m + j;
			b[rs] = a[tmp] > b[rs] ? a[tmp] : b[rs];
		}
	}
}

//d : delta, a : pooling data, m : pooling size, b : cnn data, n : cnn size, c : pooling backward result
__global__ void pooling_backward(float* d, float* a, int m, float* b, int n, float* c) {
	int bl = blockIdx.x, th = threadIdx.x;
	int cnnIdx = bl * n + th;
	int poolIdx = (bl / 2) * m + (th / 2);
	c[cnnIdx] = a[poolIdx] == b[cnnIdx] ? d[poolIdx] : 0;
}

//<<<m, p>>> matrix, {n == o} (m x n) x (o x p) = (m x p)
__global__ void matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res) {
	int bi = blockIdx.x, ti = threadIdx.x, sb = bi * n, st = ti, c = bi * p + ti, i;
	res[c] = 0;
	for (i = 0; i < n; i++) {
		res[c] += a[sb + i] * b[st];
		st += p;
	}
}

//<<<m - n + 1, m - n + 1>>>
__global__ void matrix_convolution_multiplication(float* a, int m, float* b, int n, float* c) {
	int bl = blockIdx.x, th = threadIdx.x;
	int o = m - n + 1, p = bl * o + th;
	int i, j;
	c[p] = 0;
	for (i = bl; i < bl + n; i++) {
		for (j = th; j < th + n; j++) {
			c[p] += a[i * m + j] * b[(i - bl) * n + (j - th)];
		}
	}
}

__global__ void matrix_transpose(float* a, int m, int n, float* b) {
	int j = blockIdx.x;
	int i = threadIdx.x;
	b[i * m + j] = a[j * n + i];
}

__global__ void matrix_reverse(float* a, float* b, int n) {
	int bl = blockIdx.x, th = threadIdx.x;
	int idx = bl * n + th;
	int ridx = (n - bl - 1) * n + (n - th - 1);
	b[idx] = a[ridx];
}

__global__ void make_padding_matrix(float* a, int n, float* b, int p) {
	int bl = blockIdx.x, th = threadIdx.x;
	int idx = bl * n + th;
	int pad_width = n + 2 * p;
	int pad_bl = p - 1 + bl, pad_th = p - 1 + th;
	int pad_idx = pad_bl * pad_width + pad_th;
	b[pad_idx] = a[idx];
}

__global__ void set_weight_changes(float* ws, float* wds, int h, int w, float lr) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	int seq = bx * w + tx;
	ws[seq] -= wds[seq] * lr;
}

__global__ void set_bias_changes(float* bs, float* bds, int n, float lr) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	bs[tx] -= bds[tx] * lr;
}

__global__ void batch_norm(float* a, float avg, float disp, float g, float b) {
	int i = threadIdx.x;
	a[i] = g * ((a[i] - avg) / sqrt(disp * disp + 10e-7)) + b;
}