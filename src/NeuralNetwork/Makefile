CC=gcc
NVCC=nvcc
FLAGS := -arch=sm_37 -cudart=shared -rdc=true
COMPILE=-c
OUTPUT=-o

target.o: FeedForward.o Backpropogation.o NeuralNetwork.o

FeedForward.o: FeedForward.cu FeedForward.cuh
	$(NVCC) $(COMPILE) FeedForward.cu


Backpropogation.o: Backpropogation.cu Backpropogation.cuh
	$(NVCC) $(COMPILE) Backpropogation.cu

NeuralNetwork.o: NeuralNetwork.cu NeuralNetwork.cuh
	$(NVCC) $(COMPILE) NeuralNetwork.cu

clean:
	rm *.obj
