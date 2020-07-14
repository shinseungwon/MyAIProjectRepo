#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <algorithm>
#include <chrono>
#include <random>
using namespace std;

#define IMAGE_PATH "mnist\\train-images.idx3-ubyte"
#define LABEL_PATH "mnist\\train-labels.idx1-ubyte"
#define BIAS_WEIGHT_PATH "mnist\\biasweight.txt"

#define IMAGE_SIZE 28
#define IMAGE_HEADER_SIZE 16
#define LABEL_HEADER_SIZE 8

#define TOTAL_SIZE 1200 //60000 max
#define MINI_BATCH_SIZE 100 // <= TOTAL_IMG_SIZE

#define LEARN_COUNT 20
#define LEARN_RATE 1
#define DIFF_H 1e-4;
#define DIFF_H_2 2 * 1e-4;

struct Image {
	int num;
	unsigned char image[28][28];
};

float sigmoid(float x);
vector<float>* softmax(vector<float>* a);
vector<vector<float>*>* matrix_multiplication(vector<vector<float>*>* a, vector<vector<float>*>* b);
vector<vector<float>*>* matrix_transpose(vector<vector<float>*>* v);
void set_bias_sigmoid(vector<vector<float>*>* matrix, vector<float>* bias);
void set_sigmoid_backward(vector<vector<float>*>* dy, vector<vector<float>*>* y);

vector<Image>* read_image_label(string image_path, string label_path);
vector<vector<float>*>* read_bias_weight(string biasweightpath);
void write_bias_weight(string path, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);

void print_image(Image* img);
void print_matrix(vector<vector<float>*>* matrix);
vector<float>* convert_image(Image* image);

vector<float>* get_normal_distribution_array(int n);

vector<int>* mini_batch_idx_sort(int n, int count);

vector<float>* predict(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);
vector<vector<vector<float>*>*>* predictlevels(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);

float cross_entropy_error(vector<float>* y, vector<float>* t);

vector<vector<float>*>* get_bias_gradient(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);
vector<vector<vector<float>*>*>* get_weight_gradient(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);

void learn(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);

void backprop(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);

void printpredict(vector<Image>* images, vector<int>* mini_batch, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws);

vector<vector<float>*>* bv;
vector<vector<vector<float>*>*>* wv;

vector<vector<float>*>* bg;
vector<vector<vector<float>*>*>* wg;

int main()
{		
	//initialize	
	srand(static_cast<unsigned int>(time(NULL)));

	vector<Image>* images = read_image_label(IMAGE_PATH, LABEL_PATH);
	//vector<vector<float>*>* vs = read_bias_weight(BIAS_WEIGHT_PATH);
	vector<vector<float>*>* vs = read_bias_weight("mnist\\bwvalue.txt");

	vector<vector<float>*>* bs = new vector<vector<float>*>();
	int i, j, k, l, cnt = 0;
	for (i = 0; i < 3; i++) {
		bs->push_back(vs->at(cnt++));
		//cnt++;
	}
	//bs->push_back(new vector<float>(50, 0.0));
	//bs->push_back(new vector<float>(100, 0.0));
	//bs->push_back(new vector<float>(10, 0.0));

	vector<vector<vector<float>*>*>* ws = new vector<vector<vector<float>*>*>();
	vector<vector<float>*>* wt;

	wt = new vector<vector<float>*>();
	for (i = 0; i < 784; i++) {
		wt->push_back(vs->at(cnt++));
		//wt->push_back(get_normal_distribution_array(50));
		//wt->push_back(new vector<float>(50, 0.5));
	}
	ws->push_back(wt);

	wt = new vector<vector<float>*>();
	for (i = 0; i < 50; i++) {
		wt->push_back(vs->at(cnt++));
		//wt->push_back(get_normal_distribution_array(100));
		//wt->push_back(new vector<float>(100, 0.5));
	}
	ws->push_back(wt);

	wt = new vector<vector<float>*>();
	for (i = 0; i < 100; i++) {
		wt->push_back(vs->at(cnt++));
		//wt->push_back(get_normal_distribution_array(10));
		//wt->push_back(new vector<float>(10, 0.5));
	}
	ws->push_back(wt);
	//~initialize

	//cnn
	int n = images->size(), correct = 0, wrong = 0, seq = 0, max_index;
	float error, max_value, mh, ph;

	vector<int>* mini_batch = mini_batch_idx_sort(TOTAL_SIZE, MINI_BATCH_SIZE);

	//vector<vector<float>*>* bwg = read_bias_weight("mnist\\bwgradient.txt");

	//bg = new vector<vector<float>*>();
	//bg->push_back(bwg->at(0));
	//bg->push_back(bwg->at(1));
	//bg->push_back(bwg->at(2));

	//wg = new vector<vector<vector<float>*>*>();
	//wg->push_back(new vector<vector<float>*>());
	//wg->push_back(new vector<vector<float>*>());
	//wg->push_back(new vector<vector<float>*>());

	//int cntread = 3;
	//for (i = 0; i < 784; i++) {
	//	wg->at(0)->push_back(bwg->at(cntread++));
	//}

	//for (i = 0; i < 50; i++) {
	//	wg->at(1)->push_back(bwg->at(cntread++));
	//}

	//for (i = 0; i < 100; i++) {
	//	wg->at(2)->push_back(bwg->at(cntread++));
	//}

	//test code
	//backprop(&images->at(0), bs, ws);
	//return 0;

	//learn(&images->at(mini_batch->at(0)), bs, ws);
	//return 0;

	//learn
	printpredict(images, mini_batch, bs, ws);
	for (i = 0; i < MINI_BATCH_SIZE; i++) {
		cout << i << " - learn " << images->at(mini_batch->at(i)).num << ' ';
		//learn(&images->at(mini_batch->at(i)), bs, ws);
		backprop(&images->at(mini_batch->at(i)), bs, ws);
		cout << endl;
	}
	printpredict(images, mini_batch, bs, ws);
	//~learn

	//~cnn

	//deallocate
	delete mini_batch;
	for (i = 0; i < ws->size(); i++) {
		delete ws->at(i);
	}
	delete ws;

	for (i = 0; i < vs->size(); i++) {
		delete vs->at(i);
	}
	delete vs;
	delete images;
	//~deallocate

	return 0;
}

