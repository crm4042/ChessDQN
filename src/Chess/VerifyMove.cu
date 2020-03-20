#include "VerifyMove.cuh"

int getCheck(Piece** board, int kingRow, int kingCol, int color){

	// Loops through the rows
	for(int direction=-1; direction<=1; direction+=2){
		for(int row=kingRow; row<DIM && row>=0; row+=direction){
			if(board[row][kingCol].piece.color==color){
				break;
			}

			else if(board[row][kingCol].piece.isRook || 
				board[row][kingCol].piece.isQueen || 
				(board[row][kingCol].piece.isKing && 
					abs(row-kingRow)==1)){
				return 1;
			}
		}
	}

	// Loops through the cols
	for(int direction=-1; direction<=1; direction+=2){
		for(int col=kingCol; col<DIM && col>=0; col+=direction){
			if(board[kingRow][col].piece.color==color){
				break;
			}

			else if(board[kingRow][col].piece.isRook ||
				board[kingRow][col].piece.isQueen || 
				(board[kingRow][col].piece.isKing && 
					abs(col-kingCol)==1)){
				return 1;
			}
		}
	}

	// Loops through the diagonals
	for(int rowDirection=-1; rowDirection<=1; rowDirection+=2){
		for(int colDirection=-1; colDirection<=1; colDirection+=2){
			for(int row=kingRow, col=kingCol; 
				row>=0 && row<DIM && col>=0 && col<DIM;
				row+=rowDirection, col+=colDirection){

				if(board[row][col].piece.color==color){
					break;
				}

				else if(board[row][col].piece.isBishop || 
					board[row][col].piece.isQueen ||
					(board[row][col].piece.isKing && 
						abs(row-kingRow)==1 && 
						abs(col-kingCol)==1)){

					return 1;
				}
			}
		}
	}

	// Loops through the knights
	for(int row=max(0, kingRow-2); row<=min(DIM-1, kingRow+2); row++){
		for(int col=max(0, kingCol-2); col<=min(DIM-1, kingCol+2); col++){
			if(row==kingRow || col==kingCol || 
				abs(row-kingRow)==abs(col-kingCol)){
				continue;
			}

			else if(board[row][col].piece.isKnight){
				return 1;
			}
		}
	}

	return 0;
}

/**
  *	Gets the change in row
  *	Parameter oldRow: the row to move from
  *	Parameter newRow: the row to move to
  *	Returns: the change in row
  */

int getDeltaRow(int oldRow, int newRow){
	return newRow-oldRow;
}

/**
  *	Gets the change in col
  *	Parameter oldCol: the col to move from
  *	Parameter newCol: the col to move to
  *	Returns: the change in col
  */

int getDeltaCol(int oldCol, int newCol){
	return newCol-oldCol;
}


/**
  *	Checks to make sure the pawn move was valid
  *	Parameter board: the board to check the move from
  *	Parameter oldRow: the row that the pawn moves from
  *	Parameter oldCol: the col that the pawn moves from
  *	Parameter newRow: the row that the pawn moves to
  *	Parameter newCol: the col that the pawn moves to
  *	Parameter color: the color of the pawn to move
  *	Returns: whether or not the move was valid
  */

int isValidPawnMove(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color){
	
	int deltaRow=getDeltaRow(oldRow, newRow);
	int deltaCol=getDeltaCol(oldCol, newCol);
	int colorFactor=pow(-1, color);

	// Double square advance
	if(deltaRow==2*colorFactor && 
			deltaCol==0 &&
			board[oldRow][oldCol].piece.isFirstMove==1){
		
		return canMoveFromTo(board, oldRow, oldCol, newRow, newCol, 
				color, 0, 0);
	}

	// Single square advance
	else if(deltaRow==1*colorFactor && deltaCol==0){
		return canMoveFromTo(board, oldRow, oldCol, newRow, newCol, 
				color, 0, 0);
	}

	// Take
	else if(deltaRow==1*colorFactor && abs(deltaCol)==1 && 
			hasEnemy(board, newRow, newCol, color)){
		//printf("%d \n", board[newRow][newCol].numberConversion);
		return canMoveFromTo(board, oldRow, oldCol, newRow, newCol, 
				color, 1, 0);
	}

	// Invalid move
	else{
		return 0;
	}
}

