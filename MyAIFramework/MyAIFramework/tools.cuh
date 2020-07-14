#pragma once
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "kernel.cuh"
#include <iostream>
#include <random>

float* mal_cpy_dev(float* data, int size);
float* mal_cpy_host(float* data, int size);

float* mal_dev(int size);
void free_dev(float* data);

void cpy_host(float* dst, float* src, int size);
void cpy_dev(float* dst, float* src, int size);

void cpy_dev_to_dev(float* dst, float* src, int size);

void generate_weight(float* weight, int size, float mean, float dist);

void matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res);
void matrix_convolution_multiplication(float* a, int m, float* b, int n, float* c);
void matrix_transpose(float* a, int m, int n, float* b);
void matrix_reverse(float* a, float* b, int m, int n);

void make_padding_matrix(float* a, int n, float* b, int p);

void update_delta(float* weight, float* changes, int w, int h, float lr);

void add_bias(int n, float* dst, float* bias);
void add_bias_array(int n, float* dst, float* bias);

void relu(int n, float* a);
void relu_backward(float* dy, float* y, int m, int n);
void pooling(float* a, int m, int n, float* b);
void pooling_backward(float* d, float* a, int m, float* b, int n, float* c);

void get_dist_worker(int size, float avg, float* start, float* data_sub_avg, float* data_sub_avg_sq);
void batch_norm_worker(int size
	, float* data
	, float* data_sub_avg
	, float* data_sub_avg_sq
	, float* data_caret
	, float* data_caret_mul_g
	, float* data_caret_mul_g_add_b
	, float avg, float dist, float g, float b);
void batch_norm(float* a, int size, float avg, float disp, float g, float b);
void dropout(float* data, float* mask, int size);

void softmax(float* a, float* b, int n);
float get_cross_entrophy_error(float* answer, float* output, int size);
int* mini_batch(int n, int count);
float* mini_batch_mask(int n, int count);

void print(char* title, float* data, int size, int width);

void set_weight_changes(float* ws, float* wds, int h, int w, float lr);
void set_bias_changes(float* bs, float* bds, int n, float lr);