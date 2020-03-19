#include "Game.cuh"

int getMaxIndex(double* outputs, int numOutputs){
	// Gets the index with the highest
	int maxIndex=0;
	for(int output=0; output<numOutputs; output++){
		if(outputs[maxIndex] <= outputs[output]){
			maxIndex=output;
		}
	}
	return maxIndex;
}

int* parseIndexToMove(int index){

	// Gets the actual move from the max
	int* move=(int*)(calloc(4, sizeof(int)));
	for(int movePart=0; movePart<4; movePart++){
		move[movePart]=index%8;
		index/=8;
	}
	return move;
}

int parseMoveToIndex(int* move){
	int index=0;
	for(int part=0; part<4; part++){
		index+=move[3-part]*pow(8, 3-part);
	}
	return index;
}

int makePlayerTurn(Piece** board, int color){
	int winner=-1;
	int madeMove=0;
	char* buffer=(char*)calloc(80, sizeof(char));

	do{
		printf("Make a move in the format: [oldRow oldCol newRow newCol]\n");

		int oldRow=-1;
		int oldCol=-1;
		int newRow=-1;
		int newCol=-1;
		
		fgets(buffer, 78, stdin);
		oldRow=buffer[0]-48;
		oldCol=buffer[2]-48;
		newRow=buffer[4]-48;
		newCol=buffer[6]-48;

		if(isValidMove(board, oldRow, oldCol, newRow, newCol, color)){
			if(movePiece(board, oldRow, oldCol, newRow, newCol)==KINGREWARD){
				winner=color;
			}
			madeMove=1;
		}
		else{
			printf("Invalid move made\n");
		}
	}while(!madeMove);

	free(buffer);

	return winner;
}

/**
  *	Makes the turn and updates the output vector
  *	Parameter nn: the neural network
  *	Parameter board: the board to change
  *	Parameter inputVector: the input vector
  *	Parameter outputs: the output matrix to alter for backpropogation
  *	Parameter actual:
  *	Parameter numOutputs: the output matrix
  *	Parameter color: the color of the person to make a move
  *	Returns: whether or not there was a checkmate
  */

int makeTurn(Piece** board, int color, int turn, NeuralNet* nn, 
	double* inputVector, double*** expected, double** actual, int* chosens){

	// Gets the expected output vector
	oneHotEncode(board, inputVector);
	feedForward(nn, &expected[turn], inputVector);

	// Gets the next move
	int madeMove=0;
	int randomMove=((rand()+0.0)/RAND_MAX)<EXPLORATION;
	
	int winner=-1;

	do{

		// If there should be a random move made
		if(randomMove){

			//printf("Random move\n");

			// Gets the random move
			int random=rand();
			int randomIndex=random%nn->neurons[nn->layers-1];
			int* move=parseIndexToMove(randomIndex);

			//printf("Move %d %d %d %d\n", move[0], move[1], move[2], move[3]);

			// Validates, makes, and gets the reward for a move
			if(isValidMove(board, move[0], move[1], move[2], 
						move[3], color)){

				//printf("Valid\n");

				// Updates the reward
				actual[turn][randomIndex]=movePiece(board, 
					move[0], move[1], move[2], move[3])+TURNDEFICIT;

				// Gets the index of the chosen value
				chosens[turn]=randomIndex;

				if(actual[turn][randomIndex]==KINGREWARD+TURNDEFICIT){
					winner=color;
				}

				madeMove=1;
			}

			// An invalid move
			else{
				//printf("Not valid\n");
				actual[turn][randomIndex]=-1;
			}

			free(move);

		}
		
		// Otherwise choose the best move
		else{
			//printf("Not random\n");

			int maxIndex=getMaxIndex(expected[turn][nn->layers-1], 
					nn->neurons[nn->layers-1]);
			int* move=parseIndexToMove(maxIndex);
			
			//printf("Move %d %d %d %d\n", move[0], move[1], move[2], move[3]);

			if(isValidMove(board, move[0], move[1], move[2], 
						move[3], color)){

				//printf("Valid");
				
				// Updates the reward
				actual[turn][maxIndex]=
					movePiece(board, move[0], move[1], 
					move[2], move[3])+TURNDEFICIT;
				
				// Updates the chosen list
				chosens[turn]=maxIndex;

				if(actual[turn][maxIndex]==KINGREWARD+TURNDEFICIT){
					winner=color;
				}

				madeMove=1;
			}

			else{
				//printf("Not valid");

				actual[turn][maxIndex]=-1;
			}

			free(move);

			// Make a random move if the best move is invalid
			randomMove=1;	
		}

	}while(!madeMove);

	return winner;
}

/**
  *	Plays a single game
  *	Parameter nn1: the first neural network
  *	Parameter nn2: the second neural network
  *	Parameter inputVector: the input vector
  */

