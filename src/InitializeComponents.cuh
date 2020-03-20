#ifndef INITIALIZECOMPONENTS
#define INITIALIZECOMPONENTS

#include "./Chess/Game.cuh"
#include "./Chess/VerifyMove.cuh"
#include "./NeuralNetwork/NeuralNetwork.cuh"

NeuralNet* setupMonotonicNeuralNet(int layers, int inputNeurons, 
	int hiddenNeurons, int outputNeurons, activation fullActivations);

void setupGame(int layers, int inputNeurons, int hiddenNeurons, 
	int outputNeurons, activation activations, int playerColor, char* file1, char* file2);

void setupPausedGame(int playerColor, char* file1, char* file2);

void getSetup(int layers, int inputNeurons, int hiddenNeurons, 
	int outputNeurons, activation activations, char* file1, char* file2);

#endif
