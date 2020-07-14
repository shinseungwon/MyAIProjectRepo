#include "pch.h"

#include "layer.h"

using namespace std;

layer::layer(layer_type type, int x, int y, int z, int w) {
	this->type = type;
	this->x = x;
	this->y = y;
	this->z = z;
	this->w = w;
	this->data_size = x * y;
	this->weight_size = z * w;

	data = mal_dev(data_size);
	data_grad = mal_dev(data_size);
	weight = mal_dev(weight_size);
	weight_grad = mal_dev(weight_size);

	if (type == layer_type::AFF || type == layer_type::RESULT) {
		bias_size = data_size;
		bias = mal_dev(bias_size);
		bias_grad = mal_dev(bias_size);
		generate_weight(weight, weight_size, 0.5, 0.2);
		bn_size = x * w;
		dropout_mask = mal_dev(bn_size);
	}
	else if (type == layer_type::CONV) {
		bias_size = 1;
		bias = mal_dev(bias_size);
		bias_grad = mal_dev(bias_size);
		generate_weight(weight, weight_size, 0.5, 0.4);
		bn_size = pow(x - z + 1, 2);
	}
	else if (type == layer_type::POOLING) {
		weight_size = 0;
		bias_size = 0;
	}
	else {
		bias_size = 0;
	}
	
	if (type == layer_type::AFF || type == layer_type::CONV) {
		bn_data = mal_dev(bn_size);
		bn_data_sub_avg = mal_dev(bn_size);
		bn_data_sub_avg_sq = mal_dev(bn_size);
		bn_data_caret = mal_dev(bn_size);
		bn_data_caret_mul_g = mal_dev(bn_size);
		bn_data_caret_mul_g_add_b = mal_dev(bn_size);

		bn_h_data = new float[bn_size];
		bn_h_data_sub_avg = new float[bn_size];
		bn_h_data_sub_avg_sq = new float[bn_size];
		bn_h_data_caret = new float[bn_size];
		bn_h_data_caret_mul_g = new float[bn_size];
		bn_h_data_caret_mul_g_add_b = new float[bn_size];

		bn_h_d_data_caret = new float[bn_size];
		bn_h_d_data_caret_mul_g = new float[bn_size];
		bn_h_d_data_caret_mul_g_add_b = new float[bn_size];

		dxu1 = new float[bn_size];
		dsq = new float[bn_size];
		xu = new float[bn_size];
		dxu2 = new float[bn_size];
		dx1 = new float[bn_size];
		dx2 = new float[bn_size];
		dx = new float[bn_size];
	}
}

void layer::set_data(float* data, int size) {
	if (this->data_size != size) {
		throw exception("Size not match");
	}
	this->data = mal_cpy_dev(data, size);
}

void layer::change_weight(float* changes, float lr) {
	update_delta(weight, changes, z, w, lr);	
}

void layer::change_bias(float* changes, float lr) {
	update_delta(bias, changes, 1, bias_size, lr);	
}

void layer::forward(output* next, bool train) {
	forward_internal(next->data_dev, train);
}

void layer::forward(layer* next, bool train) {
	forward_internal(next->data, train);
}

void layer::forward_internal(float* next_data, bool train) {

	if (this->type == layer_type::AFF || this->type == layer_type::RESULT) {

		matrix_multiplication(data, this->x, this->y, weight, this->z, this->w, next_data);
		add_bias_array(y, next_data, bias);

		if (isdropout && train) {
			int drcount = bn_size * dr;			
			float* mask_host = mini_batch_mask(bn_size, drcount < 1 ? 1 : drcount);
			cpy_dev(dropout_mask, mask_host, bn_size);
			dropout(next_data, dropout_mask, bn_size);
			delete[] mask_host;
		}

		if (this->type == layer_type::AFF) {
			relu(y, next_data);
			batch_norm(next_data, y);
		}
	}
	else if (this->type == layer_type::CONV) {
		int dst_width = x - z + 1;
		int dst_size = dst_width * dst_width;
		
		matrix_convolution_multiplication(data, x, weight, z, next_data);
		add_bias(dst_width, next_data, bias);		
		
		relu(dst_width * dst_width, next_data);
		batch_norm(next_data, dst_size);
	}
	else if (this->type == layer_type::POOLING) {
		pooling(data, x, z, next_data);
	}
	else {

	}
}

void layer::backward(output* next) {
	backward_internal(next->data_grad, next->data_dev);
}

void layer::backward(layer* next) {
	backward_internal(next->data_grad, next->data);
}

void layer::backward_internal(float* next_grad, float* next_data) {
	if (this->type == layer_type::AFF || this->type == layer_type::RESULT) {
		if (this->type == layer_type::AFF) {
			batch_norm_backward(next_grad, next_data, this->x * this->w);
			relu_backward(next_grad, next_data, this->x, this->w);
		}

		if (isdropout) {
			dropout(next_grad, dropout_mask, bn_size);
		}

		float* weight_trans = mal_dev(weight_size);
		matrix_transpose(weight, this->z, this->w, weight_trans);
		matrix_multiplication(next_grad, this->x, this->w, weight_trans, w, z, data_grad);
		matrix_multiplication(data, this->y, this->x, next_grad, this->z, this->w, weight_grad); // data_trans * next_grad
		set_weight_changes(weight, weight_grad, z, w, this->lr);
		set_bias_changes(bias, next_grad, w, this->lr);
		free_dev(weight_trans);
	}
	else if (this->type == layer_type::CONV) {
		int delta_width = x - z + 1;
		int delta_size = delta_width * delta_width;

		batch_norm_backward(next_grad, next_data, delta_size);
		relu_backward(next_grad, next_data, delta_width, delta_width);

		float* delta_host = new float[delta_size];
		cpy_host(delta_host, next_data, delta_size);

		float bias_host = 0;
		for (int i = 0; i < delta_size; i++) {
			bias_host += delta_host[i];
		}
		cpy_dev(bias_grad, &bias_host, 1);

		matrix_convolution_multiplication(data, x, next_grad, delta_width, weight_grad);

		set_weight_changes(weight, weight_grad, z, w, this->lr);

		int padding_matrix_width = delta_width + 2 * (z - 1);
		int padding_matrix_size = padding_matrix_width * padding_matrix_width;
		float* padding_matrix = mal_dev(padding_matrix_size);
		
		make_padding_matrix(next_grad, delta_width, padding_matrix, z - 1);

		float* weight_reverse_matrix = mal_dev(weight_size);
		matrix_reverse(weight, weight_reverse_matrix, z, w);

		matrix_convolution_multiplication(padding_matrix, padding_matrix_width, weight_reverse_matrix, z, data_grad);
	}
	else if (this->type == layer_type::POOLING) {
		int pooling_size = x / z;
		pooling_backward(next_grad, next_data, pooling_size, data, x, weight);
	}	
	else {

	}
}

