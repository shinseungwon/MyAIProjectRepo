#include "pch.h"

#include "output.h"

using namespace std;

output::output(int size) {
	this->data_size = size;
	data_dev = mal_dev(data_size);
	data_grad = mal_dev(data_size);
	data_before_softmax = new float[size];
	data_after_softmax = new float[size];
	answer = new float[size];

	for (int i = 0; i < size; i++) {
		data_before_softmax[i] = 0;
		data_after_softmax[i] = 0;
		answer[i] = 0;
	}
}

void output::set_answer(float* answer) {
	this->answer = answer;
}

void output::forward() {	
	cpy_host(data_before_softmax, data_dev, data_size);
	softmax(data_before_softmax, data_after_softmax, data_size);
	this->cross_entrophy_error = get_cross_entrophy_error(this->answer, this->data_after_softmax, data_size);
}

void output::backward() {
	float* dy = new float[this->data_size];
	for (int i = 0; i < this->data_size; i++) {
		dy[i] = data_after_softmax[i] - answer[i];
	}

	cpy_dev(data_grad, dy, this->data_size);
}

void output::print_info() {
	int i;
	printf("\noutput data info -> size : %d, cee : %f\n", this->data_size, cross_entrophy_error);
	printf("data before softmax : ");
	for (i = 0; i < this->data_size; i++) {
		printf("%.2f ", data_before_softmax[i]);
	}
	printf("\ndata after softmax : ");
	for (i = 0; i < this->data_size; i++) {
		printf("%.2f ", data_after_softmax[i]);
	}
	printf("\n");
}
