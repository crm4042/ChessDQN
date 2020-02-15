#ifndef CHESSBOARD
#define CHESSBOARD

#define DIM 8

Piece** makeChessBoard();

void printChessBoard(Piece** board);

void movePiece(Piece** board, int oldRow, int oldCol, int newRow, int newCol);

void oneHotEncode(Piece** board, double* inputVector);

#endif
