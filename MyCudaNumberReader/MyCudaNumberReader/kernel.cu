#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <stdio.h>
#include <fstream>
#include <vector>
#include <string>
#include <chrono>
#include <random>

using namespace std;

//prepare test data
#define IMAGE_PATH "mnist\\train-images.idx3-ubyte"
#define LABEL_PATH "mnist\\train-labels.idx1-ubyte"

#define BIAS_WEIGHT_PATH "mnist\\biasweight.txt" //learned data

#define IMAGE_HEADER_SIZE 16
#define LABEL_HEADER_SIZE 8

#define TOTAL_SIZE 1000 // <= 60000
#define MINI_BATCH_SIZE 100 // <= TOTAL_IMG_SIZE
//~prepare test data

#define LEVEL_SIZE 3

#define LEARN_COUNT 5
#define LEARN_RATE 0.01 // sigmoid : 0.1, relu : 0.000001

//0 : sigmoid, 1 : relu
#define ACT_FUNCTION 1

#define FILTER_SIZE 25 //5 * 5
#define FILTER_WIDTH 5
#define FILTER_COUNT 2
#define POOLING_SIZE 2

vector<float*>* images;
vector<int>* labels;
vector<int>* mbatch;

float* level[LEVEL_SIZE + 1];
int level_size[LEVEL_SIZE + 1]{ 784, 50, 100, 10 };

float** bss;
float** wss;

float* output;
float* output_dev;

//ann
float* bss_dev[LEVEL_SIZE];
float* wss_dev[LEVEL_SIZE];

float* wsst[LEVEL_SIZE];
float* wssd[LEVEL_SIZE];
float* xssd[LEVEL_SIZE + 1];

//cnn
int cnn_level_size[FILTER_COUNT + 1]{ 28, 24, 20 };
float* cnn[FILTER_COUNT];
float* cnn_w[FILTER_COUNT];
float* cnn_b[FILTER_COUNT];
float* cnn_b_w[FILTER_COUNT];

float* filter_gen[FILTER_COUNT];
float* filter[FILTER_COUNT];
float* df[FILTER_COUNT];
float* fr[FILTER_COUNT];

int pad_df_width;
int pad_df_size;
float* pad_df[FILTER_COUNT];

//for accuracy
int cnt = 0;
int correct = 0;

//cross-entrophy
float cee;
//answer value
int anstmp = 0;
//answer array
float* ans;

//batch-norm
float* avg;
float* disp;

cudaError_t error;

void read_image_label();
void read_bias_weight();
void make_bias_weight();
void make_cnn_filter();

void mini_batch(int n, int count);
void predict(float* image, int label);
void backprop(float* img, int label);
float cross_entropy_error(float* y, float* t, int n);
void print_matrix(float* a, int n, int r, string tag);

__global__ void softmax(float* a, float* b, int n);
__global__ void matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res);
__global__ void bias_sigmoid(float* a, float* bias);
__global__ void bias_relu(float* a, float* bias);
__global__ void sigmoid_backward(float* dy, float* y, int m, int n);
__global__ void relu_backward(float* dy, float* y, int m, int n);
__global__ void relu_cnn(float* a, int n, float* bias);
__global__ void set_weight_changes(float* ws, float* wds, int h, int w);
__global__ void set_bias_changes(float* bs, float* bds, int n);
__global__ void matrix_transpose(float* a, int m, int n, float* b);
__global__ void batch_norm(float* a, int n, float* avg, float* disp);
__global__ void batch_norm_set(float* a, float* avg, float* disp, float g, float b);
__global__ void matrix_reverse(float* a, float* b, int n);
__global__ void matrix_convolution_multiplication(float* a, int m, float* b, int n, float* c);
__global__ void cnnPooling(float* a, int m, int n, float* b);
__global__ void pooling_backward(float* d, float* a, int m, float* b, int n, float* c);
__global__ void set_filter_changes(float* f, float* df, int n);
__global__ void make_padding_matrix(float* a, int n, float* b, int p);
__global__ void set_cnn_bias(float* a, int n, float* bias);
__global__ void set_cnn_bias_changes(float* b, float* db);

