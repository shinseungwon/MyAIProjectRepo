#include "pch.h"

#include "network.h"

using namespace std;

void print_help();
void set_spec(string path);
void set_data(string path, int offset, int size, int count, vector<float*>* target, bool scale);
void set_input(string path, int offset, int size, int count);
void set_answer(string path, int offset, int size, int count);
void train(int count);
void predict(string path, int offset, int size, int count);
void export_weight(string path);
void import_weight(string path);

network* net = nullptr;

vector<float*>* inputs;
vector<float*>* answers;

int main(int argc, char* argv[])
{
	srand(static_cast<unsigned int>(time(NULL)));
	int i;

	//0 : Filename
	for (i = 1; i < argc; i++) {
		cout << argv[i] << endl;
	}

	string type = "", target = "";
	int offset = 0, size = 0, count = 0;

	try {
		while (true) {
			cout << "input command ..." << endl;

			cin >> type;

			if (type == "-h") {
				print_help();
			}
			else if (type == "-ss") {
				cin >> target;
				set_spec(target);
			}
			else if (type == "-si") {
				cin >> target;
				cin >> offset;
				cin >> size;
				cin >> count;
				set_input(target, offset, size, count);
			}
			else if (type == "-sa") {
				cin >> target;
				cin >> offset;
				cin >> size;
				cin >> count;
				set_answer(target, offset, size, count);
			}
			else if (type == "-t") {
				cin >> count;
				train(count);
			}
			else if (type == "-p") {
				cin >> target;
				cin >> offset;
				cin >> size;
				cin >> count;
				predict(target, offset, size, count);
			}
			else if (type == "-ew") {
				cin >> target;
				export_weight(target);
			}
			else if (type == "-iw") {
				cin >> target;
				import_weight(target);
			}
			else if (type == "-x") {
				break;
			}
			else {
				cout << "command starts with '-', try again... (type -h for help)";
			}

			cout << endl;
		};
	}
	catch (const char* e) {
		cout << "Error occured (" << e << ") ..." << endl;
		return -1;
	}

	return 0;
}

void print_help() {
	cout << "MyAIFramework help" << endl;
}

//1 : aff -> data_size, weight_size, result, dropout
//2 : conv -> data_width, filter_width, channel_count
//3 : pool -> data_width, filter_width
void set_spec(string path) {
	cout << "set_spec ..." << endl;

	int i = 0, j = 0;
	ifstream ifstr(path, ios::binary);

	if (ifstr.is_open()) {
		cout << "open file " << path << "..." << endl;

		vector<char> vc(istreambuf_iterator<char>(ifstr), (istreambuf_iterator<char>()));
		delete net;
		net = new network();

		int line[5];
		memset(line, 0, 5 * sizeof(int));
		string s;
		i = -1;
		while (++i < vc.size()) {
			if (vc[i] == '\r') {
				line[j] = stoi(s.c_str());
				s.clear();
				i++;
				j = 0;
				//set network
				switch (line[0]) {
				case 0:
					cout << "wrong layer type or error ..." << endl;
					break;
				case 1://aff, res
					net->addaff(line[1], line[2], line[3], line[4]);
					break;
				case 2://con
					net->addconv(line[1], line[2], line[3]);
					break;
				case 3://poo
					net->addpool(line[1], line[2]);					
					break;
				default:
					break;
				}
				memset(line, 0, 5 * sizeof(int));
			}
			else if (vc[i] == ' ') {
				line[j++] = stoi(s.c_str());
				s.clear();
			}
			else {
				s.push_back(vc[i]);
			}
		}
		ifstr.close();
		net->set_output();
	}
	else {
		cout << "file is not open ..." << endl;
	}
}

