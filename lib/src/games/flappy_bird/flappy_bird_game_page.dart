import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_screen.dart';
import 'providers/game_provider.dart';
import 'widgets/game_over_screen.dart';
import 'widgets/start_screen.dart';
import 'models/game_state.dart';

/// A standalone Flappy Bird game widget that can be embedded in any Flutter app.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => FlappyBirdGamePage()),
/// );
/// ```
class FlappyBirdGamePage extends StatelessWidget {
  /// Optional callback when the user exits the game
  final VoidCallback? onExit;
  
  /// Optional callback when the game is over with the final score
  final Function(int score)? onGameOver;
  
  /// Optional initial high score
  final int? initialHighScore;

  const FlappyBirdGamePage({
    Key? key, 
    this.onExit,
    this.onGameOver,
    this.initialHighScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(initialHighScore: initialHighScore),
      child: WillPopScope(
        onWillPop: () async {
          final gameProvider = Provider.of<GameProvider>(context, listen: false);
          gameProvider.pauseGame();
          
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Game?'),
              content: const Text('Are you sure you want to exit the game?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          ) ?? false;
          
          if (shouldPop) {
            onExit?.call();
          } else {
            gameProvider.resumeGame();
          }
          
          return shouldPop;
        },
        child: Scaffold(
          body: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              switch (gameProvider.gameState) {
                case GameState.start:
                  return StartScreen(
                    onStart: gameProvider.startGame,
                    highScore: gameProvider.highScore,
                    onExit: () {
                      if (onExit != null) {
                        onExit!();
                      }
                      Navigator.of(context).pop();
                    },
                  );
                case GameState.playing:
                  return GameScreen(
                    onTap: gameProvider.onTap,
                    bird: gameProvider.bird,
                    pipes: gameProvider.pipes,
                    score: gameProvider.score,
                    groundX: gameProvider.groundX,
                  );
                case GameState.gameOver:
                  return GameOverScreen(
                    score: gameProvider.score,
                    highScore: gameProvider.highScore,
                    onRestart: () {
                      if (onGameOver != null) {
                        onGameOver!(gameProvider.score);
                      }
                      gameProvider.resetGame();
                    },
                    onExit: () {
                      if (onExit != null) {
                        onExit!();
                      }
                      Navigator.of(context).pop();
                    },
                  );
                case GameState.paused:
                  return Stack(
                    children: [
                      GameScreen(
                        onTap: null, // Disable tapping when paused
                        bird: gameProvider.bird,
                        pipes: gameProvider.pipes,
                        score: gameProvider.score,
                        groundX: gameProvider.groundX,
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Game Paused',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: gameProvider.resumeGame,
                                child: const Text('Resume'),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (onExit != null) {
                                    onExit!();
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Exit Game'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
          floatingActionButton: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              if (gameProvider.gameState == GameState.playing) {
                return FloatingActionButton(
                  onPressed: gameProvider.pauseGame,
                  child: const Icon(Icons.pause),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