void layer::batch_norm(float* next_data, int data_size) {
	int i;
	float* data_host = new float[bn_size];
	cpy_dev_to_dev(bn_data, next_data, bn_size);	

	//get avg	
	cpy_host(data_host, next_data, bn_size);
	bn_avg = 0;
	for (i = 0; i < bn_size; i++) {
		bn_avg += data_host[i];
	}
	bn_avg /= bn_size;
	//~get avg

	//get dist
	get_dist_worker(bn_size, bn_avg, bn_data, bn_data_sub_avg, bn_data_sub_avg_sq);
	cpy_host(data_host, bn_data_sub_avg_sq, bn_size);
	bn_dist = 0;
	for (i = 0; i < bn_size; i++) {
		bn_dist += data_host[i];
	}
	bn_dist /= bn_size;
	//~get dist	
	
	batch_norm_worker(bn_size
		, bn_data
		, bn_data_sub_avg
		, bn_data_sub_avg_sq
		, bn_data_caret
		, bn_data_caret_mul_g
		, bn_data_caret_mul_g_add_b
		, bn_avg, bn_dist, bn_g, bn_b);
	cpy_dev_to_dev(next_data, bn_data_caret_mul_g_add_b, bn_size);

	cpy_host(bn_h_data, bn_data, bn_size);
	cpy_host(bn_h_data_sub_avg, bn_data_sub_avg, bn_size);
	cpy_host(bn_h_data_sub_avg_sq, bn_data_sub_avg_sq, bn_size);
	cpy_host(bn_h_data_caret, bn_data_caret, bn_size);
	cpy_host(bn_h_data_caret_mul_g, bn_data_caret_mul_g, bn_size);
	cpy_host(bn_h_data_caret_mul_g_add_b, bn_data_caret_mul_g_add_b, bn_size);

	delete[] data_host;
}

void layer::batch_norm_backward(float* next_delta, float* next_data, int size) {
	int i, j, k;

	float* delta_host = new float[size];
	cpy_host(delta_host, next_delta, size);

	//step 9
	cpy_host(bn_h_d_data_caret_mul_g, next_delta, size);

	bn_db = 0;
	for (i = 0; i < size; i++) {
		bn_db += delta_host[i];
	}
	
	//step 8
	for (i = 0; i < size; i++) {
		bn_h_d_data_caret[i] = bn_h_d_data_caret_mul_g[i] * bn_g;
	}

	bn_dg = 0;
	for (i = 0; i < size; i++) {
		bn_dg += bn_h_d_data_caret_mul_g[i] * bn_h_data_caret[i];
	}

	//step 7	
	float ivar = 1 / sqrt(bn_dist + 10e-7);
	for (i = 0; i < size; i++) {		
		dxu1[i] = bn_h_d_data_caret[i] * ivar;
	}

	float divar = 0;
	for (i = 0; i < size; i++) {
		divar += bn_h_d_data_caret[i] * bn_h_data_sub_avg[i];
	}

	//step 6
	float sqrtvar = 1 / ivar;
	float dsqrtvar = divar / pow(sqrtvar, 2) * -1;

	//step 5
	float var = bn_dist;
	float dvar = 0.5 / sqrt(var + 10e-7) * dsqrtvar;

	//step 4	
	for (i = 0; i < size; i++) {
		dsq[i] = dvar / size;
	}

	//step 3
	xu = bn_h_data_sub_avg;	
	for (i = 0; i < size; i++) {
		dxu2[i] = 2 * xu[i] * dsq[i];
	}

	//step 2	
	for (i = 0; i < size; i++) {
		dx1[i] = dxu1[i] + dxu2[i];
	}

	float du = 0;
	for (i = 0; i < size; i++) {
		du += dxu1[i] + dxu2[i];
	}
	du *= -1;

	//step 1	
	for (i = 0; i < size; i++) {
		dx2[i] = du / size;
	}

	//step 0	
	for (i = 0; i < size; i++) {
		dx[i] = dx1[i] + dx2[i];
	}

	bn_g -= bn_dg * lr;
	bn_b -= bn_db * lr;

	cpy_dev(next_delta, dx, size);
}

void layer::print_info() {		
	print("data info", data, data_size, y);
	print("data grad info", data_grad, data_size, y);
	if (type == layer_type::AFF || type == layer_type::RESULT) {
		print("bias info", bias, data_size, y);
		print("bias grad info", bias_grad, data_size, y);
	}	
	print("weight info", weight, weight_size, w);
	print("weight grad info", weight_grad, weight_size, w);	
}