int main()
{
	//initialize
	//srand(static_cast<unsigned int>(time(NULL)));
	int i, j, k, size;

	images = new vector<float*>();
	labels = new vector<int>();
	read_image_label();

	bss = new float* [LEVEL_SIZE];
	wss = new float* [LEVEL_SIZE];

	//read_bias_weight();
	make_bias_weight();
	make_cnn_filter();

	mini_batch(TOTAL_SIZE, MINI_BATCH_SIZE);

	for (i = 0; i < FILTER_COUNT; i++) {
		cudaMalloc((void**)&cnn[i], cnn_level_size[i + 1] * cnn_level_size[i + 1] * sizeof(float));
		cudaMalloc((void**)&cnn_w[i], cnn_level_size[i + 1] * cnn_level_size[i + 1] * sizeof(float));
		cudaMalloc((void**)&cnn_b[i], sizeof(float));
		cudaMemset(cnn_b[i], 0, sizeof(float));
		cudaMalloc((void**)&cnn_b_w[i], sizeof(float));

		cudaMalloc((void**)&filter[i], FILTER_SIZE * sizeof(float));
		cudaMemcpy(filter[i], filter_gen[i], FILTER_SIZE * sizeof(float), cudaMemcpyHostToDevice);
		cudaMalloc((void**)&df[i], FILTER_SIZE * sizeof(float));
		cudaMalloc((void**)&fr[i], FILTER_SIZE * sizeof(float));

		pad_df_width = cnn_level_size[i + 1] + (FILTER_SIZE - 1) * 2;
		pad_df_size = pad_df_width * pad_df_width;
		cudaMalloc((void**)&pad_df[i], pad_df_size * sizeof(float));
		cudaMemset(pad_df[i], 0, pad_df_size * sizeof(float));
	}
	
	cudaMalloc((void**)&avg, sizeof(float));
	cudaMalloc((void**)&disp, sizeof(float));
	cudaMalloc((void**)&level[0], level_size[0] * sizeof(float));
	cudaMalloc((void**)&xssd[0], level_size[0] * sizeof(float));
	cudaMalloc((void**)&output_dev, level_size[LEVEL_SIZE] * sizeof(float));
	output = new float[level_size[3]];
	ans = new float[level_size[3]];

	for (i = 0; i < LEVEL_SIZE; i++) {
		size = level_size[i + 1] * sizeof(float);
		cudaMalloc((void**)&bss_dev[i], size);
		cudaMemcpy(bss_dev[i], bss[i], size, cudaMemcpyHostToDevice);
		cudaMalloc((void**)&level[i + 1], size);
		cudaMalloc((void**)&xssd[i + 1], size);

		size = level_size[i] * level_size[i + 1] * sizeof(float);
		cudaMalloc((void**)&wss_dev[i], size);
		cudaMemcpy(wss_dev[i], wss[i], size, cudaMemcpyHostToDevice);
		cudaMalloc((void**)&wsst[i], size);
		cudaMalloc((void**)&wssd[i], size);
	}
	//~initialize

	//work
	for (i = 0; i < MINI_BATCH_SIZE; i++) {
		cout << "backprop " << i;

		//cout << endl;
		//for (j = 0; j < 28; j++) {
		//	for (k = 0; k < 28; k++) {
		//		cout << (images->at(mbatch->at(i))[j * 28 + k] > 0) << ' ';
		//	}
		//	cout << endl;
		//}

		predict(images->at(mbatch->at(i)), labels->at(mbatch->at(i)));
		cout << " cee : " << cee;
		backprop(images->at(mbatch->at(i)), labels->at(mbatch->at(i)));
		cout << " to " << cee << endl;
	}

	cnt = 0;
	correct = 0;
	for (i = 0; i < TOTAL_SIZE; i++) {
		predict(images->at(i), labels->at(i));
		cnt++;
		if (anstmp == labels->at(i)) {
			correct++;
		}
		cout << i << " predict : " << anstmp << " answer : " << labels->at(i) << " cee : " << cee << " data : ";
		for (j = 0; j < 10; j++) {
			//cout << output[j] << ' ';
			printf("%.4f ", output[j]);
		}
		cout << endl;
	}
	cout << "accuracy " << correct / (float)cnt << endl;
	//~work

	cudaDeviceReset();

	return 0;
}

