#include <stdio.h>

#include "ChessBoard.cuh"

/**
  *	Makes the chess board and assigns values for each piece
  *	Returns: a matrix of pieces
  */
Piece** makeChessBoard(){

	Piece** board = (Piece**)(calloc(DIM, sizeof(Piece*)));
	
	for(int row=0; row<DIM; row++){
		
		board[row]=(Piece*)(calloc(DIM, sizeof(Piece)));
		
		for(int col=0; col<DIM; col++){
			// Clears the piece's data values
			board[row][col].numberConversion=0;
			if(row==0 || row==1 || row==DIM-2 || row==DIM-1){
				// Assigns a color value of 1 to black
				board[row][col].piece.color=
					(unsigned int)(row==DIM-2 || 
							row==DIM-1);
			
				// Adds that it is the first move
				board[row][col].piece.isFirstMove=1;
			}
			
			// Assigns the piece value
			if(row==1 || row==DIM-2){
				board[row][col].piece.isPawn=1;
			}
			else if(row==0 || row==DIM-1){
				switch(col){
					case 0:
						board[row][col].piece.isRook=1;
						break;
					case 1:
						board[row][col].piece.isKnight=
							1;
						break;
					case 2:
						board[row][col].piece.isBishop=
							1;
						break;
					case 3:
						board[row][col].piece.isQueen=
							1;
						break;
					case 4:
						board[row][col].piece.isKing=1;
						break;
					case 5:
						board[row][col].piece.isBishop=
							1;
						break;
					case 6:
						board[row][col].piece.isKnight=
							1;
						break;
					case 7:
						board[row][col].piece.isRook=1;
						break;

				}
			}
		}
	}
	return board;
}

void freeChessBoard(Piece** board){
	for(int row=0; row<DIM; row++){
		free(board[row]);
	}
	free(board);
}

/**
  *	Prints the chess board
  *	Parameter board: the chess board to print
  *	Returns: nothing
  */

void printChessBoard(Piece** board){
	printf("\n\t");

	for(int col=0; col<DIM; col++){
		printf("%c\t", ((int)'A')+col);
	}

	printf("\n");

	for(int row=0; row<DIM; row++){
		
		printf("%d\t", row);

		for(int col=0; col<DIM; col++){

			// Prints a space
			if(board[row][col].numberConversion==0){
				printf("______\t");
			}

			// Prints a piece
			else{
				// Prints the initial space
				printf("__");

				// Prints the color
				if(board[row][col].piece.color==0){
					printf("%c", WHITECHAR);
				}
				else{
					printf("%c", BLACKCHAR);
				}

				// Prints the piece
				if(board[row][col].piece.isPawn){
					printf("%c", PAWN);
				}
				else if(board[row][col].piece.isRook){
					printf("%c", ROOK);
				}
				else if(board[row][col].piece.isKnight){
					printf("%c", KNIGHT);
				}
				else if(board[row][col].piece.isBishop){
					printf("%c", BISHOP);
				}
				else if(board[row][col].piece.isQueen){
					printf("%c", QUEEN);
				}
				else{
					printf("%c", KING);
				}

				// Adds the end spacing
				printf("__\t");
			}
		}
		printf("\n");
	}
	printf("===================================================\n");
}

double getReward(PieceConversion piece){
	if(piece.isPawn){
		return PAWNREWARD;
	}
	else if(piece.isRook){
		return ROOKREWARD;
	}
	else if(piece.isKnight){
		return KNIGHTREWARD;
	}
	else if(piece.isBishop){
		return BISHOPREWARD;
	}
	else if(piece.isQueen){
		return QUEENREWARD;
	}
	else if(piece.isKing){
		return KINGREWARD;
	}
	else{
		return 0;
	}
}

/**
  *	Moves a piece from an old position to a new position
  *	Parameter board: the matrix of pieces to alter
  *	Parameter oldRow: the old row to move the piece from
  *	Parameter oldCol: the old column to move the piece from
  *	Parameter newRow: the new row to move to piece to
  *	Parameter newCol: the new column to move the piece to
  *	Returns: nothing
  */

double movePiece(Piece** board, int oldRow, int oldCol, int newRow, int newCol){
	
	double reward=getReward(board[newRow][newCol].piece);

	// Moves the piece to the designated position
	board[newRow][newCol].numberConversion=
		board[oldRow][oldCol].numberConversion;
	board[newRow][newCol].piece.isFirstMove=0;
	
	// Deletes the piece from the old position
	board[oldRow][oldCol].numberConversion=0;
	
	return reward;
}

/**
  *	Creates a one-hot encoded vector of the game board
  *	Parameter board: the game board
  *	Parameter inputVector: the vector that will recieve the game board's
  *	values
  *	Returns: nothing
  */

void oneHotEncode(Piece** board, double* inputVector){
	for(int row=0; row<DIM; row++){
		for(int col=0; col<DIM; col++){

			// Gets the number conversion for the piece
			unsigned int numberConversion=
				board[row][col].numberConversion;
			
			for(int field=0; field<8; field++){
			
				// Gets the end bit
				inputVector[row*DIM+col+field]=
					numberConversion%2;

				// Does a bitwise right shift
				numberConversion/=2;
			}
		}
	}
}
