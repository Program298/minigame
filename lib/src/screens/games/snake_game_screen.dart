import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:minigame/src/games/snake/snake_game.dart';
import 'package:minigame/src/widgets/game_overlay.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  late SnakeGame _game;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _game = SnakeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<SnakeGame>(
            game: _game,
            overlayBuilderMap: {
              'gameOverlay': (context, game) {
                return GameOverlay(
                  game: game,
                  isPlaying: _isPlaying,
                  onStart: () {
                    setState(() {
                      _isPlaying = true;
                    });
                    game.startGame();
                  },
                  onRestart: () {
                    setState(() {
                      _isPlaying = true;
                    });
                    game.resetGame();
                    game.startGame();
                  },
                );
              },
            },
            initialActiveOverlays: const ['gameOverlay'],
            backgroundBuilder: (context) {
              return Container(
                color: _game.gameColor,
              );
            },
          ),
          if (_isPlaying && !_game.isGameOver)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildControlButtons(),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Up button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton(
                icon: Icons.arrow_upward,
                onPressed: () => _game.changeDirection(Direction.up),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Left, Right buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton(
                icon: Icons.arrow_back,
                onPressed: () => _game.changeDirection(Direction.left),
              ),
              const SizedBox(width: 48),
              _buildDirectionButton(
                icon: Icons.arrow_forward,
                onPressed: () => _game.changeDirection(Direction.right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Down button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton(
                icon: Icons.arrow_downward,
                onPressed: () => _game.changeDirection(Direction.down),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
