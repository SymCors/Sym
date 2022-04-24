import 'board.dart';
import 'move.dart';
import 'piece.dart';
import 'precomputed_move_data.dart';

var directionOffsets = [8, -8, -1, 1, 7, -7, 9, -9];
var attackedSquares = <int>[];

List getAttackedSquares() {
  for (var startSquare = 0; startSquare < 64; startSquare++) {
    int piece = Board.square[startSquare];
    if (Piece.isColour(piece, Board.opponentColour)) {
      // print(Piece.pieceName(piece));
      if (Piece.isSlidingPiece(piece)) {
        generateSlidingMovesForOpponent(startSquare, piece);
      } else if (Piece.isKnight(piece)) {
        generateKnightMovesForOpponent(startSquare);
      } else if (Piece.isPawn(piece)) {
        generatePawnMovesForOpponent(startSquare);
      } else if (Piece.isKing(piece)) {
        generateKingMovesForOpponent(startSquare);
      }
    }
  }
  return attackedSquares;
}

// rook, bishop, queen
void generateSlidingMovesForOpponent(int startSquare, int piece) {
  int startDirIndex = Piece.pieceType(piece) == Piece.bishop ? 4 : 0;
  int endDirIndex = Piece.pieceType(piece) == Piece.rook ? 4 : 8;

  for (var directionIndex = startDirIndex; directionIndex < endDirIndex; directionIndex++) {
    for (var n = 0; n < numSquaresToEdge[startSquare][directionIndex]; n++) {
      int targetSquare = (startSquare + directionOffsets[directionIndex] * (n + 1)).round();

      if (!targetSquare.isNegative) {
        int pieceOnTargetSquare = Board.square[targetSquare];

        // Blocked by friendly piece, so can't move any further in this direction.
        if (Piece.isColour(pieceOnTargetSquare, Board.opponentColour)) {
          break;
        }

        if (!attackedSquares.contains(targetSquare)) {
          attackedSquares.add(targetSquare);
        }
        // Can't move any further in this direction after capturing opponent's piece

        if (Piece.isColour(pieceOnTargetSquare, Board.friendlyColour)) {
          break;
        }
      }
    }
  }
}

/*------------------------------*/

void generateKingMovesForOpponent(int startSquare) {
  for (int kingMoveIndex = 0; kingMoveIndex < kingMoves[startSquare].length; kingMoveIndex++) {
    int targetSquare = kingMoves[startSquare][kingMoveIndex];
    int pieceOnTargetSquare = Board.square[targetSquare];

    if (Piece.isColour(pieceOnTargetSquare, Board.opponentColour)) {
      continue;
    }

    //bool isCapture = Piece.IsColour (pieceOnTargetSquare, Board.friendlyColour);

    if (!attackedSquares.contains(targetSquare)) {
      attackedSquares.add(targetSquare);
    }

    print(moveName(startSquare, targetSquare));
  }
}

/*---------------------------------*/

void generateKnightMovesForOpponent(startSquare) {
  for (int knightMoveIndex = 0; knightMoveIndex < knightMoves[startSquare].length; knightMoveIndex++) {
    int targetSquare = knightMoves[startSquare][knightMoveIndex];
    int targetSquarePiece = Board.square[targetSquare];
    /*bool isCapture = Piece.IsColour(targetSquarePiece, Board.friendlyColour);
    if (isCapture) {
      
    }*/

    // Skip if square contains friendly piece, or if in check and knight is not interposing/capturing checking piece
    if (Piece.isColour(targetSquarePiece, Board.opponentColour)) {
      continue;
    }

    if (!attackedSquares.contains(targetSquare)) {
      attackedSquares.add(targetSquare);
    }
    print(moveName(startSquare, targetSquare));
  }
}

/*---------------------------------*/

void generatePawnMovesForOpponent(startSquare) {}
