#pragma once
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <math.h>

__global__ void k_update_delta(float* weight, float* delta, int width, float lr);
__global__ void k_add_bias(int n, float* dst, float* bias);
__global__ void k_add_bias_array(int n, float* dst, float* bias);
__global__ void k_relu(int n, float* a);
__global__ void k_relu_backward(float* dy, float* y, int m, int n);
__global__ void k_pooling(float* a, int m, int n, float* b);
__global__ void k_pooling_backward(float* d, float* a, int m, float* b, int n, float* c);
__global__ void k_matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res);
__global__ void k_matrix_convolution_multiplication(float* a, int m, float* b, int n, float* c);
__global__ void k_matrix_transpose(float* a, int m, int n, float* b);
__global__ void k_matrix_reverse(float* a, float* b, int n);
__global__ void k_make_padding_matrix(float* a, int n, float* b, int p);
__global__ void k_set_weight_changes(float* ws, float* wds, int h, int w, float lr);
__global__ void k_set_bias_changes(float* bs, float* bds, int n, float lr);
__global__ void k_get_dist_worker(int size, float avg, float* data, float* data_sub_avg, float* data_sub_avg_sq);
__global__ void k_batch_norm_worker(int size
	, float* data_sub_avg
	, float* data_caret
	, float* data_caret_mul_g
	, float* data_caret_mul_g_add_b
	, float dist_sqrt, float g, float b);
__global__ void k_batch_norm(float* a, float avg, float disp, float g, float b);
__global__ void k_dropout(float* data, float* mask);