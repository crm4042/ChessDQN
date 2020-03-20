#include "InitializeComponents.cuh"


/**
  *	Sets up a neural network with a specified amount of input and output 
  *	neurons with the same number of hidden nodes per layer and the same 
  *	activations for each neuron
  *	Parameter layers: the amount of layers in the neural net
  *	Parameter inputNeurons: the number of neurons for the input layer
  *	Parameter hiddenNeurons: the number of neurons in each hidden layer
  *	Parameter outputNeurons: the number of neurons for the output layer
  *	Parameter fullActivations: the activations for the entire neural 
  *	network - this is the same for every neuron
  *	Returns: a neural network with the specified attributes
  */

NeuralNet* setupMonotonicNeuralNet(int layers, int inputNeurons, 
	int hiddenNeurons, int outputNeurons, activation fullActivations){

	int* neurons=(int*)calloc(layers, sizeof(int));
	activation** activations=(activation**)calloc(layers-1, 
		sizeof(activation*));

	// Assigns the parameters for the neural net
	for(int layer=0; layer<layers; layer++){

		// The input layer
		if(layer==0){
			neurons[layer]=inputNeurons;
		}

		// The output layer
		else if(layer==layers-1){
			neurons[layer]=outputNeurons;
			activations[layer-1]=(activation*)calloc(outputNeurons, 
				sizeof(activation));

			for(int neuron=0; neuron<outputNeurons; neuron++){
				activations[layer-1][neuron]=fullActivations;
			}
		}

		// The hidden layer
		else{
			neurons[layer]=hiddenNeurons;
			activations[layer-1]=(activation*)calloc(hiddenNeurons, 
				sizeof(activation));

			for(int neuron=0; neuron<hiddenNeurons; neuron++){
				activations[layer-1][neuron]=fullActivations;
			}
		}
	}

	return createNeuralNet(layers, neurons, activations);
}

void setupGame(int layers, int inputNeurons, int hiddenNeurons, 
	int outputNeurons, activation activations, int playerColor, 
	char* file1, char* file2){

	NeuralNet* nn1=setupMonotonicNeuralNet(layers, 
		inputNeurons, hiddenNeurons, 
		outputNeurons, activations);
	NeuralNet* nn2=setupMonotonicNeuralNet(layers, 
		inputNeurons, hiddenNeurons, 
		outputNeurons, activations);

	train(nn1, nn2, playerColor, file1, file2);
}

void setupPausedGame(int playerColor, char* file1, char* file2){
	printf("Deserializing the neural networks\n");
	
	char* buffer=(char*)calloc(8, sizeof(char));
	
	NeuralNet* nn1=deserializeNeuralNet(file1);
	NeuralNet* nn2=deserializeNeuralNet(file2);
	
	train(nn1, nn2, playerColor, file1, file2);
}

void getSetup(int layers, int inputNeurons, int hiddenNeurons, 
	int outputNeurons, activation activations, char* file1, char* file2){
	
	int resume=0;
	int playerColor=-1;

	char* buffer=(char*)calloc(80, sizeof(char));
	
	do{
		printf("Do you want to resume a game?[y/n]\n");
		fgets(buffer, 78, stdin);
	} while(strcmp(buffer, "y\n\0")!=0 && strcmp(buffer, "n\n\0")!=0);

	if(strcmp(buffer, "y\n\0")==0){
		resume=1;
	}

	do{
		printf("Do you want to play?[y/n]\n");
		fgets(buffer, 78, stdin);
	} while(strcmp(buffer, "y\n\0")!=0 && strcmp(buffer, "n\n\0"));
	
	if(strcmp(buffer, "y\n\0")==0){
		do{
			printf("What color do you want to play as? [w/b]\n");
			fgets(buffer, 78, stdin);
		}while(strcmp(buffer, "w\n\0")!=0 && strcmp(buffer, "b\n\0")!=0);

		if(strcmp(buffer, "w\n\0")==0){
			playerColor=0;
		}
		else{
			playerColor=1;
		}
	}

	free(buffer);

	if(resume){
		setupPausedGame(playerColor, file1, file2);
	}
	else{
		setupGame(layers, inputNeurons, hiddenNeurons, outputNeurons, activations, 
			playerColor, file1, file2);
	}
}