/**
  *	Checks to make sure the rook move was valid
  *	Parameter board: the board to check the move on
  *	Parameter oldRow: the row that the rook moves from
  *	Parameter oldCol: the col that the rook moves from
  *	Parameter newRow: the row that the rook moves to
  *	Parameter newCol: the col that the rook moves to
  *	Parameter color: the color of the rook to move
  *	Returns: whether or not the move was valid
  */

int isValidRookMove(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color){
	
	int deltaRow=getDeltaRow(oldRow, newRow);
	int deltaCol=getDeltaCol(oldCol, newCol);
	
	// If it matches the parrern for a rook's move
	if((deltaRow!=0 && deltaCol==0) || 
			(deltaRow==0 && deltaCol!=0)){
		return canMoveFromTo(board, oldRow, oldCol, newRow, newCol, 
				color, 1, 0);
	}

	// Invalid move pattern
	else{
		return 0;
	}
}

/**
  *	Checks to make sure that the knight move was valid
  *	Parameter board: the board to check the move on
  *	Parameter oldRow: the row that the knight moves from
  *	Parameter oldCol: the col that the knight moves from
  *	Parameter newRow: the row that the knight moves from
  *	Parameter newCol: the col that the knight moves from
  *	Parameter color: the color of the knight to move
  *	Returns: whether or not the knight move was valid
  */

int isValidKnightMove(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color){

	int deltaRow=getDeltaRow(oldRow, newRow);
	int deltaCol=getDeltaCol(oldCol, newCol);

	// If it matches the pattern for a knight's move
	if((abs(deltaRow)==1 && abs(deltaCol)==2) || 
			(abs(deltaRow)==2 && abs(deltaCol)==1)){
		return canMoveFromTo(board, oldRow, oldCol, newRow, newCol, 
				color, 1, 0);
	}

	// Invalid move pattern
	else{
		return 0;
	}
}

/**
  *	Checks to make sure that the bishop's move was valid
  *	Parameter board: the board to check the move on
  *	Parameter oldRow: the row that the bishop moves from
  *	Parameter oldCol: the col that the bishop moves from
  *	Parameter newRow: the row that the bishop moves to
  *	Parameter newCol: the col that the bishop moves to
  *	Parameter color: the color of the bishop to move
  *	Returns: whether or not the bishop's move was valid
  */

int isValidBishopMove(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color){

	int deltaRow=getDeltaRow(oldRow, newRow);
	int deltaCol=getDeltaCol(oldCol, newCol);

	// If it matches the pattern for a bishop's move
	if(abs(deltaRow)==abs(deltaCol)){
		return canMoveFromTo(board, oldRow, oldCol, newRow, newCol, 
				color, 1, 0);
	}

	// Invalid move pattern
	else{
		return 0;
	}
}

/**
  *	Checks to make sure that the queen's move was valid
  *	Parameter board: the board to check the move on
  *	Parameter oldRow: the row that the queen moves from
  *	Parameter oldCol: the col that the queen moves from
  *	Parameter newRow: the row that the queen moves to
  *	Parameter newCol: the col that the queen moves to
  *	Parameter color: the color of the queen to move
  *	Returns: whether or not the queen's move was valid
  */

int isValidQueenMove(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color){
	return isValidRookMove(board, oldRow, oldCol, newRow, newCol, color) ||
		isValidBishopMove(board, oldRow, oldCol, newRow, newCol, 
				color);
}

/**
  *	Checks to make sure that the king's move was valid
  *	Parameter board: the board to check the move on
  *	Parameter oldRow: the row that the king moves from
  *	Parameter oldCol: the col that the king moves from
  *	Parameter newRow: the row that the king moves to
  *	Parameter newCol: the col that the king moves to
  *	Parameter color: the color of the king to move
  *	Returns: whether or not the king's move was valid
  */

