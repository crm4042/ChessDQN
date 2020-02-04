#ifndef NEURALNET_CUH
#define NEURALNET_CUH

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NUMBLOCKS 4
#define BLOCKSIZE 64

enum activation{LINEAR, BINARY_STEP, LOGISTIC, TANH, 
	RELU, LEAKYRELU};

typedef struct nn{
	int layers;
	int* neurons;
	double** biases;
	double*** weights;
	activation** activations;
} NeuralNet;

NeuralNet* createNeuralNet(int layers, int* neurons, activation** activations);

void printNeuralNet(NeuralNet* nn);

void freeNeuralNet(NeuralNet* nn);

#endif

