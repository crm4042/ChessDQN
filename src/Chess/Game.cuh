#ifndef GAME
#define GAME

#include "VerifyMove.cuh"
#include "./../NeuralNetwork/Backpropogation.cuh"
#include "./../NeuralNetwork/FeedForward.cuh"
#include "./../NeuralNetwork/NeuralNetwork.cuh"
#include "./../Serialize/SerializeDeserialize.cuh"

#define TURNS 75
#define EXPLORATION .1
#define DISCOUNT .25
#define WINREWARD 100
#define LOSSREWARD -100
#define TURNDEFICIT -.1


void train(NeuralNet* nn1, NeuralNet* nn2, int playerColor);

#endif