int isValidKingMove(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color){

	int deltaRow=getDeltaRow(oldRow, newRow);
	int deltaCol=getDeltaCol(oldCol, newCol);

	// If it matches the pattern for a king's move
	if((abs(deltaRow)==1 && abs(deltaCol)<=1) || 
			(abs(deltaRow) <=1 && abs(deltaCol)==1)){
		return canMoveFromTo(board, oldRow, oldCol, newRow, newCol, 
				color, 1, 0);
	}

	// If it matches the pattern for a castle
	else if(oldRow==newRow &&
		abs(deltaCol)==2 &&
		board[oldRow][oldCol].piece.isFirstMove &&
		canMoveFromTo(board, oldRow, oldCol, newRow, newCol, color, 
			0, 0) &&
		((deltaCol<0 && board[oldRow][0].piece.isRook && 
			board[oldRow][0].piece.isFirstMove && 
			canMoveFromTo(board, oldRow, 0, newRow, 3, color, 
				0, 0)) ||
		(deltaCol>0 && board[oldRow][7].piece.isRook && 
			board[oldRow][7].piece.isFirstMove && 
			canMoveFromTo(board, oldRow, 7, newRow, 5, color, 
				0, 0)))){

		//Checks for a check between the two (inclusive)
		for(int col=oldCol; col!=newCol+(deltaCol/abs(deltaCol)); col+=(deltaCol/abs(deltaCol))){
			if(getCheck(board, oldRow, col, color)){
				return 0;
			}
		}

		return 1;
	}

	// Invalid move pattern
	else{
		return 0;
	}
}

#include "ChessBoard.cuh"

/**
  *	Checks to see if a move is valid
  *	Parameter board: the board to check the move on
  *	Parameter oldRow: the row that the piece moves from
  *	Parameter oldCol: the col that the piece moves from
  *	Parameter newRow: the row that the piece moves to
  *	Parameter newCol: the col that the piece moves to
  *	Parameter color: the color of the person that's moving
  *	Returns: whether or not the move is valid
  */

int isValidMove(Piece** board, int oldRow, int oldCol, int newRow, int newCol, 
		int color){

	/*printf("OldRow %d, OldCol %d NewRow %d, NewCol %d; ", oldRow, oldCol, newRow, newCol);
	if(verifyBounds(oldRow, oldCol)){
		printf("Valid old bounds ");
		if(verifyBounds(newRow, newCol)){
			printf("Valid new bounds ");
			if(isOccupied(board, oldRow, oldCol)){
				printf("Occupied start position ");
				if(board[oldRow][oldCol].piece.color==color){
					printf("Valid color move ");
					if(!hasObstructions(board, oldRow, oldCol, newRow, newCol)){
						printf("No obstructions. Passed to inside\n");
					}
					else{
						printf("Obstructions found \n");
					}
				}
				else{
					printf("Invalid color move \n");
				}
			}
			else{
				printf("Occupied end position /n");
			}
		}
		else{
			printf("Non-valid new bounds /n");
		}
	}
	else{
		printf("Non-valid old bounds /n");
	}*/

	// Checks if there is a piece at oldRow oldCol that can be moved
	if(verifyBounds(oldRow, oldCol) && verifyBounds(newRow, newCol) && 
			(oldRow!=newRow || oldCol!=newCol) &&
			isOccupied(board, oldRow, oldCol) && 
			board[oldRow][oldCol].piece.color==color){
		
		//printf("Inside\n");

		// Checks each of the pieces
		if(board[oldRow][oldCol].piece.isPawn){
			/*if(newRow==6 && oldCol==newCol){
				printChessBoard(board);
				printf("PAWN oldRow=%d, oldCol=%d, newRow=%d, newCol=%d\n", oldRow, oldCol, newRow, newCol);
			}*/
			return isValidPawnMove(board, oldRow, oldCol, newRow, 
					newCol, color);
		}
		else if(board[oldRow][oldCol].piece.isRook){
			//printf("ROOK\n");
			return isValidRookMove(board, oldRow, oldCol, newRow, 
					newCol, color);
		}
		else if(board[oldRow][oldCol].piece.isKnight){
			//printf("KNIGHT\n");
			return isValidKnightMove(board, oldRow, oldCol, 
					newRow, newCol, color);
		}
		else if(board[oldRow][oldCol].piece.isBishop){
			//printf("BISHOP\n");
			return isValidBishopMove(board, oldRow, oldCol, 
					newRow, newCol, color);
		}
		else if(board[oldRow][oldCol].piece.isQueen){
			//printf("QUEEN\n");
			return isValidQueenMove(board, oldRow, oldCol, 
					newRow, newCol, color);
		}
		else if(board[oldRow][oldCol].piece.isKing){
			//printf("KING\n");
			return isValidKingMove(board, oldRow, oldCol, newRow, 
					newCol, color);
		}
		else{
			printf("");
		}
	}

	return 0;
}

