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

	// Writes the activation data
	for(int layer=0; layer<nn->layers-1; layer++){
		for(int neuron=0; neuron<nn->neurons[layer+1]; neuron++){
			fprintf(file, "%d\n", nn->activations[layer][neuron]);
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
			for(int neuron2=0; neuron2<nn->neurons[layer+1]; neuron2++){
				fscanf(file, "%lf\n", &nn->weights[layer][neuron1][neuron2]);
				//printf("Layer=%d\tNeuron1=%d\tNeuron2=%d\tWeight=%lf\n", layer, neuron1, neuron2, nn->weights[layer][neuron1][neuron2]);
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

	// Gets the activation function data
	cudaMallocManaged(&nn->activations, (nn->layers-1)*sizeof(activation*));
	for(int layer=0; layer<nn->layers-1; layer++){
		cudaMallocManaged(&nn->activations[layer], nn->neurons[layer+1]*sizeof(activation));
		for(int neuron=0; neuron<nn->neurons[layer+1]; neuron++){
			fscanf(file, "%d\n", &nn->activations[layer][neuron]);
		}
	}

	fclose(file);

	return nn;
}

void serializeChessBoard(Piece** board, char* filename){
	FILE* file=fopen(filename, "w");
	
	fprintf(file, "\t");

	for(int col=0; col<DIM; col++){
		fprintf(file, "%c\t", ((int)'A')+col);
	}

	fprintf(file, "\n");

	for(int row=0; row<DIM; row++){

		fprintf(file, "%d\t", row);

		for(int col=0; col<DIM; col++){
			
			if(board[row][col].numberConversion==0){
				fprintf(file, "______\t");
			}

			else{
				fprintf(file, "__");

				if(board[row][col].piece.color==0){
					fprintf(file, "W");
				}
				else{
					fprintf(file, "B");
				}

				if(board[row][col].piece.isPawn){
					fprintf(file, "P");
				}
				else if(board[row][col].piece.isRook){
					fprintf(file, "R");
				}
				else if(board[row][col].piece.isKnight){
					fprintf(file, "N");
				}
				else if(board[row][col].piece.isBishop){
					fprintf(file, "B");
				}
				else if(board[row][col].piece.isQueen){
					fprintf(file, "Q");
				}
				else{
					fprintf(file, "K");
				}

				fprintf(file, "__\t");
			}
		}

		fprintf(file, "\n");
	}

	fprintf(file, "\n======================================================\n\n");

	for(int row=0; row<DIM; row++){
		for(int col=0; col<DIM; col++){
			fprintf(file, "Row %d, Col %d, Num %d, clr %d, fst %d, Pwn %d, Rk %d, Knt %d, Bshp %d, Qn %d, Kng %d\n", row, col, board[row][col].numberConversion, board[row][col].piece.color, board[row][col].piece.isFirstMove, board[row][col].piece.isPawn, board[row][col].piece.isRook, board[row][col].piece.isKnight, board[row][col].piece.isBishop, board[row][col].piece.isQueen, board[row][col].piece.isKing);
		}
	}

	fclose(file);
}
