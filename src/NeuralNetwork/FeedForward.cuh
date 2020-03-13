#ifndef FEEDFORWARD_CUH
#define FEEDFORWARD_CUH

#include "NeuralNetwork.cuh"

__global__
void feedForwardKernel(NeuralNet* nn, int layer, 
		double*** outputs);

void feedForward(NeuralNet* nn, double*** outputs, 
		double* inputs);

double*** makeExpected(NeuralNet* nn, int numOutputs);

double** makeActual(NeuralNet* nn, int numOutputs);

void freeOutputs(NeuralNet* nn, double*** outputs, int numOutputs);

#endif