int playGame(NeuralNet* nn1, NeuralNet* nn2, int playerColor, double* inputVector, 
	double*** expected1, double*** expected2, double** actual1, 
	double** actual2, int* chosens1, int* chosens2, int* whiteTurns, 
	int* blackTurns){

	Piece** board=makeChessBoard();
	//printChessBoard(board);

	int winner;
	int color=0;
	do{
		char* filename=(char*)calloc(10, sizeof(char));
		strcpy(filename, "board.txt\0");
		serializeChessBoard(board, filename);
		free(filename);
		if(color == playerColor){
			printChessBoard(board);
			winner=makePlayerTurn(board, color);
		}
		else if(color==0){
			//printf("\nWhite turn %d\n", *whiteTurns);
			winner=makeTurn(board, color, *whiteTurns,  nn1, 
				inputVector, expected1, actual1, chosens1);
			(*whiteTurns)++;
		}
		else{
			//printf("\nBlack turn %d\n", *blackTurns);
			winner=makeTurn(board, color, *blackTurns, nn2, 
				inputVector, expected2, actual2, chosens2);
			(*blackTurns)++;
		}
		color=(color+1)%2;

		//printChessBoard(board);
	}while(winner<0 && (*whiteTurns)<TURNS && (*blackTurns)<TURNS);

	printChessBoard(board);

	freeChessBoard(board);

	return winner;
}

/**
  *	Uses the bellman equation to alter the actual reward values that were 
  *	returned
  *	Parameter actual: the actual reward values
  *	Parameter chosen: the states that were chosen
  *	Parameter numOutputs: the max number of outputs that could be chosen
  *	Returns: nothing
  */

void alterActual(double** actual, int* chosens, int numOutputs, int won, int tie){
	// The win/loss rewards to be added to the final state
	if(won){
		actual[numOutputs-1][chosens[numOutputs-1]]+=DISCOUNT*WINREWARD;
	}
	else if(!tie){
		actual[numOutputs-1][chosens[numOutputs-1]]+=DISCOUNT*LOSSREWARD;
	}

	// The bellman equation to chain the actions together
	for(int output=numOutputs-2; output>=0; output--){
		if(chosens[output+1]!=-1){
			actual[output][chosens[output]]+=
				DISCOUNT*actual[output+1][chosens[output+1]];
		}
		chosens[output+1]=-1;
	}
	chosens[0]=-1;
}

/**
  *	Trains the neural network
  *	Parameter nn1: the first neural network to train
  *	Parameter nn2: the second neural network to train
  *	Returns: nothing
  */

void train(NeuralNet* nn1, NeuralNet* nn2, int playerColor){
	// The inputs used for both neural network feedforwards
	double* sharedInputs=(double*)calloc(nn1 -> neurons[0], 
		sizeof(double*));

	// Gets the expected output Matrices for both sides of the neural nets
	double*** expected1=makeExpected(nn1, TURNS);
	double*** expected2=makeExpected(nn2, TURNS);

	// Gets the actual output Matrices for both sides of the neural nets
	double** actual1=makeActual(nn1, TURNS);
	double** actual2=makeActual(nn2, TURNS);

	// Gets the chosens vectors denoting what move was chosen
	int* chosens1=(int*)calloc(TURNS, sizeof(int));
	int* chosens2=(int*)calloc(TURNS, sizeof(int));
	for(int output=0; output<TURNS; output++){
		chosens1[output]=-1;
		chosens2[output]=-1;
	}

	// Loops through infinite games and plays the game to train it
	for(int game=0; 1; game++){
		if(game%5==0){
			printf("Serializing the neural networks\n");
			char* buffer=(char*)calloc(8, sizeof(char));
			
			strcpy(buffer, "nn1.txt\0");
			serializeNeuralNet(nn1, buffer);
			
			strcpy(buffer, "nn2.txt\0");
			serializeNeuralNet(nn2, buffer);
			
			free(buffer);
		}

		int* whiteTurns=(int*)calloc(1, sizeof(int));
		int* blackTurns=(int*)calloc(1, sizeof(int));

		printf("Training on game %d\n", game);
		int winner=playGame(nn1, nn2, playerColor, sharedInputs, expected1, expected2, 
			actual1, actual2, chosens1, chosens2, whiteTurns, blackTurns);
		
		printf("Performing bellman equation on rewards\n");

		alterActual(actual1, chosens1, *whiteTurns, winner==0, winner==-1);
		alterActual(actual2, chosens2, *blackTurns, winner==1, winner==-1);

		free(whiteTurns);
		free(blackTurns);

		if(playerColor==-1){
			printf("Backpropogating\n");
			backpropogate(nn1, expected1, actual1, TURNS);
			backpropogate(nn2, expected2, actual2, TURNS);
		}
	}
}
