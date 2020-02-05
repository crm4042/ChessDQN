#include "Backpropogation.cuh"
#include "NeuralNet.cuh"

/**
  *	Gets the errors associated with each neuron's output
  *	Parameter nn: the neural network to get the error for
  *	Parameter errors: the matrix to put the errors in
  *	Parameter layer: the layer to get the error for
  *	Return: nothing
  */

__global__
void getErrorKernel(NeuralNet* nn, double** errors, double** outputs, double* expected, int layer){

	for(int neuron1 = threadIdx.x + (blockDim.x * blockIdx.x); neuron1 < nn ->neurons[layer]; neuron1 += blockDim.x*gridDim.x){

		// The last layer's error
		if(layer == nn->layers - 1){
			//printf("actual - expected = %f - %f = %f\n", outputs[nn->layers - 1][neuron1], expected[neuron1], outputs[nn->layers - 1][neuron1]-expected[neuron1]);

			errors[layer][neuron1] = outputs[nn->layers - 1][neuron1] - expected[neuron1];
		}
	
		// The remaining layers' errors
		else{

			// Zeros the error
			errors[layer][neuron1] = 0;
	
			// Uses the derivative of the outputs with respect to the inputs
			for(int neuron2 = 0; neuron2 < nn->neurons[layer+1]; neuron2++){
				switch(nn->activations[layer][neuron2]){
					case LINEAR:
						errors[layer][neuron1] += 
						       (errors[layer + 1][neuron2] * 
							nn -> weights[layer][neuron1][neuron2]);
						break;
	
					case BINARY_STEP:
						break;
	
					case LOGISTIC:
						errors[layer][neuron1] += 
							(errors[layer + 1][neuron2] * 
							 nn -> weights[layer][neuron1][neuron2] * 
							 outputs[layer + 1][neuron2] * 
							 (1 - outputs[layer + 1][neuron2]));
						break;
	
					case TANH:
						errors[layer][neuron1] += 
							(errors[layer + 1][neuron2] * 
							 nn -> weights[layer][neuron1][neuron2] * 
							 (1 - (outputs[layer + 1][neuron2] * 
							       outputs[layer + 1][neuron2])));
						break;
	
					case RELU:
						if(outputs[layer + 1][neuron2] > 0){
							errors[layer][neuron1] += 
								(errors[layer + 1][neuron2] * 
							 	nn -> weights[layer][neuron1][neuron2]);
						}
						break;
	
					case LEAKYRELU:
						if(outputs[layer + 1][neuron2] < 0){
							errors[layer][neuron1] += 
								(errors[layer + 1][neuron2] * 
								 nn -> weights[layer][neuron1][neuron2] * .01);
						}
	
						else{
							errors[layer][neuron1] += 
								(errors[layer + 1][neuron2] * 
								 nn -> weights[layer][neuron1][neuron2]);
						}
						break;
				}
			}
		}
	}
}

/**
  *	Backpropogates the weights in the neural net
  *	Parameter nn: the neural network to backpropogate
  *	Parameter layer: the layer that is being backpropogated
  *	Returns: nothing
  */

__global__
void backpropogationWeightsKernel(NeuralNet* nn, double** outputs, 
		double** error, double*** deltaWeights, int layer){

	for(int neuron1 = threadIdx.x + (blockDim.x* blockIdx.x); neuron1 < nn -> neurons[layer]; neuron1 += (blockDim.x * gridDim.x)){
		for(int neuron2 = threadIdx.y + (blockDim.y * blockIdx.y); neuron2 < nn->neurons[layer + 1]; neuron2 += (blockDim.y * gridDim.y)){

			switch(nn->activations[layer][neuron2]){
				case LINEAR:
					deltaWeights[layer][neuron1][neuron2] += 
						(LEARNING_RATE * 
						 error[layer + 1][neuron2] * 
						 outputs[layer][neuron1]);
					break;
		
				case BINARY_STEP:
					// This has a derivative of 0 everywhere so 
					// nothing needs to be added
					break;
		
				case LOGISTIC:
					deltaWeights[layer][neuron1][neuron2] +=
						(LEARNING_RATE * error[layer + 1][neuron2] *
						 outputs[layer][neuron1] * 
						 (outputs[layer][neuron2] * 
						  (1 - outputs[layer][neuron2])));
					break;
		
				case TANH:
					deltaWeights[layer][neuron1][neuron2] +=
						(LEARNING_RATE * error[layer + 1][neuron2] *
						 outputs[layer][neuron1] * 
						 (1 - (outputs[layer][neuron2] * 
						       outputs[layer][neuron2])));
					break;
		
				case RELU:
					if(outputs[layer][neuron2] > 0){
						deltaWeights[layer][neuron1][neuron2] +=
							(LEARNING_RATE * 
							 error[layer + 1][neuron2] * 
							 outputs[layer][neuron1]);
					}
					break;
		
				case LEAKYRELU:
					if(outputs[layer + 1][neuron2] < 0){
						deltaWeights[layer][neuron1][neuron2] +=
							(LEARNING_RATE * 
							 error[layer + 1][neuron2] * 
							 outputs[layer][neuron1] * .01);
					}
		
					else{
						deltaWeights[layer][neuron1][neuron2] += 
							(LEARNING_RATE * 
							 error[layer + 1][neuron2] * 
							 outputs[layer][neuron1]);
					}
					break;
			}

		}
	}
}