void set_data(string path, int offset, int size, int count, vector<float*>* target, bool scale) {
	int i, j;
	ifstream ifstr(path, ios::binary);
	if (ifstr.is_open()) {
		char* offsetbuffer = new char[offset];
		ifstr.read(offsetbuffer, offset);
		delete[] offsetbuffer;

		char* databuffer = new char[size];
		float* datafloatbuffer;
		for (i = 0; i < count; i++) {
			datafloatbuffer = new float[size];
			ifstr.read(databuffer, size);
			for (j = 0; j < size; j++) {
				datafloatbuffer[j] = (float)(unsigned char)databuffer[j] / (scale ? 256.0 : 1.0);
			}
			target->push_back(datafloatbuffer);
		}
		delete[] databuffer;

		ifstr.close();
	}
	else {
		cout << "file is not open ..." << endl;
	}
}

void set_input(string path, int offset, int size, int count) {
	cout << "set_input (" << path << ") ..." << endl;
	inputs = new vector<float*>();
	set_data(path, offset, size, count, inputs, true);
	cout << "completed ..." << endl;
}

void set_answer(string path, int offset, int size, int count) {
	cout << "set_answer (" << path << ") ..." << endl;
	answers = new vector<float*>();
	set_data(path, offset, size, count, answers, false);
	cout << "completed ..." << endl;
}

void train(int count) {
	cout << "train " << count << " counts ..." << endl;
	for (int x = 0; x < count; x++) {
		for (int i = 0; i < inputs->size(); i++) {
			net->train(inputs->at(i), answers->at(i), false);			
			cout << "item " << i << endl;
		}
		cout << "rotation " << x << " ..." << endl;
	}
	cout << "completed ..." << endl;
}

void predict(string path, int offset, int size, int count) {
	cout << "predict (" << path << ") ..." << endl;
	vector<float*>* nominees = new vector<float*>();
	float* res;
	int i, j, maxidx, input_size = net->layers->at(0)->data_size, output_size = net->result->data_size;
	float max;
	set_data(path, offset, size, count, nominees, true);
	for (i = 0; i < nominees->size(); i++) {
		res = net->predict(nominees->at(i));
		for (j = 0; j < output_size; j++) {
			cout << '/' << res[j];
		}
		cout << endl;
	}
	cout << "completed ..." << endl;
}

void export_weight(string path) {
	ofstream ofs(path, ios::binary);
	layer* l;
	int i, j;
	float* weight;
	float* bias;
	char buff[4];	
	if (ofs.is_open()) {		
		for (i = 0; i < net->layers->size(); i++) {
			l = net->layers->at(i);
			weight = mal_cpy_host(l->weight, l->weight_size);
			bias = mal_cpy_host(l->bias, l->bias_size);						
			for (j = 0; j < l->weight_size; j++) {				
				memcpy(buff, &weight[j], 4);				
				ofs.write(buff, 4);
			}

			for (j = 0; j < l->bias_size; j++) {				
				memcpy(buff, &bias[j], 4);				
				ofs.write(buff, 4);
			}

			delete[] weight;
			delete[] bias;
		}		
		ofs.close();
	}
	else {
		cout << "file not created..." << endl;
	}
	
	cout << "completed ..." << endl;
}

void import_weight(string path) {
	ifstream ifs(path, ios::binary);
	layer* l;
	int i, j;
	char buff[4];
	float f;
	float* weight_buff;
	float* bias_buff;
	
	if (ifs.is_open()) {
		for (i = 0; i < net->layers->size(); i++) {			
			l = net->layers->at(i);

			weight_buff = new float[l->weight_size];
			bias_buff = new float[l->bias_size];

			for (j = 0; j < l->weight_size; j++) {
				ifs.read(buff, 4);
				memcpy(&f, buff, 4);
				weight_buff[j] = f;
			}			

			for (j = 0; j < l->bias_size; j++) {
				ifs.read(buff, 4);
				memcpy(&f, buff, 4);
				bias_buff[j] = f;
			}

			cpy_dev(l->weight, weight_buff, l->weight_size);
			cpy_dev(l->bias, bias_buff, l->bias_size);

			delete[] weight_buff;
			delete[] bias_buff;
		}

		ifs.close();
	}
	else {
		cout << "file not opened..." << endl;
	}


	cout << "completed ..." << endl;
}