#include "pch.h"

#include "network.h"

network::network() {

}

void network::add(layer* l) {
	layers->push_back(l);
}

void network::addaff(int data_size, int weight_size, bool result, bool dropout) {
	layer* l = new layer(result ? layer_type::RESULT : layer_type::AFF, 1, data_size, data_size, weight_size);
	l->isdropout = dropout;
	layers->push_back(l);
}

void network::addconv(int data_width, int filter_width, int channel_count) {
	layer* l = new layer(layer_type::CONV, data_width, data_width, filter_width, filter_width);
	layers->push_back(l);
}

void network::addpool(int data_width, int filter_width) {
	layer* l = new layer(layer_type::POOLING, data_width, data_width, filter_width, filter_width);
	layers->push_back(l);
}

void network::set_input(float* data) {
	layers->at(0)->set_data(data, layers->at(0)->data_size);
}

void network::set_output() {	
	this->result = new output(layers->at(layers->size() - 1)->w);
}

void network::set_answer(float* ans) {
	this->result->answer = ans;
}

void network::forward(bool train) {
	int i, n = layers->size();
	for (i = 0; i < n - 1; i++) {
		layers->at(i)->forward(layers->at(i + 1), train);
	}
	layers->at(n - 1)->forward(this->result, train);
	result->forward();
}

void network::backward() {
	int i, n = layers->size();
	result->backward();
	layers->at(n - 1)->backward(result);
	for (i = n - 2; i >= 0; i--) {
		layers->at(i)->backward(layers->at(i + 1));
	}
}

void network::train(float* input, float* answer, bool print) {	
	set_input(input);
	set_answer(answer);
	forward();
	backward();		
	if (print) {		
		print_info();
	}	
}

float* network::predict(float* input) {
	set_input(input);
	forward(false);	
	return this->result->data_after_softmax;
}

void network::print_info() {
	int n = layers->size(), i;
	for (i = 0; i < n; i++) {		
		printf("\nlayer %d\n", i);
		layers->at(i)->print_info();
	}
	result->print_info();
}