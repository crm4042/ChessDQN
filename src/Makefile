FLAGS:=--debug

NN=NeuralNetwork
CHS=Chess
SER=Serialize
FF=FeedForward
BPK=Backpropogation
CBRD=ChessBoard
GM=Game
VFY=VerifyMove
SD=SerializeDeserialize
MN=Main
IC=InitializeComponents

ICSrc:=$(IC).cu
ICFiles:=$(ICSrc) $(IC).cuh

Files:=$(NN) $(FF) $(BPK)
DIR:=$(NN)/$(NN).obj $(NN)/$(FF).obj $(NN)/$(BPK).obj $(CHS)/$(CBRD).obj $(CHS)/$(VFY).obj $(CHS)/$(GM).obj $(SER)/$(SD).obj $(IC).obj $(MN).obj

Output: subsystem neuralNetwork InitializeComponents.o Main 
	nvcc $(FLAGS) -o Output $(DIR)

Main: $(MN).cu
	nvcc -c $(MN).cu

InitializeComponents.o: $(ICFiles)
	nvcc -c $(ICSrc)

subsystem:
	$(MAKE) -C Chess
	$(MAKE) -C NeuralNetwork
	$(MAKE) -C Serialize

clean:
	rm *.obj
