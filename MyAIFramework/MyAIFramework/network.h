#pragma once
#include "tools.cuh"
#include "layer.h"

#include <vector>

using namespace std;

#ifndef NETWORK
#define NETWORK
class network {
public:
	vector<layer*>* layers = new vector<layer*>();
	output* result = nullptr;

	network();

	void add(layer* l);

	void addaff(int data_size, int weight_size, bool result, bool dropout);
	void addconv(int data_width, int filter_width, int channel_count);	
	void addpool(int data_width, int fliter_width);

	void set_input(float* data);
	void set_output();
	void set_answer(float* ans);
	void forward(bool train = true);
	void backward();

	void train(float* input, float* answer, bool print = false);
	float* predict(float* input);

	void print_info();
};
#endif