void read_image_label() {
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
		char* imagebuffer = new char[level_size[0]];
		input_image.read(imagebuffer, level_size[0]);
		for (k = 0; k < level_size[0]; k++) {
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
		img = new float[level_size[0]];

		for (j = 0; j < level_size[0]; j++) {
			img[j] = (float)(unsigned char)bytes_i[i++] / 256.0;
		}
		images->push_back(img);
		count++;
	}

	cout << images->size() << " images" << endl;

	input_image.close();
	input_label.close();
}

void read_bias_weight() {
	ifstream bias_wieght(BIAS_WEIGHT_PATH);
	vector<char> chars(istreambuf_iterator<char>(bias_wieght), (istreambuf_iterator<char>()));
	int n = chars.size(), i, j, k, q = 0;
	vector<vector<float>*>* vs = new vector<vector<float>*>();
	vector<float>* v = new vector<float>();
	string s = "";
	for (i = 0; i < n; i++) {
		if (chars[i] == '\n') {
			vs->push_back(v);
			v = new vector<float>();
		}
		else if (chars[i] == '/') {
			v->push_back(stof(s));
			s.clear();
		}
		else {
			s += chars[i];
		}
	}

	for (i = 0; i < LEVEL_SIZE; i++) {
		bss[i] = &vs->at(i)->at(0);
		q++;
	}
	for (i = 0; i < LEVEL_SIZE; i++) {
		int size = level_size[i] * level_size[i + 1];
		float* x = new float[size];

		int pos = 0;
		for (j = 0; j < level_size[i]; j++) {
			memcpy(&x[pos], &vs->at(q++)->at(0), level_size[i + 1] * sizeof(float));
			pos += level_size[i + 1];
		}
		wss[i] = x;
	}
}

void make_bias_weight() {
	int i, j, size;
	float sd;
	float dist[10];

	for (i = 0; i < LEVEL_SIZE; i++) {
		bss[i] = new float[level_size[i + 1]];
		memset(bss[i], 0, level_size[i + 1] * sizeof(float));
		size = level_size[i] * level_size[i + 1];
		wss[i] = new float[size];
		sd = sqrt((ACT_FUNCTION + 1) / (float)level_size[i + 1]);
		normal_distribution<float> distribution(0.5, sd);
		default_random_engine generator;
		generator.seed(rand());
		memset(dist, 0, 10 * sizeof(float));
		for (j = 0; j < size; j++) {
			wss[i][j] = distribution(generator);
			if (wss[i][j] > 1) {
				wss[i][j] = 0.9999;
			}
			else if (wss[i][j] < 0) {
				wss[i][j] = 0.0001;
			}

			dist[(int)(wss[i][j] * 10)]++;
		}

		cout << "sd : " << sd << ", size : " << size << endl;
		for (j = 0; j < 10; j++) {
			cout << j * 0.1 << "~ : " << dist[j] << '(' << dist[j] * 100 / (float)size << "%)" << endl;
		}
		cout << endl;
	}
}

