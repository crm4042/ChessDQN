#include <stdio.h>
#include "InitializeComponents.cuh"
#include "./NeuralNetwork/NeuralNetwork.cuh"

#define INPUTS 512
#define HIDDEN 512
#define OUTPUTS 4096

int main(int argc, char* argv[]){
	printf("Initializing game\n");
	if(argc==1){
		char* file1=(char*)calloc(8, sizeof(char));
		char* file2=(char*)calloc(8, sizeof(char));

		strcpy(file1, "nn1.txt\0");
		strcpy(file2, "nn2.txt\0");
		
		getSetup(4, INPUTS, HIDDEN, OUTPUTS, LEAKYRELU, file1, file2);
		
		free(file1);
		free(file2);
	}

	else if(argc==3){
		getSetup(4, INPUTS, HIDDEN, OUTPUTS, LEAKYRELU, argv[0], argv[1]);
	}

	else{
		printf("Wrong number of arguments\n");
	}
}
