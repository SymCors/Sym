import 'dart:io';

import 'package:sym/models/move.dart';
import 'package:sym/move_generator.dart';
import 'package:sym/utils/constants.dart';

void main() {
  // Initialize the chess board to the starting position
  chessBoard.loadPositionFromFen('r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1');

  print('\n' * 3);
  print(moveGenerationTest(2));
  print('\n' * 3);

  // Set up the input and output streams
  // stdin.transform(utf8.decoder).transform(LineSplitter()).listen(handleInput);

  // Send the "uci" command to the GUI to initiate the UCI communication
  // stdout.write('uci\n');
}

int moveGenerationTest(int depth) {
  if (depth == 0) {
    return 1;
  }

  Set<Move> moves = MoveGenerator().generateMoves(board, activeColor);
  int numberOfPositions = 0;

  for (Move move in moves) {
    print(move.toUciString());
    var localBoard = MoveGenerator().deepCopyBoard(board);
    chessBoard.makeMoveForBoard(localBoard, move);
    numberOfPositions += moveGenerationTest(depth - 1);
  }

  return numberOfPositions;
}

void handleInput(String input) {
  // Split the input string into tokens
  List<String> tokens = input.split(' ');
  String command = tokens[0];

  switch (command) {
    case 'uci':
      // Respond to the "uci" command with the engine's name and options
      stdout.write('id name Sym Chess Bot\n');
      stdout.write('id author Yunus Karaaslan\n');
      stdout.write('uciok\n');
      break;
    case 'isready':
      // Respond to the "isready" command with "readyok"
      stdout.write('readyok\n');
      break;
    case 'ucinewgame':
      // Reset the chess board and other internal state when starting a new game
      chessBoard.loadPositionFromFen(startingPosition);
      break;
    case 'position':
      // Set the position on the chess board according to the FEN string or moves list
      if (tokens[1] == 'startpos') {
        chessBoard.loadPositionFromFen(startingPosition);
      } else if (tokens[1] == 'fen') {
        String fen = tokens.sublist(2, tokens.length - 1).join(' ');
        chessBoard.loadPositionFromFen(fen);
      }
      if (tokens[tokens.length - 2] == 'moves') {
        for (int i = tokens.length - 1; i < tokens.length; i++) {
          String move = tokens[i];
          // Make the move on the chess board and update the internal state
          chessBoard.makeMove(Move.fromUciString(move));
        }
      }
      break;
    case 'go':
      // Generate and make a move, and send it to the GUI
      String move = MoveGenerator().generateMove(board);
      chessBoard.makeMove(Move.fromUciString(move));
      stdout.write('bestmove $move\n');
      print('\n' * 10);
      for (var i = board.length - 1; i >= 0; i--) {
        var symbol = '';
        for (var element in board[i]) {
          symbol += '${element?.getSymbol() ?? '.'} ';
        }
        print(symbol);
      }
      print('\n' * 5);
      break;
    case 'stop':
      // Interrupt the search when receiving the "stop" command
      break;
    case 'quit':
      // Terminate the program when receiving the "quit" command
      exit(0);
    default:
      // Ignore unknown commands
      break;
  }
}
