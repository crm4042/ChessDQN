#include <stdio.h>

#include "ChessBoard.cuh"

/**
  *	Makes the chess board and assigns values for each piece
  *	Returns: a matrix of pieces
  */
Piece** makeChessBoard(){

	Piece** board = (Piece*)(calloc(DIM, sizeof(Piece*)));
	
	for(int row=0; row<DIM; row++){
		
		board[row]=(Piece*)(calloc(DIM, sizeof(Piece)));
		
		for(int col=0; col<DIM; col++){
			// Clears the piece's data values
			board[row][col].numberConversion=0;

			// Assigns a color value of 1 to black
			board[row][col].piece.color=
				(unsigned int)(row==DIM-2 || row==DIM-1);
			
			// Adds that it is the first move
			board[row][col].piece.isFirstMove=1;
			
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

/**
  *	Prints the chess board
  *	Parameter board: the chess board to print
  *	Returns: nothing
  */

void printChessBoard(Piece** board){
	for(int row=0; row<DIM; row++){
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
}


