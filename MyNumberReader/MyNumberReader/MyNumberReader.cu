//#include "cuda_runtime.h"
//#include "device_launch_parameters.h"
//
//#include <stdio.h>
//#include <iostream>
//#include <vector>
//#include <fstream>
//#include <string>
//#include <algorithm>
//#include <chrono>
//#include <random>
//
//using namespace std;
//
//#define IMAGE_PATH "mnist\\train-images.idx3-ubyte"
//#define LABEL_PATH "mnist\\train-labels.idx1-ubyte"
//#define BIAS_WEIGHT_PATH "mnist\\biasweight.txt"
//
//#define IMAGE_SIZE 28
//#define IMAGE_HEADER_SIZE 16
//#define LABEL_HEADER_SIZE 8
//
//#define TOTAL_SIZE 1200 //60000 max
//#define MINI_BATCH_SIZE 100 // <= TOTAL_IMG_SIZE
//
//#define LEARN_COUNT 20
//#define LEARN_RATE 1
//#define DIFF_H 1e-4;
//#define DIFF_H_2 2 * 1e-4;
//
//struct Image {
//	int num;
//	unsigned char image[28][28];
//};
//
//float sigmoid_cu(float x);
//vector<float>* softmax_cu(vector<float>* a);
//float* matrix_multiplication_cu(float* a, int m, int n, float* b, int o, int p, int blocks, int threads);
//float** matrix_transpose_cu(float** a, int m, int n);
//void set_sigmoid_backward_cu(float** dy, float m, float n, float** y, float o, float p);
//
//vector<Image>* read_image_label_cu(const char* image_path, const char* label_path);
//vector<vector<float>*>* read_bias_weight_cu(const char* bias_weight_path);
//void write_bias_weight_cu(const char* path, float** bs, int* m, float*** ws, int** n);
//
//void print_image_cu(Image* img);
//void print_matrix_cu(float** a, int m, int n);
//float* convert_image_cu(Image* img);
//
//float* get_normal_distribution_array_cu(int n);
//vector<int>* mini_batch_idx_sort_cu(int n, int count);
//float cross_entropy_error_cu(vector<float>* y, vector<float>* t);
//
//vector<float>* predict_cu(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);
//float*** predictlevels_cu(Image* img, float** bs, float*** ws);
//float*** get_weight_gradient(Image* img, float** bs, float*** ws);
//
//void learn_cu(Image* img, float** bs, float*** ws);
//void backprop_cu(Image* img, float** bs, float*** ws);
//void printpredict_cu(vector<Image>* images, vector<int>* mini_batch, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);
//
//__global__ void kernel_mm(float* a, int m, int n, float* b, int o, int p, float* res);
//__global__ void kernel_bs(float* a, int m, int n, float* bs);
//
//vector<vector<float>*>* bv_cu;
//vector<vector<vector<float>*>*>* wv_cu;
//vector<vector<float>*>* bg_cu;
//vector<vector<vector<float>*>*>* wg_cu;
//
//int main()
//{
//	//initialize
//	srand(static_cast<unsigned int>(time(NULL)));
//	vector<Image>* images = read_image_label_cu(IMAGE_PATH, LABEL_PATH);
//	vector<vector<float>*>* vs = read_bias_weight_cu("mnist\\bwvalue.txt");
//
//	vector<vector<float>*>* bs = new vector<vector<float>*>();
//	int i, j, k, l, cnt = 0;
//	for (i = 0; i < 3; i++) {
//		bs->push_back(vs->at(cnt++));		
//	}
//
//	vector<vector<vector<float>*>*>* ws = new vector<vector<vector<float>*>*>();
//	vector<vector<float>*>* wt;
//
//	wt = new vector<vector<float>*>();
//	for (i = 0; i < 784; i++) {
//		wt->push_back(vs->at(cnt++));
//		//wt->push_back(get_normal_distribution_array(50));
//		//wt->push_back(new vector<float>(50, 0.5));
//	}
//	ws->push_back(wt);
//
//	wt = new vector<vector<float>*>();
//	for (i = 0; i < 50; i++) {
//		wt->push_back(vs->at(cnt++));
//		//wt->push_back(get_normal_distribution_array(100));
//		//wt->push_back(new vector<float>(100, 0.5));
//	}
//	ws->push_back(wt);
//
//	wt = new vector<vector<float>*>();
//	for (i = 0; i < 100; i++) {
//		wt->push_back(vs->at(cnt++));
//		//wt->push_back(get_normal_distribution_array(10));
//		//wt->push_back(new vector<float>(10, 0.5));
//	}
//	ws->push_back(wt);
//	//~initialize
//
//	//cnn
//	int n = images->size(), correct = 0, wrong = 0, seq = 0, max_index;
//	float error, max_value, mh, ph;
//
//	vector<int>* mini_batch = mini_batch_idx_sort_cu(TOTAL_SIZE, MINI_BATCH_SIZE);
//
//	//learn
//	printpredict_cu(images, mini_batch, bs, ws);
//	//for (i = 0; i < MINI_BATCH_SIZE; i++) {
//	//	cout << i << " - learn " << images->at(mini_batch->at(i)).num << ' ';
//	//	//learn(&images->at(mini_batch->at(i)), bs, ws);
//	//	backprop_cu(&images->at(mini_batch->at(i)), bs, ws);
//	//	cout << endl;
//	//}
//	printpredict_cu(images, mini_batch, bs, ws);
//	//~learn
//
//	//~cnn
//
//	//deallocate
//	delete mini_batch;
//	for (i = 0; i < ws->size(); i++) {
//		delete ws->at(i);
//	}
//	delete ws;
//
//	for (i = 0; i < vs->size(); i++) {
//		delete vs->at(i);
//	}
//	delete vs;
//	delete images;
//	//~deallocate
//
//	return 0;
//}
//
//vector<Image>* read_image_label_cu(const char* image_path, const char* label_path)
//{
//	int header = 0, row = 0, col = 0, n, m, i = 0, j = 0, k = 0, l = 0, count = 0;
//
//	//read image
//	ifstream input_image(image_path, ios::binary);
//	//vector<char> bytes_i(istreambuf_iterator<char>(input_image), (istreambuf_iterator<char>()));
//	vector<char> bytes_i;
//	char headerbuffer[IMAGE_HEADER_SIZE];
//	input_image.read(headerbuffer, IMAGE_HEADER_SIZE);
//	for (i = 0; i < IMAGE_HEADER_SIZE; i++) {
//		bytes_i.push_back(headerbuffer[i]);
//	}
//
//	for (i = 0; i < TOTAL_SIZE; i++) {
//		char imagebuffer[784];
//		input_image.read(imagebuffer, 784);
//		for (j = 0; j < 784; j++) {
//			bytes_i.push_back(imagebuffer[j]);
//		}
//	}
//
//	//read label
//	ifstream input_label(label_path, ios::binary);
//	//vector<char> bytes_l(istreambuf_iterator<char>(input_label), (istreambuf_iterator<char>()));
//	vector<char> bytes_l;
//	char labelbuffer[LABEL_HEADER_SIZE + TOTAL_SIZE];
//	input_label.read(labelbuffer, LABEL_HEADER_SIZE + TOTAL_SIZE);
//	for (int i = 0; i < LABEL_HEADER_SIZE + TOTAL_SIZE; i++) {
//		bytes_l.push_back(labelbuffer[i]);
//	}
//
//	n = bytes_i.size();
//	m = bytes_l.size();
//	vector<Image>* res = new vector<Image>();
//
//	i = 0;
//	l = 0;
//	cout << "image header : ";
//	for (j = 0; j < IMAGE_HEADER_SIZE; j++) {
//		cout << (int)(unsigned char)bytes_i[i++] << ' ';
//	}
//	cout << endl;
//
//	cout << "label header : ";
//	for (j = 0; j < LABEL_HEADER_SIZE; j++) {
//		cout << (int)(unsigned char)bytes_l[l++] << ' ';
//	}
//	cout << endl;
//
//	while (i < n && l < m && count < TOTAL_SIZE) {
//
//		Image img;
//		img.num = (int)(unsigned char)bytes_l[l++];
//
//		for (j = 0; j < IMAGE_SIZE; j++) {
//			for (k = 0; k < IMAGE_SIZE; k++) {
//				img.image[j][k] = (unsigned char)bytes_i[i++];
//			}
//		}
//		res->push_back(img);
//		//print_image(&img);
//		count++;
//	}
//
//	cout << res->size() << " images" << endl;
//
//	input_image.close();
//	input_label.close();
//
//	return res;
//}
//
//vector<vector<float>*>* read_bias_weight_cu(const char* bias_weigh_tpath) {
//	ifstream bias_wieght(bias_weigh_tpath);
//	vector<char> chars(istreambuf_iterator<char>(bias_wieght), (istreambuf_iterator<char>()));
//	int n = chars.size(), i, k;
//	vector<vector<float>*>* vs = new vector<vector<float>*>();
//	vector<float>* v = new vector<float>();
//	string s = "";
//	for (i = 0; i < n; i++) {
//		if (chars[i] == '\n') {
//			vs->push_back(v);
//			v = new vector<float>();
//		}
//		else if (chars[i] == '/') {
//			v->push_back(stof(s));
//			s.clear();
//		}
//		else {
//			s += chars[i];
//		}
//	}
//
//	return vs;
//}
//
//vector<int>* mini_batch_idx_sort_cu(int n, int count) {
//	vector<int>* res = new vector<int>();
//	int i, x;
//
//	if (count <= n && count >= 0) {
//		int* arr = new int[n];
//		for (i = 0; i < n; i++) {
//			arr[i] = i;
//		}
//		for (i = n; i > n - count; i--) {
//			x = rand() % i;
//			res->push_back(arr[x]);
//			arr[x] = arr[i - 1];
//		}
//		delete[] arr;
//	}
//	sort(res->begin(), res->end());
//	return res;
//}
//
//
//void printpredict_cu(vector<Image>* images, vector<int>* mini_batch, float** bs, int* bs_arr_sz, int bs_sz
//	, vector<vector<vector<float>*>*>* ws) {
//	int i, j, seq, max_index, correct = 0, wrong = 0;
//	float error, max_value;
//	for (i = 0; i < MINI_BATCH_SIZE; i++) {
//		seq = mini_batch->at(i);
//		cout << "task " << i + 1 << " -> value : " << images->at(seq).num;
//		vector<float>* output = predict_cu(&images->at(seq), bs, ws);
//		vector<float>* answer = new vector<float>(10, 0);
//		answer->at(images->at(seq).num) = 1;
//		error = cross_entropy_error_cu(output, answer);
//
//		max_value = 0;
//		max_index = -1;
//		for (j = 0; j < output->size(); j++) {
//			if (output->at(j) > max_value) {
//				max_value = output->at(j);
//				max_index = j;
//			}
//		}
//
//		if (max_index == images->at(seq).num) {
//			correct++;
//		}
//		else {
//			wrong++;
//		}
//		cout << " result : " << max_index << " error : " << error
//			<< " accuracy : " << correct / (float)(correct + wrong) << endl;
//
//		delete output;
//		delete answer;
//	}	
//}
//
//float* convert_image_cu(Image* image) {
//	float* res = new float[IMAGE_SIZE * IMAGE_SIZE];
//	int i, j;
//	for (i = 0; i < IMAGE_SIZE; i++) {
//		for (j = 0; j < IMAGE_SIZE; j++) {
//			res[i * IMAGE_SIZE + j] = image->image[i][j];
//		}
//	}
//	return res;
//}
//
//vector<float>* predict_cu(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {
//	float* input = convert_image_cu(img);	
//	int i;
//
//	float* ws0 = ws->at(0)
//	
//	float* level_1 = matrix_multiplication_cu(input, 28, 28,  );
//	set_bias_sigmoid_cu(level_1, bs->at(0));
//
//	float* level_2 = matrix_multiplication_cu(level_1, ws->at(1));
//	set_bias_sigmoid_cu(level_2, bs->at(1));
//
//	float* level_3 = matrix_multiplication_cu(level_2, ws->at(2));
//	set_bias_sigmoid_cu(level_3, bs->at(2));
//
//	vector<float>* output = softmax_cu(level_3->at(0));
//
//	delete level_1;
//	delete level_2;
//	delete level_3;	
//	delete input;
//
//	return output;
//}
//
//vector<float>* softmax_cu(vector<float>* a) {
//	int i, n = a->size();
//	float max = 0, expsum = 0;
//	vector<float> ac(n);
//	vector<float>* res = new vector<float>();
//	for (i = 0; i < n; i++) {
//		if (a->at(i) > max) {
//			max = a->at(i);
//		}
//	}
//
//	for (i = 0; i < n; i++) {
//		ac[i] = a->at(i) - max;
//		expsum += exp(ac[i]);
//	}
//
//	for (i = 0; i < n; i++) {
//		res->push_back(exp(ac[i]) / expsum);
//	}
//
//	return res;
//}
//
//float* matrix_multiplication_cu(float* a, int m, int n, float* b, int o, int p, float* bs, int q, int blocks, int threads) {
//
//	float* dev_a = 0;
//	float* dev_b = 0;
//	float* dev_c = 0;
//
//	int mal_a = m * n;
//	int mal_b = o * p;
//	int mal_c = m * p;
//
//	cudaMalloc((void**)&dev_c, mal_c * sizeof(float));
//
//	cudaMalloc((void**)&dev_a, mal_a * sizeof(float));
//	cudaMemcpy(dev_a, a, mal_a * sizeof(float), cudaMemcpyHostToDevice);	
//
//	cudaMalloc((void**)&dev_b, mal_b * sizeof(float));
//	cudaMemcpy(dev_b, b, mal_b * sizeof(float), cudaMemcpyHostToDevice);
//
//	kernel_mm << <blocks, threads >> > (a, m, n, b, o, p, c);
//
//	cudaMemcpy(dev_c, dev_c, mal_c * sizeof(int), cudaMemcpyDeviceToHost);
//
//	return dev_c;
//}
//
//__global__ void kernel_mm(float* a, int m, int n, float* b, int o, int p, float* res) {
//	
//}
//
//__global__ void kernel_bs(float* a, int m, int n, float* bs) {
//
//}