#ifndef CHESSBOARD
#define CHESSBOARD

#include "Piece.cuh"

#define DIM 8

Piece** makeChessBoard();

void printChessBoard(Piece** board);

double movePiece(Piece** board, int oldRow, int oldCol, int newRow, int newCol);

void oneHotEncode(Piece** board, double* inputVector);

#endif
