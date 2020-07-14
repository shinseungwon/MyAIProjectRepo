#pragma once
#include "tools.cuh"
#include "output.h"

#ifndef LAYER
#define LAYER
enum class layer_type { AFF, CONV, POOLING, RESULT, NONE };

class layer {
public:
	layer_type type = layer_type::NONE;
	bool isdropout = false;	

	float* data = 0;
	float* weight = 0;
	float* bias = 0;

	float* data_grad = 0;
	float* weight_grad = 0;
	float* bias_grad = 0;

	int data_size = 0;
	int weight_size = 0;
	int bias_size = 0;
	int x = 0;
	int y = 0;
	int z = 0;
	int w = 0;

	float lr = 0.1; //learning rate
	float dr = 0.3; //dropout rate

	float* dropout_mask = 0;

	//batch_normalization
	int bn_size = 0;
	float bn_avg = 0;
	float bn_dist = 1;	
	float bn_g = 1;
	float bn_dg = 0;
	float bn_b = 0;
	float bn_db = 0;

	float* bn_data = 0;
	float* bn_data_sub_avg = 0;
	float* bn_data_sub_avg_sq = 0;
	float* bn_data_caret = 0;
	float* bn_data_caret_mul_g = 0;
	float* bn_data_caret_mul_g_add_b = 0;

	float* bn_h_data = 0;
	float* bn_h_data_sub_avg = 0;
	float* bn_h_data_sub_avg_sq = 0;
	float* bn_h_data_caret = 0;
	float* bn_h_data_caret_mul_g = 0;
	float* bn_h_data_caret_mul_g_add_b = 0;

	float* bn_h_d_data_caret = 0;
	float* bn_h_d_data_caret_mul_g = 0;
	float* bn_h_d_data_caret_mul_g_add_b = 0;

	float* dxu1 = 0;
	float* dsq = 0;
	float* xu = 0;
	float* dxu2 = 0;
	float* dx1 = 0;
	float* dx2 = 0;
	float* dx = 0;
	//~batch normalization

	layer(layer_type type, int x, int y, int z, int w);	

	void set_data(float* data, int size);
	void change_weight(float* changes, float lr);
	void change_bias(float* changes, float lr);

	void forward(output* next, bool train = true);
	void forward(layer* next, bool train = true);
	void forward_internal(float* next_data, bool train);
	
	void backward(output* next);
	void backward(layer* next);
	void backward_internal(float* next_grad, float* next_data);
	
	void batch_norm(float* next_data, int data_size);
	void batch_norm_backward(float* delta, float* _data, int size);

	void print_info();
};
#endif