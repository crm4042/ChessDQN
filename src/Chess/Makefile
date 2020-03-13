CC=nvcc
CDL=-c

PC=Piece
BRD=ChessBoard
VFY=VerifyMove
GM=Game

PCH=$(PC).cuh
VFYH=$(VFY).cuh

CBRDSrc=$(BRD).cu
CBRDFiles:=$(CBRDSrc) $(BRD).cuh

VFYSrc:=$(VFY).cu
VFYFiles:=$(VFYSrc) $(VFY).cuh

GMSrc:=$(GM).cu
GMFiles:=$(GMSrc) $(GM).cuh

Output: $(PCH) ChessBoard.o VerifyMove.o Game.o

ChessBoard.o: $(CBRDFiles)
	$(CC) $(CDL) $(CBRDSrc)

VerifyMove.o: $(VFYFiles)
	$(CC) $(CDL) $(VFYSrc)

Game.o: $(GMFiles)
	$(CC) $(CDL) $(GMSrc)
