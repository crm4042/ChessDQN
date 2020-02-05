#include "NeuralNet.cuh"

#define LEARNING_RATE .000001
#define GRADIENT_CEILING 10

__global__
void getErrorKernel(NeuralNet* nn, double** errors, double** outputs, 
		double* expected, int layer);

__global__
void backpropogationWeightsKernel(NeuralNet* nn, double** outputs, 
		double** error, double*** deltaWeights, int layer);

__global__
void backpropogationBiasesKernel(NeuralNet* nn, double** outputs, 
		double** error, double** deltaBiases, int layer);

__global__
void changeWeights(NeuralNet* nn, double*** deltaWeights, int numOutputs);

__global__
void changeBiases(NeuralNet* nn, double** deltaBiases, int numOutputs);

void backpropogate(NeuralNet* nn, double*** actual, double** expected, 
		int numOutputs);

double** getNeuralMatrix(NeuralNet* nn);

void freeNeuralMatrix(double** matrix, NeuralNet* nn);

double*** getNeuralWeightMatrix(NeuralNet* nn);

void freeNeuralWeightMatrix(double*** matrix, NeuralNet* nn);