/**
  *	Backpropogates the biases in the neural net
  *	Parameter nn: the neural network to backpropogate
  *	Parameter layer: the layer that is being backpropogated
  *	Returns: nothing
  */

__global__
void backpropogationBiasesKernel(NeuralNet* nn, double** outputs, double** error, double** deltaBiases, int layer){

	for(int neuron = threadIdx.x + (blockDim.x * blockIdx.x); neuron < nn->neurons[layer]; neuron += (blockDim.x * gridDim.x)){

		switch(nn->activations[layer][neuron]){
			case LINEAR:
				deltaBiases[layer][neuron] += 
					(LEARNING_RATE * 
					 error[layer][neuron]);
				break;
	
			case BINARY_STEP:
				// This has a derivative of 0 everywhere
				// so nothing needs to be added
				break;
	
			case LOGISTIC:
				deltaBiases[layer][neuron] += 
					(LEARNING_RATE * 
					 error[layer][neuron] * 
					 outputs[layer][neuron] * 
					 (1 - outputs[layer][neuron]));
				break;
	
			case TANH:
				deltaBiases[layer][neuron] += 
					(LEARNING_RATE * 
					 error[layer][neuron] * 
					 (1 - (outputs[layer][neuron] * 
					  outputs[layer][neuron])));
				break;
	
			case RELU:
				if(outputs[layer][neuron] > 0){
					deltaBiases[layer][neuron] += 
						(LEARNING_RATE * 
						 error[layer][neuron]);
				}
				break;
	
			case LEAKYRELU:
				if(outputs[layer][neuron] < 0){
					deltaBiases[layer][neuron] += 
						(LEARNING_RATE * 
						 error[layer][neuron] * 
						 .01);
				}
	
				else{
					deltaBiases[layer][neuron] += 
						(LEARNING_RATE * 
						 error[layer][neuron]);
				}
				break;
		}
	}
}

/**
  *	Changes the weights in the neural net
  *	Parameter nn: the neural network to change the weights in
  *	Parameter deltaWeights: the matrix of total unaveraged weight changes
  *	Parameter numOutputs: the number of outputs to average
  *	Returns: nothing
  */

__global__
void changeWeights(NeuralNet* nn, double*** deltaWeights, int numOutputs){
	for(int layer = threadIdx.x + (blockDim.x * blockIdx.x); layer < nn->layers-1; layer += (blockDim.x * gridDim.x)){
		for(int neuron1 = threadIdx.y + (blockDim.y * blockIdx.y); neuron1 < nn->neurons[layer]; neuron1 += (blockDim.y * gridDim.y)){
			for(int neuron2 = threadIdx.z + (blockDim.z * blockIdx.z); neuron2 < nn->neurons[layer + 1]; neuron2 += (blockDim.z * gridDim.z)){
				nn->weights[layer][neuron1][neuron2] -= (deltaWeights[layer][neuron1][neuron2] / numOutputs);
			}
		}
	}
}

/**
  *	Changes the biases in the neural net
  *	Parameter nn: the neural network to change the biases in
  *	Parameter deltaBiases: the matrix of total unaveraged bias changes
  *	Parameter numOutputs: the total number of outputs to average
  *	Returns: nothing
  */

__global__
void changeBiases(NeuralNet* nn, double** deltaBiases, int numOutputs){
	for(int layer = threadIdx.x + (blockDim.x * blockIdx.x); layer < nn->layers - 1; layer += (blockDim.x * gridDim.x)){
		for(int neuron = threadIdx.y + (blockDim.y * blockIdx.y); neuron < nn->neurons[layer]; neuron += blockDim.y * gridDim.y){
			nn->biases[layer][neuron] -= (deltaBiases[layer][neuron] / numOutputs);
		}
	}
}

/**
  *	Backpropogates the neural network with the actual and expected outputs
  *	Parameter nn: the neural network to backpropogate
  *	Parameter actual: the actual outputs given by the neural network
  *	Parameter expected: the expected outputs given by the neural network
  *	Parameter numOutputs: the number of outputs
  *	Returns: nothing
  */