/**
  *	Verifies the bounds of the new position to make sure it is in the board
  *	Parameter row: the row to check the bounds of
  *	Parameter col: the column to check the bounds of
  *	Returns: whether or now newRow and newCol are in the bounds of the board
  */

int verifyBounds(int row, int col){
	return row>=0 && row<DIM && col>=0 && col<DIM;
}

/**
  *	Checks whether or not the square is occupied
  *	Parameter board: the board to check for the occupied square in
  *	Parameter row: the row to check if it is occupied
  *	Parameter col: the col to check if it is occupied
  *	Returns: whether or not the square is occupied
  */

int isOccupied(Piece** board, int row, int col){
	return board[row][col].numberConversion!=0;
}

/**
  *	Checks whether or not the square has an enemy
  *	Parameter board: the board to check for the enemy
  *	Parameter row: the row to check for an enemy
  *	Parameter col: the column to check for an enemy
  *	Parameter color: the color of the side looking for an enemy
  *	Returns: whether or not there is an enemy in row, col
  */

int hasEnemy(Piece** board, int row, int col, int color){
	return board[row][col].numberConversion != 0 && 
		board[row][col].piece.color!=color;
}

/**
  *	Checks if there are obstructions between the start and end
  *	positions
  *	Parameter board: the board to check for obstructions
  *	Parameter oldRow: the row that the piece moves from
  *	Parameter oldCol: the col that the piece moves from
  *	Parameter newRow: the row that the piece moves to
  *	Parameter newCol: the col that the piece moves to
  *	Returns: whether or not there are obstructions between the
  *	start and end positions
  */

int hasObstructions(Piece** board, int oldRow, int oldCol, 
		int newRow, int newCol){
	
	int deltaRow=pow(-1, newRow<oldRow);
	int deltaCol=pow(-1, newCol<oldCol);
	
	// If it moves along the col
	if(oldRow==newRow){
		for(int col=oldCol+deltaCol; col!=newCol; col+=deltaCol){
			if(board[oldRow][col].numberConversion!=0){
				return 1;
			}
		}
	}

	// If it moves along the row
	else if(oldCol==newCol){
		for(int row=oldRow+deltaRow; row!=newRow; row+=deltaRow){
			if(board[row][oldCol].numberConversion!=0){
				return 1;
			}
		}
	}

	// A diagonal
	else if(abs(oldRow-newRow)==abs(oldCol-newCol)){
		for(int row=oldRow+deltaRow, col=oldCol+deltaCol; 
			row!=newRow || col!=newCol; 
			row+=deltaRow, col+=deltaCol){
			if(board[row][col].numberConversion!=0){
				return 1;
			}
		}
	}

	return 0;
}

/**
  *	Checks whether or not the piece can move between the two
  *	locations
  *	Parameter board: the board to check
  *	Parameter oldRow: the old row to check
  *	Parameter oldCol: the old col to check
  *	Parameter newRow: the new row to check
  *	Parameter newCol: the new col to check
  *	Return: whether or not the move can be made
  */

int canMoveFromTo(Piece** board, int oldRow, int oldCol, int newRow, 
		int newCol, int color, int canTake, int canJump){

	return verifyBounds(oldRow, oldCol) && 
		verifyBounds(newRow, newCol) &&
		((canTake && hasEnemy(board, newRow, newCol, color)) ||
		!isOccupied(board, newRow, newCol)) &&
		(canJump || !hasObstructions(board, oldRow, oldCol, 
					     newRow, newCol));
}


