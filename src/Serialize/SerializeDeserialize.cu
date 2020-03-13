#include "SerializeDeserialize.cuh"

void serializeNeuralNet(NeuralNet* nn, char* fileName){
	// Opens the file for writing
	FILE* file=fopen(fileName, "w");

	// Writes the layer data
	fprintf(file, "%d\n", nn->layers);

	// Writes the neuron data
	for(int layer=0; layer<nn->layers; layer++){
		fprintf(file, "%d\n", nn->neurons[layer]);
	}

	// Writes the weight data
	for(int layer=0; layer<nn->layers-1; layer++){
		for(int neuron1=0; neuron1<nn->neurons[layer]; neuron1++){
			for(int neuron2=0; neuron2<nn->neurons[layer+1]; neuron2++){
				fprintf(file, "%lf\n", nn->weights[layer][neuron1][neuron2]);
			}
		}
	}

	// Writes the bias data
	for(int layer=0; layer<nn->layers-1; layer++){
		for(int neuron=0; neuron<nn->neurons[layer+1]; neuron++){
			fprintf(file, "%lf\n", nn->biases[layer][neuron]);
		}
	}

	fclose(file);
}

NeuralNet* deserializeNeuralNet(char* fileName){
	FILE* file=fopen(fileName, "r");

	NeuralNet* nn;
	cudaMallocManaged(&nn, 1*sizeof(NeuralNet));

	// Gets the layers
	fscanf(file, "%d\n", &nn->layers);

	// Gets the neuron data
	cudaMallocManaged(&nn->neurons, nn->layers*sizeof(int));
	for(int layer=0; layer<nn->layers; layer++){
		fscanf(file, "%d\n", &nn->neurons[layer]);
	}

	// Gets the weight data
	cudaMallocManaged(&nn->weights, (nn->layers-1)*sizeof(double**));
	for(int layer=0; layer<nn->layers-1; layer++){
		cudaMallocManaged(&nn->weights[layer], nn->neurons[layer]*sizeof(double*));
		for(int neuron1=0; neuron1<nn->neurons[layer]; neuron1++){
			cudaMallocManaged(&nn->weights[layer][neuron1], 
				nn->neurons[layer+1]*sizeof(double));
			for(int neuron2=0; neuron2<nn->neurons[layer]; neuron2++){
				fscanf(file, "%lf\n", &nn->weights[layer][neuron1][neuron2]);
				printf("Layer=%d\tNeuron1=%d\tNeuron2=%d\tWeight=%lf\n", layer, neuron1, neuron2, nn->weights[layer][neuron1][neuron2]);
			}
		}
	}

	// Gets the bias data
	cudaMallocManaged(&nn->biases, (nn->layers-1)*sizeof(double*));
	for(int layer=0; layer<nn->layers-1; layer++){
		cudaMallocManaged(&nn->biases[layer], nn->neurons[layer+1]*sizeof(double));
		for(int neuron=0; neuron<nn->neurons[layer+1]; neuron++){
			fscanf(file, "%lf\n", &nn->biases[layer][neuron]);
		}
	}

	fclose(file);

	return nn;
}