void make_cnn_filter() {
	int i, j;
	normal_distribution<float> distribution(0, 0.2);
	default_random_engine generator;
	generator.seed(rand());
	for (i = 0; i < FILTER_COUNT; i++) {
		filter_gen[i] = new float[FILTER_SIZE];
		for (j = 0; j < FILTER_SIZE; j++) {
			filter_gen[i][j] = distribution(generator);
			if (filter_gen[i][j] > 1) {
				filter_gen[i][j] = 1;
			}
			else if (filter_gen[i][j] < -1) {
				filter_gen[i][j] = -1;
			}
		}
	}
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

void predict(float* image, int label) {
	int i;

	error = cudaMemcpy(level[0], image, level_size[0] * sizeof(float), cudaMemcpyHostToDevice);
	if (error != cudaSuccess) {
		cout << "Faild copy image to device" << endl;
		return;
	}

	matrix_convolution_multiplication << <24, 24 >> > (level[0], 28, filter[0], 5, cnn[0]);	
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}

	relu_cnn << <24, 24 >> > (cnn[0], 24, cnn_b[0]);
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}

	matrix_convolution_multiplication << <20, 20 >> > (cnn[0], 24, filter[1], 5, cnn[1]);
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}

	relu_cnn << <20, 20 >> > (cnn[1], 20, cnn_b[1]);
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}

	cnnPooling << <10, 10 >> > (cnn[1], cnn_level_size[2], POOLING_SIZE, level[2]);
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}

	//print_matrix << <1, 1 >> > (level[0], 28 * 28, 28);
	//print_matrix << <1, 1 >> > (filter[0], 5 * 5, 5);
	//print_matrix << <1, 1 >> > (cnn[0], 24 * 24, 24);
	//print_matrix << <1, 1 >> > (filter[1], 5 * 5, 5);
	//print_matrix << <1, 1 >> > (cnn[1], 20 * 20, 20);
	//print_matrix << <1, 1 >> > (level[2], 10 * 10, 10);

	//pass for cnn
	//for (i = 0; i < LEVEL_SIZE - 1; i++) {
	//	matrix_multiplication << <1, level_size[i + 1] >> > (level[i], 1, level_size[i], wss_dev[i], level_size[i], level_size[i + 1], level[i + 1]);
	//	//batch_norm<<<1,1>>>(level[i + 1], level_size[i + 1], avg, disp);		
	//	//batch_norm_set << <1, level_size[i + 1] >> > (level[i + 1], avg, disp, 1, 0);
	//	//print_matrix << <1, 1 >> > (level[i + 1], level_size[i + 1], 10);
	//	if (ACT_FUNCTION) {
	//		bias_relu << <1, level_size[i + 1] >> > (level[i + 1], bss_dev[i]);
	//	}
	//	else {
	//		bias_sigmoid << <1, level_size[i + 1] >> > (level[i + 1], bss_dev[i]);
	//	}
	//}

	matrix_multiplication << <1, level_size[LEVEL_SIZE] >> > (level[LEVEL_SIZE - 1], 1, level_size[LEVEL_SIZE - 1], wss_dev[LEVEL_SIZE - 1], level_size[LEVEL_SIZE - 1], level_size[LEVEL_SIZE], level[LEVEL_SIZE]);
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}
	//print_matrix << <1, 1 >> > (level[3], 10, 10);
	softmax << <1, 1 >> > (level[LEVEL_SIZE], output_dev, level_size[LEVEL_SIZE]);
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}
	//print_matrix << <1, 1 >> > (output_dev, 10, 10);
	cudaMemcpy(output, output_dev, level_size[LEVEL_SIZE] * sizeof(float), cudaMemcpyDeviceToHost);
	if (cudaDeviceSynchronize() != cudaSuccess) {
		cout << "error occured" << endl;
		return;
	}

	memset(ans, 0, level_size[LEVEL_SIZE] * sizeof(float));
	ans[label] = 1;

	cee = cross_entropy_error(output, ans, level_size[LEVEL_SIZE]);

	int maxidx = -1;
	float max = -1;
	for (i = 0; i < level_size[LEVEL_SIZE]; i++) {
		if (output[i] > max) {
			max = output[i];
			maxidx = i;
		}
	}

	anstmp = maxidx;
}