void backpropogate(NeuralNet* nn, double*** outputs, double** expected, int numOutputs){

	// Gets an matrix for the error
	double** error = getNeuralMatrix(nn);

	double** deltaBiasMatrix=getNeuralMatrix(nn);

	double*** deltaWeightMatrix=getNeuralWeightMatrix(nn);

	// Loops through the outputs
	for(int output = 0; output < numOutputs; output++){
		for(int layer=nn->layers - 1; layer >= 0; layer--){

			// Gets the error
			getErrorKernel<<<NUMBLOCKS, BLOCKSIZE>>>(nn, error, outputs[output], expected[output], layer);
			cudaDeviceSynchronize();

			// Backpropgate the weights/biases
			if(layer != nn->layers - 1){
				backpropogationWeightsKernel<<<dim3(NUMBLOCKS, NUMBLOCKS), dim3(BLOCKSIZE/4, BLOCKSIZE/4)>>>(nn, outputs[output], error, deltaWeightMatrix, layer);
				cudaDeviceSynchronize();

				backpropogationBiasesKernel<<<NUMBLOCKS, BLOCKSIZE>>>(nn, outputs[output], error, deltaBiasMatrix, layer);
				cudaDeviceSynchronize();
			}
		}
	}

	// Changes the weights in the neural net
	changeWeights<<<dim3(NUMBLOCKS, NUMBLOCKS, NUMBLOCKS), dim3(BLOCKSIZE/16, BLOCKSIZE/16, BLOCKSIZE/16)>>>(nn, deltaWeightMatrix, numOutputs);
	cudaDeviceSynchronize();

	// Changes the biases in the neural net
	changeBiases<<<dim3(NUMBLOCKS, NUMBLOCKS), dim3(BLOCKSIZE/4, BLOCKSIZE/4)>>>(nn, deltaBiasMatrix, numOutputs);
	cudaDeviceSynchronize();

	// Frees the error matrix
	freeNeuralMatrix(error, nn);

	// Frees the bias matrix
	freeNeuralMatrix(deltaBiasMatrix, nn);

	// Frees the weight matrix
	freeNeuralWeightMatrix(deltaWeightMatrix, nn);
}

/**
  *	Allocates memory for and zeros a matrix of the same size as the neural network's nodes
  *	Parameter nn: the neural network to get the dimensions from
  *	Returns: a matrix of the same size as the neural network's nodes
  */

double** getNeuralMatrix(NeuralNet* nn){
	
	double** matrix;
	cudaMallocManaged(&matrix, nn->layers*sizeof(double*));

	for(int layer = 0; layer < nn->layers; layer++){
		cudaMallocManaged(&matrix[layer], nn->neurons[layer]*sizeof(double));
		
		for(int neuron = 0; neuron < nn->neurons[layer]; neuron++){
			matrix[layer][neuron] = 0;
		}
	}

	return matrix;
}

/**
  *	Frees the neural matrix
  *	Parameter matrix: the matrix to feree
  *	Parameter nn: the neural network to get the dimensions from
  *	Returns: nothing
  */


void freeNeuralMatrix(double** matrix, NeuralNet* nn){
	
	for(int layer = 0; layer < nn->layers; layer++){
		cudaFree(matrix[layer]);
	}

	cudaFree(matrix);
}

/**
  *	Allocates memory and zeros a matrix of the same size as the neural network's weight matrix
  *	Parameter nn: the neural network to get the weight matrix from
  *	Returns: a matrix of the same size as the neural network's weight matrix
  */

double*** getNeuralWeightMatrix(NeuralNet* nn){

	double*** matrix;
	cudaMallocManaged(&matrix, nn->layers * sizeof(double**));

	for(int layer = 0; layer < nn->layers-1; layer++){

		cudaMallocManaged(&matrix[layer], nn->neurons[layer] * sizeof(double*));
		for(int neuron1 = 0; neuron1 < nn->neurons[layer]; neuron1++){

			cudaMallocManaged(&matrix[layer][neuron1], nn->neurons[layer+1] * sizeof(double));
			for(int neuron2 = 0; neuron2 < nn->neurons[layer + 1]; neuron2++){
				matrix[layer][neuron1][neuron2] = 0;
			}
		}
	}

	return matrix;
}

/**
  *	Frees the neural weight matrix
  *	Parameter matrix: the neural weight matrix
  *	Parameter nn: the neural network to get the dimensions from
  *	Returns: nothing
  */

void freeNeuralWeightMatrix(double*** matrix, NeuralNet* nn){

	for(int layer = 0; layer < nn->layers - 1; layer++){
		for(int neuron1 = 0; neuron1 < nn->neurons[layer]; neuron1++){
			cudaFree(matrix[layer][neuron1]);
		}

		cudaFree(matrix[layer]);
	}

	cudaFree(matrix);
}

