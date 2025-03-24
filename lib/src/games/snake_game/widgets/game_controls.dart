import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minigame/src/games/snake_game/models/snake.dart';
import 'package:minigame/src/games/snake_game/providers/game_provider.dart';

class GameControls extends StatelessWidget {
  const GameControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                context,
                Icons.arrow_upward,
                () => _changeDirection(context, Direction.up),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                context,
                Icons.arrow_back,
                () => _changeDirection(context, Direction.left),
              ),
              const SizedBox(width: 50),
              _buildControlButton(
                context,
                Icons.arrow_forward,
                () => _changeDirection(context, Direction.right),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                context,
                Icons.arrow_downward,
                () => _changeDirection(context, Direction.down),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
        padding: const EdgeInsets.all(15.0),
      ),
    );
  }

  void _changeDirection(BuildContext context, Direction direction) {
    Provider.of<GameProvider>(context, listen: false).changeDirection(direction);
  }
}
