import 'package:flutter/material.dart';
import 'package:minigame/src/games/brick_breaker/game/brick_breaker_game.dart';
import 'package:flame/game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BrickBreakerGame _game;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _game = BrickBreakerGame(
      onGameOver: (score) {
        setState(() {
          _gameStarted = false;
        });
        _showGameOverDialog(score);
      },
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
    _game.startGame();
  }

  void _showGameOverDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          if (!_gameStarted)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'BRICK BREAKER',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'START GAME',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    
              Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                       onPressed: () {
                  Navigator.pop(context);
                  // Navigator.pop(context);
                   },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 227, 76, 76),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Exit Game',
                        style: TextStyle(fontSize: 20,color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                             ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