float sigmoid(float x) {
	return 1 / (1 + exp(-x));
}

vector<float>* softmax(vector<float>* a) {
	int i, n = a->size();
	float max = 0, expsum = 0;
	vector<float> ac(n);
	vector<float>* res = new vector<float>();
	for (i = 0; i < n; i++) {
		if (a->at(i) > max) {
			max = a->at(i);
		}
	}
	for (i = 0; i < n; i++) {
		ac[i] = a->at(i) - max;
		expsum += exp(ac[i]);
	}
	for (i = 0; i < n; i++) {
		res->push_back(exp(ac[i]) / expsum);
	}

	return res;
}

//n열 m행 X p열 o행 = n열 o행
vector<vector<float>*>* matrix_multiplication(vector<vector<float>*>* a, vector<vector<float>*>* b) {
	int m = a->at(0)->size(), n = a->size(), o = b->at(0)->size(), p = b->size();
	vector<vector<float>*>* res = new vector<vector<float>*>();
	int i, j, k, r = m;

	if (m == p) {
		for (i = 0; i < n; i++) {
			res->push_back(new vector<float>());
		}

		for (i = 0; i < n; i++) {
			for (j = 0; j < o; j++) {
				res->at(i)->push_back(0);
				for (k = 0; k < r; k++) {
					res->at(i)->at(j) += a->at(i)->at(k) * b->at(k)->at(j);
				}
			}
		}
	}

	return res;
}

vector<vector<float>*>* matrix_transpose(vector<vector<float>*>* v) {
	int i, j, n = v->size(), m = v->at(0)->size();
	vector<vector<float>*>* res = new vector<vector<float>*>();
	for (i = 0; i < m; i++) {
		res->push_back(new vector<float>(n, 0.0));
	}

	for (i = 0; i < n; i++) {
		for (j = 0; j < m; j++) {
			res->at(j)->at(i) = v->at(i)->at(j);
		}
	}

	return res;
}

void set_bias_sigmoid(vector<vector<float>*>* matrix, vector<float>* bias) {
	int i, j, m = matrix->size(), n = matrix->at(0)->size();

	for (i = 0; i < m; i++) {
		for (j = 0; j < n; j++) {
			matrix->at(i)->at(j) = sigmoid(matrix->at(i)->at(j) + bias->at(j));
		}
	}
}

void set_sigmoid_backward(vector<vector<float>*>* dy, vector<vector<float>*>* y) {
	int i, j, m = dy->size(), n = dy->at(0)->size();
	float t;
	for (i = 0; i < m; i++) {
		for (j = 0; j < n; j++) {
			t = y->at(i)->at(j);
			dy->at(i)->at(j) *= t * (1 - t);
		}
	}
}

