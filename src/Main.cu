#include <stdio.h>
#include "InitializeComponents.cuh"
#include "./NeuralNetwork/NeuralNetwork.cuh"

#define INPUTS 512
#define HIDDEN 512
#define OUTPUTS 4096

int main(){
	printf("Initializing game\n");
	setupGame(4, INPUTS, HIDDEN, OUTPUTS, LEAKYRELU);
}
