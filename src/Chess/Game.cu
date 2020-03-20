#include "Game.cuh"

/**
  *	Gets the index of the highest value in a list
  *	Parameter outputs: the list to look through
  *	Parameter numOutputs: the number of elements in
  *	the outputs list
  *	Returns: the index of the highest value in a list
  */

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

/**
  *	Changes an index into a move vector
  *	Parameter index: the index to change into
  *	a move vector
  *	Returns: a vector corresponding to the move to be
  *	made in the form (oldRow, oldCol, newRow, newCol)
  */

int* parseIndexToMove(int index){

	// Gets the actual move from the max
	int* move=(int*)(calloc(4, sizeof(int)));
	for(int movePart=0; movePart<4; movePart++){
		move[movePart]=index%8;
		index/=8;
	}
	return move;
}

/**
  *	Changes the move into an index (for the output list)
  *	This is the inverse of the parseIndexToMove function
  *	and makes a 1-1 correspondance between the functions
  *	Parameter move: the move vector (oldRow, oldCol, 
  *	newRow, newCol)
  *	Returns: the corresponding index of the move
  */

int parseMoveToIndex(int* move){
	int index=0;
	for(int part=0; part<4; part++){
		index+=move[3-part]*pow(8, 3-part);
	}
	return index;
}

/**
  *	Allows the user to input a move to play against the neural network
  *	Parameter board: the board to make a move on
  *	Parameter color: the player's color (that's making the move)
  *	Returns: the winner's color if there is one -1 otherwise
  */

int makePlayerTurn(Piece** board, int color){
	int winner=-1;
	int madeMove=0;
	char* buffer=(char*)calloc(80, sizeof(char));

	do{
		//Handles user input
		printf("Make a numerical move in the format: [oldRow oldCol newRow newCol]\n");

		int oldRow=-1;
		int oldCol=-1;
		int newRow=-1;
		int newCol=-1;
		
		fgets(buffer, 78, stdin);
		oldRow=buffer[0]-48;
		oldCol=buffer[2]-48;
		newRow=buffer[4]-48;
		newCol=buffer[6]-48;

		// Validates the move and gets a winner if there is one
		if(isValidMove(board, oldRow, oldCol, newRow, newCol, color)){
			if(movePiece(board, oldRow, oldCol, newRow, newCol)==KINGREWARD){
				winner=color;
			}
			madeMove=1;
		}

		// An invalid move was made
		else{
			printf("Invalid move made\n");
		}
	}while(!madeMove);

	free(buffer);

	return winner;
}

/**
  *	Makes the turn and updates the output vectors
  *	Parameter board: the board to make a turn on
  *	Parameter color: the color of the player whose turn it is
  *	Parameter turn: the turn number
  *	Parameter nn: the neural network to use
  *	Parameter inputVector: a vector with enough space to hold
  *	all one-hot encoded data values for the board
  *	Parameter output: the rewards corresponding to the 
  *	output of the neural network
  *	Parameter expected: the values that were rewarded
  *	Parameter chosens: the chosen moves
  *	Returns: whether or not there was a checkmate
  */

