#ifndef SERIALIZEDESERIALIZE
#define SERIALIZEDESERIALIZE

#include <stdio.h>
#include <stdlib.h>

#include "./../NeuralNetwork/NeuralNetwork.cuh"

void serializeNeuralNet(NeuralNet* nn, char* fileName);

NeuralNet* deserializeNeuralNet(char* fileName);

#endif
