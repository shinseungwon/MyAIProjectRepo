#pragma once
#include "tools.cuh"

#ifndef OUTPUT
#define OUTPUT
class output {
public:
	int data_size = 0;
	float* data_dev;
	float* data_before_softmax = 0;
	float* data_after_softmax = 0;
	float* answer = 0;
	float cross_entrophy_error = 0;

	float* data_grad = 0;

	output(int size);
	void set_answer(float* answer);

	void forward();
	void backward();

	void print_info();
};
#endif