int makeTurn(Piece** board, int color, int turn, NeuralNet* nn, 
	double* inputVector, double*** output, double** expected, int* chosens){

	// Gets the expected output vector
	oneHotEncode(board, inputVector);
	feedForward(nn, &output[turn], inputVector);

	// Gets the next move
	int madeMove=0;
	int randomMove=((rand()+0.0)/RAND_MAX)<EXPLORATION;
	
	int winner=-1;

	do{

		// If there should be a random move made
		if(randomMove){

			// Gets the random move
			int random=rand();
			int randomIndex=random%nn->neurons[nn->layers-1];
			int* move=parseIndexToMove(randomIndex);

			// Validates, makes, and gets the reward for a move
			if(isValidMove(board, move[0], move[1], move[2], 
						move[3], color)){

				expected[turn][randomIndex]=movePiece(board, 
					move[0], move[1], move[2], move[3])+TURNDEFICIT;

				chosens[turn]=randomIndex;

				if(expected[turn][randomIndex]==KINGREWARD+TURNDEFICIT){
					winner=color;
				}

				madeMove=1;
			}

			// Penalizes invalid moves
			else{
				expected[turn][randomIndex]=-1;
			}

			free(move);

		}
		
		// Otherwise choose the best move
		else{

			int maxIndex=getMaxIndex(output[turn][nn->layers-1], 
					nn->neurons[nn->layers-1]);
			int* move=parseIndexToMove(maxIndex);
			
			// Verifies the move and gets the reward for the move
			if(isValidMove(board, move[0], move[1], move[2], 
						move[3], color)){
				
				// Updates the reward
				expected[turn][maxIndex]=
					movePiece(board, move[0], move[1], 
					move[2], move[3])+TURNDEFICIT;
				
				// Updates the chosen list
				chosens[turn]=maxIndex;

				if(expected[turn][maxIndex]==KINGREWARD+TURNDEFICIT){
					winner=color;
				}

				madeMove=1;
			}

			// Penalizes invalid moves
			else{
				expected[turn][maxIndex]=-1;
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
  *	Parameter playerColor: the color of the player (-1
  *	if no player)
  *	Parameter inputVector: the input vector allocated
  *	with enough room for the one-hot encoded values of
  *	the board
  *	Parameter output1: the output values for the first 
  *	neural network
  *	Parameter output2: the output values for the second
  *	neural network
  *	Parameter expected1: the reward values for the 
  *	first player
  *	Parameter expected2: the reward values for the 
  *	second player
  *	Parameter chosens1: the chosen move indices for the 
  *	first player
  *	Parameter chosens2: the chosen move indices for the
  *	second player
  *	Parameter whiteTurns: the number of turns for the 
  *	first player
  *	Parameter blackTurns: the number of turns for the 
  *	second player
  *	Returns: the winner of the game (-1 if tie)
  */

int playGame(NeuralNet* nn1, NeuralNet* nn2, int playerColor, double* inputVector, 
	double*** output1, double*** output2, double** expected1, 
	double** expected2, int* chosens1, int* chosens2, int* whiteTurns, 
	int* blackTurns){

	Piece** board=makeChessBoard();

	int winner;
	int color=0;
	do{

		// Makes the player's turn
		if(color == playerColor){
			printChessBoard(board);
			winner=makePlayerTurn(board, color);
		}

		// Makes white's turn
		else if(color==0){
			//printf("White %d\n", *whiteTurns);
			winner=makeTurn(board, color, *whiteTurns,  nn1, 
				inputVector, output1, expected1, chosens1);
			(*whiteTurns)++;
		}

		// Makes black's turn
		else{
			//printf("Black %d\n", *blackTurns);
			winner=makeTurn(board, color, *blackTurns, nn2, 
				inputVector, output2, expected2, chosens2);
			(*blackTurns)++;
		}

		color=(color+1)%2;
	}while(winner<0 && (*whiteTurns)<TURNS && (*blackTurns)<TURNS);

	printChessBoard(board);

	freeChessBoard(board);

	return winner;
}

/**
  *	Uses the bellman equation to alter the actual reward values that were 
  *	returned
  *	Parameter nn: the neural network of the corresponding player
  *	Parameter outputs: the outputs of the neural networks
  *	Parameter expected: the reward values
  *	Parameter chosens: the states that were chosen
  *	Parameter numOutputs: the max number of outputs that could be chosen
  *	Parameter won: whether or not the player corresponding to the reward
  *	values has won
  *	Parameter tie: whether or not the player corresponding to the reward
  *	values has tied
  *	Returns: nothing
  */

void alterExpected(NeuralNet* nn, double*** outputs, double** expected, 
	int* chosens, int numOutputs, int won, int tie){
	
	// The bellman equation to chain the actions together
	for(int output=numOutputs-1; output>=0; output--){
		
		// Changes the non-chosen values to the output from the neural network
		// so no erroneous changes are made
		for(int reward=0; reward<nn->neurons[nn->layers-1]; reward++){
			if(expected[output][reward]!=-1 && reward != chosens[output]){
				expected[output][reward]=outputs[output][nn->layers-1][reward];
			}
		}

		// Bellman equation on last state's chosen value
		if(output==numOutputs-1){
			if(won){
				expected[output][chosens[output]]+=DISCOUNT*WINREWARD;
			}
			else if(!tie){
				expected[output][chosens[output]]+=DISCOUNT*LOSSREWARD;
			}
		}

		// Bellman equation on every other state's chosen value
		else{
			expected[output][chosens[output]]+=
				DISCOUNT*expected[output+1][chosens[output+1]];
			chosens[output+1]=-1;
		}
	}
	chosens[0]=-1;
}

/**
  *	Trains the neural network
  *	Parameter nn1: the first neural network to train
  *	Parameter nn2: the second neural network to train
  *	Parameter playerColor: the color of the player (or 
  *	-1 if there is no player)
  *	Returns: nothing
  */

void train(NeuralNet* nn1, NeuralNet* nn2, int playerColor, char* file1, char* file2){
	// The inputs used for both neural network feedforwards
	double* sharedInputs=(double*)calloc(nn1 -> neurons[0], 
		sizeof(double*));

	// Gets the output Matrices for both sides of the neural nets
	double*** output1=makeExpected(nn1, TURNS);
	double*** output2=makeExpected(nn2, TURNS);

	// Gets the reward Matrices for both sides of the neural nets
	double** expected1=makeActual(nn1, TURNS);
	double** expected2=makeActual(nn2, TURNS);

	// Gets the chosens vectors denoting what move was chosen
	int* chosens1=(int*)calloc(TURNS, sizeof(int));
	int* chosens2=(int*)calloc(TURNS, sizeof(int));
	for(int output=0; output<TURNS; output++){
		chosens1[output]=-1;
		chosens2[output]=-1;
	}

	// Loops through infinite games and plays the game to train it
	for(int game=0; 1; game++){

		// Serializes the neural networks every 5 games
		if(game%5==0){
			printf("Serializing the neural networks\n");
			
			serializeNeuralNet(nn1, file1);
			serializeNeuralNet(nn2, file2);
		}

		int* whiteTurns=(int*)calloc(1, sizeof(int));
		int* blackTurns=(int*)calloc(1, sizeof(int));

		// Plays a game
		printf("Training on game %d\n", game);
		int winner=playGame(nn1, nn2, playerColor, sharedInputs, output1, output2, 
			expected1, expected2, chosens1, chosens2, whiteTurns, blackTurns);

		// Changes the rewards using the bellman equation
		alterExpected(nn1, output1, expected1, chosens1, *whiteTurns, winner==0, winner==-1);
		alterExpected(nn2, output2, expected2, chosens2, *blackTurns, winner==1, winner==-1);

		free(whiteTurns);
		free(blackTurns);

		// Backpropogates when there is no player
		if(playerColor==-1){
			printf("Backpropogating\n");
			backpropogate(nn1, output1, expected1, TURNS);
			backpropogate(nn2, output2, expected2, TURNS);
		}
	}
}
