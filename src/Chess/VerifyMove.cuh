#ifndef VERIFYMOVE
#define VERIFYMOVE

#include <math.h>
#include <stdio.h>

#include "ChessBoard.cuh"

int canMoveFromTo(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color, int canTake, int canJump);

int isValidMove(Piece** board, int oldRow, int oldCol, int newRow, int newCol, 
		int color);

int verifyBounds(int row, int col);

int isOccupied(Piece** board, int row, int col);

int hasEnemy(Piece** board, int row, int col, int color);

#endif
