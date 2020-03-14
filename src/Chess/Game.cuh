#ifndef GAME
#define GAME

#include "VerifyMove.cuh"
#include "./../NeuralNetwork/Backpropogation.cuh"
#include "./../NeuralNetwork/FeedForward.cuh"
#include "./../NeuralNetwork/NeuralNetwork.cuh"
#include "./../Serialize/SerializeDeserialize.cuh"

#define TURNS 200
#define EXPLORATION .1
#define DISCOUNT .25


void train(NeuralNet* nn1, NeuralNet* nn2, int playerColor);

#endif
