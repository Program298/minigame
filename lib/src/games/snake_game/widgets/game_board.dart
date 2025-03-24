import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minigame/src/games/snake_game/models/snake.dart';
import 'package:minigame/src/games/snake_game/providers/game_provider.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isGameOver) {
          return _buildGameOverScreen(context, gameProvider);
        }

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < 0) {
              gameProvider.changeDirection(Direction.up);
            } else if (details.delta.dy > 0) {
              gameProvider.changeDirection(Direction.down);
            }
          },
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < 0) {
              gameProvider.changeDirection(Direction.left);
            } else if (details.delta.dx > 0) {
              gameProvider.changeDirection(Direction.right);
            }
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.black.withOpacity(0.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CustomPaint(
                  painter: GameBoardPainter(
                    snake: gameProvider.snake,
                    food: gameProvider.food,
                    boardWidth: GameProvider.boardWidth,
                    boardHeight: GameProvider.boardHeight,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameOverScreen(BuildContext context, GameProvider gameProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: ${gameProvider.score}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    gameProvider.resetGame();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Play Again'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Main Menu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GameBoardPainter extends CustomPainter {
  final Snake? snake;
  final Food? food;
  final int boardWidth;
  final int boardHeight;
  final Image? foodImage;

  GameBoardPainter({
    required this.snake,
    required this.food,
    required this.boardWidth,
    required this.boardHeight,
    this.foodImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (snake == null || food == null) return;

    final cellWidth = size.width / boardWidth;
    final cellHeight = size.height / boardHeight;

    // Draw snake
    final snakePaint = Paint()..color = Colors.green;
    final snakeHeadPaint = Paint()..color = Colors.lightGreen;

    for (int i = 0; i < snake!.positions.length; i++) {
      final position = snake!.positions[i];
      final rect = Rect.fromLTWH(
        position.x * cellWidth,
        position.y * cellHeight,
        cellWidth,
        cellHeight,
      );

      // Draw snake head with different color
      if (i == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4.0)),
          snakeHeadPaint,
        );
        
        // Draw eyes
        final eyeRadius = cellWidth * 0.15;
        final eyeOffset = cellWidth * 0.25;
        
        // Position eyes based on direction
        double leftEyeX, leftEyeY, rightEyeX, rightEyeY;
        
        switch (snake!.direction) {
          case Direction.up:
            leftEyeX = rect.left + eyeOffset;
            leftEyeY = rect.top + eyeOffset;
            rightEyeX = rect.right - eyeOffset;
            rightEyeY = rect.top + eyeOffset;
            break;
          case Direction.down:
            leftEyeX = rect.left + eyeOffset;
            leftEyeY = rect.bottom - eyeOffset;
            rightEyeX = rect.right - eyeOffset;
            rightEyeY = rect.bottom - eyeOffset;
            break;
          case Direction.left:
            leftEyeX = rect.left + eyeOffset;
            leftEyeY = rect.top + eyeOffset;
            rightEyeX = rect.left + eyeOffset;
            rightEyeY = rect.bottom - eyeOffset;
            break;
          case Direction.right:
            leftEyeX = rect.right - eyeOffset;
            leftEyeY = rect.top + eyeOffset;
            rightEyeX = rect.right - eyeOffset;
            rightEyeY = rect.bottom - eyeOffset;
            break;
        }
        
        final eyePaint = Paint()..color = Colors.black;
        canvas.drawCircle(Offset(leftEyeX, leftEyeY), eyeRadius, eyePaint);
        canvas.drawCircle(Offset(rightEyeX, rightEyeY), eyeRadius, eyePaint);
      } else {
        // Draw snake body with rounded corners
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4.0)),
          snakePaint,
        );
      }
    }

    // Draw food
    final foodRect = Rect.fromLTWH(
      food!.position.x * cellWidth,
      food!.position.y * cellHeight,
      cellWidth,
      cellHeight,
    );
    
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawCircle(
      Offset(
        foodRect.left + cellWidth / 2,
        foodRect.top + cellHeight / 2,
      ),
      cellWidth / 2,
      foodPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
