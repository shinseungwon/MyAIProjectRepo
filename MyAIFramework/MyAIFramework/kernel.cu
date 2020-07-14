#include "kernel.cuh"

using namespace std;

//n : col count ( thread count )
__global__ void k_update_delta(float* weight, float* delta, int width, float lr) {
	int idx = blockIdx.x * width + threadIdx.x;
	weight[idx] -= lr * delta[idx];
}

__global__ void k_add_bias(int n, float* a, float* bias) {	
	int idx = blockIdx.x * n + threadIdx.x;
	a[idx] += *bias;
}

__global__ void k_add_bias_array(int n, float* a, float* bias) {
	int idx = blockIdx.x * n + threadIdx.x;
	a[idx] += bias[idx];
}

__global__ void k_relu(int n, float* a) {
	int idx = blockIdx.x * n + threadIdx.x;
	if (a[idx] < 0) a[idx] = 0;
}

__global__ void k_relu_backward(float* dy, float* y, int m, int n) {
	int i = blockIdx.x, j = threadIdx.x, seq = n * i + j;
	dy[seq] *= y[seq] < 0 ? 0 : 1;
}

__global__ void k_pooling(float* a, int m, int n, float* b) {
	int bl = blockIdx.x, th = threadIdx.x;
	int bs = bl * n, ts = th * n, rs = bl * (m / n) + th, tmp;
	int i, j;
	b[rs] = 0;
	for (i = bs; i < bs + n; i++) {
		for (j = ts; j < ts + n; j++) {
			tmp = i * m + j;
			b[rs] = a[tmp] > b[rs] ? a[tmp] : b[rs];
		}
	}
}

//d : delta, a : pooling data, m : pooling size, b : cnn data, n : cnn size, c : pooling backward result
__global__ void k_pooling_backward(float* d, float* a, int m, float* b, int n, float* c) {
	int bl = blockIdx.x, th = threadIdx.x;
	int cnnIdx = bl * n + th;
	int poolIdx = (bl / 2) * m + (th / 2);
	c[cnnIdx] = a[poolIdx] == b[cnnIdx] ? d[poolIdx] : 0;
}

//<<<m, p>>> matrix, {n == o} (m x n) x (o x p) = (m x p)
__global__ void k_matrix_multiplication(float* a, int m, int n, float* b, int o, int p, float* res) {
	int bi = blockIdx.x, ti = threadIdx.x, sb = bi * n, st = ti, c = bi * p + ti, i;
	res[c] = 0;
	for (i = 0; i < n; i++) {
		res[c] += a[sb + i] * b[st];
		st += p;
	}
}

//<<<m - n + 1, m - n + 1>>>
__global__ void k_matrix_convolution_multiplication(float* a, int m, float* b, int n, float* c) {
	int bl = blockIdx.x, th = threadIdx.x;
	int o = m - n + 1, p = bl * o + th;
	int i, j;
	c[p] = 0;
	for (i = bl; i < bl + n; i++) {
		for (j = th; j < th + n; j++) {
			c[p] += a[i * m + j] * b[(i - bl) * n + (j - th)];
		}
	}
}

__global__ void k_matrix_transpose(float* a, int m, int n, float* b) {
	int j = blockIdx.x;
	int i = threadIdx.x;
	b[i * m + j] = a[j * n + i];
}

__global__ void k_matrix_reverse(float* a, float* b, int n) {
	int bl = blockIdx.x, th = threadIdx.x;
	int idx = bl * n + th;
	int ridx = (n - bl - 1) * n + (n - th - 1);
	b[idx] = a[ridx];
}

__global__ void k_make_padding_matrix(float* a, int n, float* b, int p) {
	int bl = blockIdx.x, th = threadIdx.x;
	int idx = bl * n + th;
	int pad_width = n + 2 * p;
	int pad_bl = p - 1 + bl, pad_th = p - 1 + th;
	int pad_idx = pad_bl * pad_width + pad_th;
	b[pad_idx] = a[idx];
}

__global__ void k_set_weight_changes(float* ws, float* wds, int h, int w, float lr) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	int seq = bx * w + tx;
	ws[seq] -= wds[seq] * lr;
}

__global__ void k_set_bias_changes(float* bs, float* bds, int n, float lr) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	bs[tx] -= bds[tx] * lr;
}

__global__ void k_get_dist_worker(int size, float avg, float* data, float* data_sub_avg, float* data_sub_avg_sq) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	data_sub_avg[tx] = data[tx] - avg;
	data_sub_avg_sq[tx] = data_sub_avg[tx] * data_sub_avg[tx];
}

__global__ void k_batch_norm_worker(int size
	, float* data_sub_avg
	, float* data_caret
	, float* data_caret_mul_g
	, float* data_caret_mul_g_add_b
	, float dist_sqrt, float g, float b) {
	int bx = blockIdx.x;
	int tx = threadIdx.x;
	data_caret[tx] = data_sub_avg[tx] / dist_sqrt;
	data_caret_mul_g[tx] = data_caret[tx] * g;
	data_caret_mul_g_add_b[tx] = data_caret_mul_g[tx] + b;
}

__global__ void k_batch_norm(float* a, float avg, float disp, float g, float b) {
	int i = threadIdx.x;
	a[i] = g * ((a[i] - avg) / sqrt(disp * disp + 10e-7)) + b;
}

__global__ void k_dropout(float* data, float* mask) {
	int i = threadIdx.x;
	if (mask[i] == 0) {
		data[i] = 0;
	}
}