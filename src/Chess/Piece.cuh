#ifndef PIECE
#define PIECE

#define WHITE 0
#define BLACK 1

#define WHITECHAR 'W'
#define BLACKCHAR 'B'

#define PAWN 'P'
#define ROOK 'R'
#define KNIGHT 'N'
#define BISHOP 'B'
#define QUEEN 'Q'
#define KING 'K'

#define PAWNREWARD 1
#define ROOKREWARD 5
#define KNIGHTREWARD 3
#define BISHOPREWARD 3
#define QUEENREWARD 9
#define KINGREWARD 40

typedef struct pce{
	unsigned int color : 1;
	unsigned int isFirstMove : 1;
	unsigned int isPawn : 1;
	unsigned int isRook : 1;
	unsigned int isKnight : 1;
	unsigned int isBishop : 1;
	unsigned int isQueen : 1;
	unsigned int isKing : 1;
} PieceConversion;

typedef union p{
	PieceConversion piece;
	unsigned int numberConversion;
} Piece;

#endif