void backprop(float* img, int label) {
	int i, j, k;

	for (i = 0; i < LEARN_COUNT; i++) {
		predict(img, label);		
		
		//copy trans - matrix
		for (j = 0; j < LEVEL_SIZE; j++) {
			matrix_transpose << <level_size[j], level_size[j + 1] >> > (wss_dev[j], level_size[j], level_size[j + 1], wsst[j]);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}			
			print_matrix(level[j], level_size[j], 10, "level[j] " + to_string(i));
		}
		
		//copy reverse - matrix
		for (j = 0; j < FILTER_COUNT; j++) {
			matrix_reverse << <FILTER_WIDTH, FILTER_WIDTH >> > (filter[j], fr[j], FILTER_WIDTH);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}
		}

		//softmax - with - loss
		for (j = 0; j < level_size[LEVEL_SIZE]; j++) {
			output[j] -= ans[j];
		}

		//copy softmax - with - loss data to device
		error = cudaMemcpy(xssd[LEVEL_SIZE], output, level_size[LEVEL_SIZE] * sizeof(float), cudaMemcpyHostToDevice);
		if (error != cudaSuccess) {
			cout << "Copy result to host faild" << endl;
			return;
		}
		print_matrix(xssd[LEVEL_SIZE], 10, 10, "xssd[LEVEL_SIZE] " + to_string(i));

		//set back to output
		for (j = 0; j < level_size[LEVEL_SIZE]; j++) {
			output[j] += ans[j];
		}
		

		//for (j = LEVEL_SIZE; j > 1; j--) { //ann
		for (j = LEVEL_SIZE; j > 2; j--) { //cnn
			matrix_multiplication << <1, level_size[j - 1] >> > (xssd[j], 1, level_size[j], wsst[j - 1], level_size[j], level_size[j - 1], xssd[j - 1]);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}
			print_matrix(xssd[2], 100, 10, "xssd[2] " + to_string(i));

			matrix_multiplication << <level_size[j - 1], level_size[j] >> > (level[j - 1], level_size[j - 1], 1, xssd[j], 1, level_size[j], wssd[j - 1]);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}
			print_matrix(wssd[2], 1000, 10, "wssd[2] " + to_string(i));

			if (ACT_FUNCTION) {
				relu_backward << <1, level_size[j - 1] >> > (xssd[j - 1], level[j - 1], 1, level_size[j - 1]);
				if (cudaDeviceSynchronize() != cudaSuccess) {
					cout << "error occured" << endl;
					return;
				}

			}
			else {
				sigmoid_backward << <1, level_size[j - 1] >> > (xssd[j - 1], level[j - 1], 1, level_size[j - 1]);
				if (cudaDeviceSynchronize() != cudaSuccess) {
					cout << "error occured" << endl;
					return;
				}
			}
			print_matrix(xssd[2], 100, 10, "xssd[2] " + to_string(i));
		}

		//ann
		//matrix_multiplication << <level_size[0], level_size[1] >> > (level[0], level_size[0], 1, xssd[1], 1, level_size[1], wssd[0]);
		//~ann

		//cnn
		pooling_backward << <20, 20 >> > (xssd[2], level[2], 10, cnn[1], 20, cnn_w[1]);
		if (cudaDeviceSynchronize() != cudaSuccess) {
			cout << "error occured" << endl;
			return;
		}
		print_matrix(cnn_w[1], 400, 20, "cnn_w[1] " + to_string(i));

		relu_backward << <20, 20 >> > (cnn_w[1], cnn[1], 20, 20);
		if (cudaDeviceSynchronize() != cudaSuccess) {
			cout << "error occured" << endl;
			return;
		}
		print_matrix(cnn_w[1], 400, 20, "cnn_w[1] " + to_string(i));

		//summary cnn_w[1]
		set_cnn_bias << <1, 1 >> > (cnn_w[1], 400, cnn_b_w[1]);

		matrix_convolution_multiplication << <FILTER_WIDTH, FILTER_WIDTH >> > (cnn[0], 24, cnn_w[1], 20, df[1]);
		if (cudaDeviceSynchronize() != cudaSuccess) {
			cout << "error occured" << endl;
			return;
		}
		print_matrix(df[1], 25, 5, "df[1] " + to_string(i));


		
		make_padding_matrix<<<20, 20>>>(cnn_w[1], 20, pad_df[1], FILTER_WIDTH - 1);
		if (cudaDeviceSynchronize() != cudaSuccess) {
			cout << "error occured" << endl;
			return;
		}
		print_matrix(pad_df[1], 28 * 28, 28, "pad_dfx[1] " + to_string(i));

		matrix_convolution_multiplication << <24, 24 >> > (pad_df[1], 28, fr[1], 5, cnn_w[0]);
		if (cudaDeviceSynchronize() != cudaSuccess) {
			cout << "error occured" << endl;
			return;
		}
		print_matrix(cnn_w[0], 24 * 24, 24, "cnn_w[0] " + to_string(i));
		
		relu_backward << <24, 24 >> > (cnn_w[0], cnn[0], 24, 24);
		if (cudaDeviceSynchronize() != cudaSuccess) {
			cout << "error occured" << endl;
			return;
		}
		print_matrix(cnn_w[0], 24 * 24, 24, "cnn_w[0] " + to_string(i));

		//average cnn_w[0]
		set_cnn_bias << <1, 1 >> > (cnn_w[0], 400, cnn_b_w[0]);

		matrix_convolution_multiplication << <FILTER_WIDTH, FILTER_WIDTH >> > (level[0], 28, cnn_w[0], 24, df[0]);
		if (cudaDeviceSynchronize() != cudaSuccess) {
			cout << "error occured" << endl;
			return;
		}
		print_matrix(df[0], 5 * 5, 5, "df[0] " + to_string(i));
		//~cnn

		//print_matrix << <1, 1 >> > (df[0], 5 * 5, 5);
		//print_matrix << <1, 1 >> > (df[1], 5 * 5, 5);

		//print_matrix << <1, 1 >> > (filter[0], 5 * 5, 5);
		//print_matrix << <1, 1 >> > (filter[1], 5 * 5, 5);

		//for (j = 0; j < LEVEL_SIZE; j++) { //ann
		for (j = 2; j < LEVEL_SIZE; j++) { // cnn
			set_weight_changes << < level_size[j], level_size[j + 1] >> > (wss_dev[j], wssd[j], level_size[j], level_size[j + 1]);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}

			set_bias_changes << <1, level_size[j + 1] >> > (bss_dev[j], xssd[j + 1], level_size[j + 1]);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}
		}

		//cnn
		for (j = 0; j < FILTER_COUNT; j++) {
			set_filter_changes << < FILTER_WIDTH, FILTER_WIDTH >> > (filter[j], df[j], FILTER_WIDTH);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}

			set_cnn_bias_changes << <1, 1 >> > (cnn_b[j], cnn_b_w[j]);
			if (cudaDeviceSynchronize() != cudaSuccess) {
				cout << "error occured" << endl;
				return;
			}
		}
	}
}

