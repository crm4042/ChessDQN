CC=nvcc
CDL=-c

SD:=SerializeDeserialize
SDSrc:=$(SD).cu
SDFiles:=$(SDSrc) $(SD).cuh

Output: SerializeDeserialize.o

SerializeDeserialize.o: $(SDFiles)
	$(CC) $(CDL) $(SDSrc)
