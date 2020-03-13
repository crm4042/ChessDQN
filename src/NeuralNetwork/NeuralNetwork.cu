#include "NeuralNetwork.cuh"

/**
  *	Creates a neural network with the specified number of layers
  *	and neurons
  *	Parameter layers: the number of layers in the neural network
  *	Parameter neurons: an array with the number of neurons for each layer
  *	Returns: a NeuralNet with the specified layers/neurons
  */

NeuralNet* createNeuralNet(int layers, int* neurons, activation** activations){
	// Seeds the randomizer
	srand(time(NULL));

	// Creates the neural net
	NeuralNet* nn;
	cudaMallocManaged(&nn, sizeof(NeuralNet));
	
	// Sets the attributes of the neural net
	nn->layers = layers;
	cudaMallocManaged(&nn->neurons, layers*sizeof(int));
	for(int layer=0; layer<layers; layer++){
		nn->neurons[layer] = neurons[layer];
	}

	// Allocates memory for the activation function enum
	cudaMallocManaged(&nn->activations, 
			(layers - 1) * sizeof(activation*));

	// Allocates memory for the weights/biases and assigns random values
	cudaMallocManaged(&nn->biases, (layers - 1) * sizeof(double*));
	cudaMallocManaged(&nn->weights, (layers - 1) * sizeof(double**));
	
	for(int layer = 0; layer < layers-1; layer++){

		cudaMallocManaged(&nn->activations[layer], 
				neurons[layer + 1] *sizeof(activation));

		cudaMallocManaged(&nn->biases[layer], 
				neurons[layer+1] * sizeof(double));
		cudaMallocManaged(&nn->weights[layer], 
				neurons[layer] * sizeof(double*));

		for(int neuron1 = 0; neuron1 < neurons[layer+1]; neuron1++){
			nn->biases[layer][neuron1] = double(rand())/RAND_MAX;
			nn->activations[layer][neuron1] = 
				activations[layer][neuron1];
		}

		for(int neuron1 = 0; neuron1 < neurons[layer]; neuron1++){
			cudaMallocManaged(&nn->weights[layer][neuron1], 
					neurons[layer+1] * sizeof(double));
			
			for(int neuron2 = 0; neuron2 < neurons[layer+1]; 
					neuron2++){
				nn->weights[layer][neuron1][neuron2] = 
					double(rand())/RAND_MAX;
			}
		}
	}

	return nn;
}

void freeNeuralNet(NeuralNet* nn){
	for(int layer = 0; layer < nn->layers-1; layer++){
		for(int neuron1=0; neuron1 < nn->neurons[layer]; neuron1++){
			cudaFree(nn->weights[layer][neuron1]);
		}
		cudaFree(nn->activations[layer]);
		cudaFree(nn->biases[layer]);
		cudaFree(nn->weights[layer]);
	}
	cudaFree(nn->neurons);
	cudaFree(nn->activations);
	cudaFree(nn->biases);
	cudaFree(nn->weights);
	cudaFree(nn);
}

void printNeuralNet(NeuralNet* nn){
	printf("Layers = %d\n", nn->layers);
	for(int layer = 0; layer < nn->layers; layer++){

		printf("\nLayer %d Neurons %d\n", layer, nn->neurons[layer]);

		// Prints the biases
		if(layer != 0){
			printf("Activations for this layer:\n");
			for(int neuron1 = 0; neuron1 < nn->neurons[layer]; 
					neuron1++){
				printf("%d\t", nn->activations[layer-1][neuron1]);
			}
			printf("\n");
			printf("Biases for this layer:\n");
			for(int neuron1 = 0; neuron1 < nn->neurons[layer]; 
					neuron1++){
				printf("%f\t", nn->biases[layer-1][neuron1]);
			}
			printf("\n");
		}
		else{
			printf("No biases in this layer\n");
		}

		// Prints the weights
		if(layer != nn->layers - 1){
			printf("Weights for this layer:\n");
			for(int neuron1 = 0; neuron1 < nn->neurons[layer];
					neuron1++){
				for(int neuron2 = 0; 
						neuron2 < nn->neurons[layer+1];
						neuron2++){
					printf("%f\t", nn->weights[layer]\
							[neuron1][neuron2]);
				}
				printf("\n");
			}
		}
	}
}