float cross_entropy_error(float* y, float* t, int n) {
	float res = 0;
	int i;

	for (i = 0; i < n; i++) {
		res += t[i] * log(y[i] + 1e-7);
	}

	return -res;
}

void print_matrix(float* a, int n, int r, string tag) {
	if (0
		|| tag.find("df[0]") != string::npos
		|| tag.find("df[1]") != string::npos
		) {
		float* buffer = new float[n];
		cudaMemcpy(buffer, a, n * sizeof(float), cudaMemcpyDeviceToHost);
		printf("\nprint %d items - %s\n", n, tag.c_str());
		int i;
		for (i = 0; i < n; i++) {
			if (i % r == 0 && i > 0) {
				printf("(%d)\n", i);
			}
			printf("%.4f ", buffer[i]);
		}
		printf("\n");
		delete buffer;
	}	
}

__global__ void softmax(float* a, float* b, int n) {
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
//row-col <<<m, p>>> matrix, {n == o} (m x n) x (o x p) = (m x p)
__global__ void matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res) {
	int bi = blockIdx.x, ti = threadIdx.x, sb = bi * n, st = ti, c = bi * p + ti, i;
	res[c] = 0;
	for (i = 0; i < n; i++) {
		res[c] += a[sb + i] * b[st];
		st += p;
	}
}

