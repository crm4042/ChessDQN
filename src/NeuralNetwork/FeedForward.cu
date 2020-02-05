#include "FeedForward.cuh"


// The feedforward algorithm propogates the inputs given forward.
// Because these are dependant on the layer before it, the threads must be called
// layer by layer. Furthermore, this can only be parallelized with one thread per
// output because it is an nx1 input and has a race condition in that the
// weights/biases can overwrite one another if called to update the same neuron
// in parallel.


/**
  *	The kernal for the feedforward algorithm
  *	Parameter nn: the neural network for the feedforward alforithm
  *	Parameter layer: the layer that is being evaluated
  *	Parameter outputs: the output matrix
  *	Return: nothing
  */

__global__ 
void feedForwardKernel(NeuralNet* nn, int layer, double*** outputs){

	// Loops through the output neurons
	for(int neuron2 = threadIdx.x + (blockIdx.x * blockDim.x); 
			neuron2 < nn->neurons[layer]; 
			neuron2 += blockDim.x*gridDim.x){

		// Sets the initial output to 0
		(*outputs)[layer][neuron2] = 0;

		// Loops through the input neurons and multiplies the weights * the inputs
		for(int neuron1 = 0; neuron1 < nn->neurons[layer-1]; neuron1++){
			(*outputs)[layer][neuron2] += 
				(nn->weights[layer-1][neuron1][neuron2] * 
				(*outputs)[layer-1][neuron1]);
		}

		// Adds the bias
		(*outputs)[layer][neuron2]+=nn->biases[layer-1][neuron2];
		switch(nn->activations[layer-1][neuron2]){
			case BINARY_STEP:
				if((*outputs)[layer][neuron2] <=0){
					(*outputs)[layer][neuron2] = 0;
				}
				else{
					(*outputs)[layer][neuron2] = 1;
				}
				break;
			case LOGISTIC:
				(*outputs)[layer][neuron2] = 
					1/(1+exp(-1*(*outputs)[layer][neuron2]));
				break;
			case TANH:
				(*outputs)[layer][neuron2] = 
					tanh((*outputs)[layer][neuron2]);
				break;
			case RELU:
				if((*outputs)[layer][neuron2] < 0){
					(*outputs)[layer][neuron2] = 0;
				}
				break;
			case LEAKYRELU:
				if((*outputs)[layer][neuron2] < 0){
					(*outputs)[layer][neuron2] *= .01;
				}
				break;
		}
	}
}

/**
  *	Feeds the inputs forward through the neural network.
  *	Parameter nn: the neural network to feed the inputs through
  *	Parameter outputs: a reference to the output matrix
  *	Parameter inputs: the array of inputs
  *	Returns: nothing
  */

void feedForward(NeuralNet* nn, double*** outputs, double* inputs){

	// Loops through the layers
	for(int layer = 0; layer < nn->layers; layer++){

		// If it is the input layer
		if(layer == 0){

			// Sets the input layer to the inputs
			for(int input = 0; input < nn->neurons[layer]; input++){
				(*outputs)[layer][input] = inputs[input];
			}
		}

		else{
			// Calls the feedforward kernel
			feedForwardKernel<<<NUMBLOCKS, BLOCKSIZE>>>(nn, layer, 
					outputs);

			cudaDeviceSynchronize();
		}
	}
}

/**
  *	Makes the output matrix
  *	Parameter nn: the neural net to make the output matrix from
  *	Parameter numOutputs: the number of outputs to create
  *	Return: the output matrix created
  */

double*** makeOutputs(NeuralNet* nn, int numOutputs){
	double*** outputs;
	cudaMallocManaged(&outputs, numOutputs * sizeof(double**));
	
	for(int output = 0; output < numOutputs; output++){
		cudaMallocManaged(&outputs[output], 
				nn->layers * sizeof(double*));

		for(int layer=0; layer < nn->layers; layer++){
			cudaMallocManaged(&outputs[output][layer], 
					nn->neurons[layer] * sizeof(double));
		}
	}
	return outputs;
}

/**
  *	Frees the output matrix
  *	Parameter nn: the neural network
  *	Parameter outputs: the outout matrix to free
  *	Parameter numOutputs: the number of outputs in the matrix
  *	Returns: nothing
  */

void freeOutputs(NeuralNet* nn, double*** outputs, int numOutputs){
	for(int output=0; output < numOutputs; output++){
		for(int layer=0; layer < nn->layers; layer++){
			cudaFree(outputs[output][layer]);
		}
		cudaFree(outputs[output]);
	}
	cudaFree(outputs);
}