vector<Image>* read_image_label(string image_path, string label_path) {
	int header = 0, row = 0, col = 0, n, m, i = 0, j = 0, k = 0, l = 0, count = 0;

	//read image
	ifstream input_image(image_path, ios::binary);
	//vector<char> bytes_i(istreambuf_iterator<char>(input_image), (istreambuf_iterator<char>()));
	vector<char> bytes_i;
	char headerbuffer[IMAGE_HEADER_SIZE];
	input_image.read(headerbuffer, IMAGE_HEADER_SIZE);
	for (i = 0; i < IMAGE_HEADER_SIZE; i++) {
		bytes_i.push_back(headerbuffer[i]);
	}

	for (i = 0; i < TOTAL_SIZE; i++) {
		char imagebuffer[784];
		input_image.read(imagebuffer, 784);
		for (j = 0; j < 784; j++) {
			bytes_i.push_back(imagebuffer[j]);
		}
	}

	//read label
	ifstream input_label(label_path, ios::binary);
	//vector<char> bytes_l(istreambuf_iterator<char>(input_label), (istreambuf_iterator<char>()));
	vector<char> bytes_l;
	char labelbuffer[LABEL_HEADER_SIZE + TOTAL_SIZE];
	input_label.read(labelbuffer, LABEL_HEADER_SIZE + TOTAL_SIZE);
	for (int i = 0; i < LABEL_HEADER_SIZE + TOTAL_SIZE; i++) {
		bytes_l.push_back(labelbuffer[i]);
	}

	n = bytes_i.size();
	m = bytes_l.size();
	vector<Image>* res = new vector<Image>();

	i = 0;
	l = 0;
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

	while (i < n && l < m && count < TOTAL_SIZE) {

		Image img;
		img.num = (int)(unsigned char)bytes_l[l++];

		for (j = 0; j < IMAGE_SIZE; j++) {
			for (k = 0; k < IMAGE_SIZE; k++) {
				img.image[j][k] = (unsigned char)bytes_i[i++];
			}
		}
		res->push_back(img);
		//print_image(&img);
		count++;
	}

	cout << res->size() << " images" << endl;

	input_image.close();
	input_label.close();

	return res;
}

vector<vector<float>*>* read_bias_weight(string bias_weigh_tpath) {
	ifstream bias_wieght(bias_weigh_tpath);
	vector<char> chars(istreambuf_iterator<char>(bias_wieght), (istreambuf_iterator<char>()));
	int n = chars.size(), i, k;
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

	//for (i = 0; i < vs->size(); i++) {
	//	for (int j = 0; j < vs->operator[](i)->size(); j++) {
	//		cout << vs->operator[](i)->operator[](j) << endl;
	//	}
	//}

	return vs;
}

void write_bias_weight(string path, vector<vector<float>*>* bias, vector<vector<vector<float>*>*>* weight) {
	int i, j, k;

	ofstream txt;
	txt.open(path);
	for (i = 0; i < bias->size(); i++) {
		for (j = 0; j < bias->at(i)->size(); j++) {
			txt << bias->at(i)->at(j) << '/';
		}
		txt << endl;
	}
	for (i = 0; i < weight->size(); i++) {
		for (j = 0; j < weight->at(i)->size(); j++) {
			for (k = 0; k < weight->at(i)->at(j)->size(); k++) {
				txt << weight->at(i)->at(j)->at(k) << '/';
			}
			txt << endl;
		}
	}
	txt.close();
}

void print_image(Image* img) {
	cout << "\nnum : " << img->num << endl;
	int i, j, n = 28;
	for (i = 0; i < n; i++) {
		for (j = 0; j < n; j++) {
			cout << ((int)(unsigned char)img->image[i][j] > 0 ? 1 : 0) << ' ';
		}
		cout << endl;
	}
}

void print_matrix(vector<vector<float>*>* matrix) {
	int i, j, n = matrix->size(), m = matrix->at(0)->size();
	cout << '(' << n << ',' << m << ')' << endl;
	for (i = 0; i < n; i++) {
		for (j = 0; j < m; j++) {
			cout << matrix->at(i)->at(j) << ' ';
		}
		cout << endl;
	}
}

vector<float>* convert_image(Image* image) {
	vector<float>* res = new vector<float>();
	int i, j;
	for (i = 0; i < IMAGE_SIZE; i++) {
		for (j = 0; j < IMAGE_SIZE; j++) {
			res->push_back(image->image[i][j]);
		}
	}
	return res;
}