__global__ void bias_sigmoid(float* a, float* bias) {
	int ti = threadIdx.x;
	a[ti] = 1 / (1 + exp(-(a[ti] + bias[ti])));
}

__global__ void bias_relu(float* a, float* bias) {
	int ti = threadIdx.x;
	a[ti] = a[ti] < 0 ? 0 : (a[ti] + bias[ti]);
}

__global__ void sigmoid_backward(float* dy, float* y, int m, int n) {
	int i = blockIdx.x, j = threadIdx.x, seq = n * i + j;
	float t = y[seq];
	dy[seq] *= t * (1 - t);
}

__global__ void relu_backward(float* dy, float* y, int m, int n) {
	int i = blockIdx.x, j = threadIdx.x, seq = n * i + j;
	dy[seq] *= y[seq] < 0 ? 0 : 1;
}

__global__ void relu_cnn(float* a, int n, float* bias) {	
	int bi = blockIdx.x, ti = threadIdx.x;
	int seq = bi * n + ti;
	a[seq] = a[seq] < 0 ? 0 : (a[seq] + *bias);
}

__global__ void set_weight_changes(float* ws, float* wds, int h, int w) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	int seq = bx * w + tx;
	ws[seq] -= wds[seq] * LEARN_RATE;	
}

__global__ void set_bias_changes(float* bs, float* bds, int n) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	bs[tx] -= bds[tx] * LEARN_RATE;
}

__global__ void matrix_transpose(float* a, int m, int n, float* b) {
	int j = blockIdx.x;
	int i = threadIdx.x;
	b[i * m + j] = a[j * n + i];
}

__global__ void batch_norm(float* a, int n, float* avg, float* disp) {
	int i;
	float tmp;

	for (i = 0; i < n; i++) {
		*avg += a[i];
	}
	*avg /= n;

	for (i = 0; i < n; i++) {
		tmp = a[i] - *avg;
		*disp += tmp * tmp;
	}
	*disp /= n;
}

__global__ void batch_norm_set(float* a, float* avg, float* disp, float g, float b) {
	int i = threadIdx.x;
	a[i] = g * ((a[i] - *avg) / sqrt(*disp * *disp + 10e-7)) + b;
}

__global__ void matrix_reverse(float* a, float* b, int n) {
	int bl = blockIdx.x, th = threadIdx.x;
	int idx = bl * n + th;
	int ridx = (n - bl - 1) * n + (n - th - 1);
	b[idx] = a[ridx];
}

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

__global__ void cnnPooling(float* a, int m, int n, float* b) {
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

__global__ void set_filter_changes(float* f, float* df, int n) {
	int bl = blockIdx.x, th = threadIdx.x;
	int idx = bl * n + th;	
	f[idx] -= df[idx] * LEARN_RATE;
}

//a : base, n :base width, b : result, p : padding size
__global__ void make_padding_matrix(float* a, int n, float* b, int p) {
	int bl = blockIdx.x, th = threadIdx.x;
	int idx = bl * n + th;
	int pad_width = n + 2 * p;
	int pad_bl = p - 1 + bl, pad_th = p - 1 + th;
	int pad_idx = pad_bl * pad_width + pad_th;
	b[pad_idx] = a[idx];
}

__global__ void set_cnn_bias(float* a, int n, float* bias) {
	int i;
	*bias = 0;
	for (i = 0; i < n; i++) {
		*bias += a[i];
	}	
}

__global__ void set_cnn_bias_changes(float* b, float* db) {
	*b -= *db * LEARN_RATE;
	//printf("bias : %f\n", *db);
}