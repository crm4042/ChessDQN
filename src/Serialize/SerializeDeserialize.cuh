#ifndef SERIALIZEDESERIALIZE
#define SERIALIZEDESERIALIZE

#include <stdio.h>
#include <stdlib.h>

#include "./../Chess/Piece.cuh"
#include "./../NeuralNetwork/NeuralNetwork.cuh"

#define DIM 8

void serializeNeuralNet(NeuralNet* nn, char* fileName);

NeuralNet* deserializeNeuralNet(char* fileName);

void serializeChessBoard(Piece** board, char* filename);

#endif