vector<float>* get_normal_distribution_array(int n) {

	normal_distribution<float> distribution(0.0, 0.5);
	default_random_engine generator;
	generator.seed(rand());
	vector<float>* res = new vector<float>();

	for (int i = 0; i < n; i++) {
		res->push_back(distribution(generator));
	}

	return res;
}

vector<int>* mini_batch_idx_sort(int n, int count) {
	vector<int>* res = new vector<int>();
	int i, x;

	if (count <= n && count >= 0) {
		int* arr = new int[n];
		for (i = 0; i < n; i++) {
			arr[i] = i;
		}
		for (i = n; i > n - count; i--) {
			x = rand() % i;
			res->push_back(arr[x]);
			arr[x] = arr[i - 1];
		}
		delete[] arr;
	}
	sort(res->begin(), res->end());
	return res;
}

float cross_entropy_error(vector<float>* y, vector<float>* t) {
	float res = 0, x;
	int n = y->size(), i;
	if (y->size() == t->size()) {
		for (i = 0; i < n; i++) {
			res += t->at(i) * log(y->at(i) + (1e-7));
		}
	}
	return -res;
}

vector<float>* predict(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {
	vector<vector<float>*>* input = new vector<vector<float>*>();
	input->push_back(convert_image(img));
	int i;

	vector<vector<float>*>* level_1 = matrix_multiplication(input, ws->at(0));
	set_bias_sigmoid(level_1, bs->at(0));

	vector<vector<float>*>* level_2 = matrix_multiplication(level_1, ws->at(1));
	set_bias_sigmoid(level_2, bs->at(1));

	vector<vector<float>*>* level_3 = matrix_multiplication(level_2, ws->at(2));
	set_bias_sigmoid(level_3, bs->at(2));

	vector<float>* output = softmax(level_3->at(0));

	for (i = 0; i < level_1->size(); i++) {
		delete level_1->at(i);
	}
	delete level_1;

	for (i = 0; i < level_2->size(); i++) {
		delete level_2->at(i);
	}
	delete level_2;

	for (i = 0; i < level_3->size(); i++) {
		delete level_3->at(i);
	}
	delete level_3;
	delete input->at(0);
	delete input;

	return output;
}

vector<vector<vector<float>*>*>* predictlevels(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {

	vector<vector<vector<float>*>*>* res = new vector<vector<vector<float>*>*>();

	vector<vector<float>*>* input = new vector<vector<float>*>();
	input->push_back(convert_image(img));
	res->push_back(input);

	vector<vector<float>*>* level_1 = matrix_multiplication(input, ws->at(0));
	set_bias_sigmoid(level_1, bs->at(0));
	res->push_back(level_1);

	vector<vector<float>*>* level_2 = matrix_multiplication(level_1, ws->at(1));
	set_bias_sigmoid(level_2, bs->at(1));
	res->push_back(level_2);

	vector<vector<float>*>* level_3 = matrix_multiplication(level_2, ws->at(2));
	set_bias_sigmoid(level_3, bs->at(2));
	res->push_back(level_3);

	return res;
}

vector<vector<float>*>* get_bias_gradient(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {
	int i, j, k;
	float t, mh, ph, diff;
	vector<float>* mres;
	vector<float>* pres;
	vector<float>* ans = new vector<float>(10, 0);
	ans->at(img->num) = 1;

	vector<vector<float>*>* res = new vector<vector<float>*>();

	for (i = 0; i < bs->size(); i++) {
		res->push_back(new vector<float>(bs->at(i)->size(), 0));
	}

	for (i = 0; i < bs->size(); i++) {
		for (j = 0; j < bs->at(i)->size(); j++) {
			t = bs->at(i)->at(j);
			bs->at(i)->at(j) = t - DIFF_H;
			mres = predict(img, bs, ws);
			mh = cross_entropy_error(mres, ans);
			bs->at(i)->at(j) = t + DIFF_H;
			pres = predict(img, bs, ws);
			ph = cross_entropy_error(pres, ans);
			diff = (ph - mh) / DIFF_H_2;
			res->at(i)->at(j) = diff;
			bs->at(i)->at(j) = t;
			delete mres, pres;
		}
		cout << i << endl;
	}
	delete ans;

	return res;
}

vector<vector<vector<float>*>*>* get_weight_gradient(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {
	int i, j, k;
	float t, mh, ph, diff;
	vector<float>* mres;
	vector<float>* pres;
	vector<float>* ans = new vector<float>(10, 0);
	ans->at(img->num) = 1;

	vector<vector<vector<float>*>*>* res = new vector<vector<vector<float>*>*>();

	for (i = 0; i < ws->size(); i++) {
		res->push_back(new vector<vector<float>*>());
		for (j = 0; j < ws->at(i)->size(); j++) {
			res->at(i)->push_back(new vector<float>(ws->at(i)->at(j)->size(), 0));
		}
	}

	for (i = 0; i < ws->size(); i++) {
		for (j = 0; j < ws->at(i)->size(); j++) {
			for (k = 0; k < ws->at(i)->at(j)->size(); k++) {
				t = ws->at(i)->at(j)->at(k);
				ws->at(i)->at(j)->at(k) = t - DIFF_H;
				mres = predict(img, bs, ws);
				mh = cross_entropy_error(mres, ans);
				ws->at(i)->at(j)->at(k) = t + DIFF_H;
				pres = predict(img, bs, ws);
				ph = cross_entropy_error(pres, ans);
				diff = (ph - mh) / DIFF_H_2;
				res->at(i)->at(j)->at(k) = diff;
				ws->at(i)->at(j)->at(k) = t;
				delete mres, pres;
			}
			cout << i << ' ' << j << endl;
		}
	}
	delete ans;

	return res;
}

void learn(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {

	int i, j, k, l;
	vector<vector<float>*>* bgra;
	vector<vector<vector<float>*>*>* wgra;
	for (i = 0; i < LEARN_COUNT; i++) {
		bgra = get_bias_gradient(img, bs, ws);
		wgra = get_weight_gradient(img, bs, ws);

		for (j = 0; j < bs->size(); j++) {
			for (k = 0; k < bs->at(j)->size(); k++) {
				bs->at(j)->at(k) += bgra->at(j)->at(k) * LEARN_RATE;
			}
		}

		for (j = 0; j < ws->size(); j++) {
			for (k = 0; k < ws->at(j)->size(); k++) {
				for (l = 0; l < ws->at(j)->at(k)->size(); l++) {
					ws->at(j)->at(k)->at(l) += wgra->at(j)->at(k)->at(l) * LEARN_RATE;
				}
			}
		}

		for (j = 0; j < bgra->size(); j++) {
			delete bgra->at(j);
		}
		delete bgra;

		for (j = 0; j < wgra->size(); j++) {
			for (k = 0; k < wgra->at(j)->size(); k++) {
				delete wgra->at(j)->at(k);
			}
			delete wgra->at(j);
		}
		delete wgra;
	}
}

void backprop(Image* img, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {
	int i, j, k, l;
	float diff_b = 0, diff_w = 0;

	for (i = 0; i < LEARN_COUNT; i++) {
		vector<vector<vector<float>*>*>* xs = predictlevels(img, bs, ws);
		vector<vector<float>*>* outputm = new vector<vector<float>*>();
		vector<float>* output = xs->at(3)->at(0);
		outputm->push_back(output);
		vector<vector<float>*>* swlm = new vector<vector<float>*>();
		vector<float>* swl = new vector<float>();
		vector<float>* answer = new vector<float>(10, 0);
		answer->at(img->num) = 1;
		for (j = 0; j < output->size(); j++) {
			swl->push_back(output->at(j) - answer->at(j));
		}
		//print error changes
		cout << cross_entropy_error(output, answer) << ' ';

		swlm->push_back(swl);
		set_sigmoid_backward(swlm, outputm);
		delete answer;
		delete outputm;

		vector<vector<vector<float>*>*>* wst = new vector<vector<vector<float>*>*>();
		wst->push_back(matrix_transpose(ws->at(0)));
		wst->push_back(matrix_transpose(ws->at(1)));
		wst->push_back(matrix_transpose(ws->at(2)));
		vector<vector<vector<float>*>*>* xst = new vector<vector<vector<float>*>*>();
		xst->push_back(matrix_transpose(xs->at(0)));
		xst->push_back(matrix_transpose(xs->at(1)));
		xst->push_back(matrix_transpose(xs->at(2)));

		//backprop
		vector<vector<float>*>* dx_3 = matrix_multiplication(swlm, wst->at(2));
		//print_matrix(dx_3);
		vector<vector<float>*>* wsd_3 = matrix_multiplication(xst->at(2), swlm);
		//print_matrix(wsd_3);
		//print_matrix(wg->at(2));
		set_sigmoid_backward(dx_3, xs->at(2));
		//print_matrix(dx_3);

		vector<vector<float>*>* dx_2 = matrix_multiplication(dx_3, wst->at(1));
		//print_matrix(leveld_2);
		vector<vector<float>*>* wsd_2 = matrix_multiplication(xst->at(1), dx_3);
		//print_matrix(wsd_2);
		set_sigmoid_backward(dx_2, xs->at(1));
		//print_matrix(dx_2);

		vector<vector<float>*>* wsd_1 = matrix_multiplication(xst->at(0), dx_2);
		//print_matrix(wsd_1);
		//~backprop

		vector<vector<vector<float>*>*>* wds = new vector<vector<vector<float>*>*>();
		wds->push_back(wsd_1);
		wds->push_back(wsd_2);
		wds->push_back(wsd_3);

		vector<vector<float>*>* bds = new vector<vector<float>*>();
		bds->push_back(dx_2->at(0));
		bds->push_back(dx_3->at(0));
		bds->push_back(swlm->at(0));

		//set bias, weight
		for (j = 0; j < bs->size(); j++) {
			for (k = 0; k < bs->at(j)->size(); k++) {
				bs->at(j)->at(k) -= bds->at(j)->at(k) * LEARN_RATE;
				//cout << (bds->at(j)->at(k) * LEARN_RATE) << " changed" << endl;
				//cout << bds->at(j)->at(k) << '/' << bg->at(j)->at(k) << endl;
				//diff_b += abs(bds->at(j)->at(k) - bg->at(j)->at(k));
			}
		}

		for (j = 2; j < ws->size(); j++) {
			for (k = 0; k < ws->at(j)->size(); k++) {
				for (l = 0; l < ws->at(j)->at(k)->size(); l++) {
					ws->at(j)->at(k)->at(l) -= wds->at(j)->at(k)->at(l) * LEARN_RATE;
					//cout << (wds->at(j)->at(k)->at(l) * LEARN_RATE) << " changed" << endl;
					//cout << wds->at(j)->at(k)->at(l) << '/' << wg->at(j)->at(k)->at(l) << endl;
					//diff_w += abs(wds->at(j)->at(k)->at(l) - wg->at(j)->at(k)->at(l));
				}
			}
		}
		//~set bias, weight

		//check gradient(only for img(0) at first bias, weight
		//cout << diff_b << '/' << diff_w << endl;
		//break;		

		//deallocation		
		for (j = 0; j < xs->size(); j++) {
			for (k = 0; k < xs->at(j)->size(); k++) {
				delete xs->at(j)->at(k);
			}
			delete xs->at(j);
		}
		delete xs;

		for (j = 0; j < xst->size(); j++) {
			for (k = 0; k < xst->at(j)->size(); k++) {
				delete xst->at(j)->at(k);
			}
			delete xst->at(j);
		}
		delete xst;

		for (j = 0; j < wst->size(); j++) {
			for (k = 0; k < wst->at(j)->size(); k++) {
				delete wst->at(j)->at(k);
			}
			delete wst->at(j);
		}
		delete wst;

		for (j = 0; j < wds->size(); j++) {
			for (k = 0; k < wds->at(j)->size(); k++) {
				delete wds->at(j)->at(k);
			}
			delete wds->at(j);
		}
		delete wds;

		for (j = 0; j < bds->size(); j++) {
			delete bds->at(j);
		}
		delete bds;

		delete swlm;
		//~deallocation

		//cout << "task : " << i << endl;
	}
}

void printpredict(vector<Image>* images, vector<int>* mini_batch, vector<vector<float>*>* bs, vector<vector<vector<float>*>*>* ws) {
	int i, j, seq, max_index, correct = 0, wrong = 0;
	float error, max_value;
	for (i = 0; i < MINI_BATCH_SIZE; i++) {
		seq = mini_batch->at(i);
		cout << "task " << i + 1 << " -> value : " << images->at(seq).num;
		vector<float>* output = predict(&images->at(seq), bs, ws);
		vector<float>* answer = new vector<float>(10, 0);
		answer->at(images->at(seq).num) = 1;
		error = cross_entropy_error(output, answer);

		max_value = 0;
		max_index = -1;
		for (j = 0; j < output->size(); j++) {
			if (output->at(j) > max_value) {
				max_value = output->at(j);
				max_index = j;
			}
		}

		if (max_index == images->at(seq).num) {
			correct++;
		}
		else {
			wrong++;
		}
		cout << " result : " << max_index << " error : " << error
			<< " accuracy : " << correct / (float)(correct + wrong) << endl;

		delete output;
		delete answer;
	}
}