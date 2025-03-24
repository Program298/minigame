import 'package:flutter/material.dart';
import 'package:minigame/games/brick_breaker/screens/brick_breaker_screen.dart';
// import 'package:minigame/screens/games/flappy_bird_screen.dart';
// import 'package:minigame/screens/games/snake_game_screen.dart';
import 'package:provider/provider.dart';
import 'package:minigame/providers/score_provider.dart';
import 'package:minigame/games/flappy_bird/flappy_bird_game_page.dart';
import 'package:minigame/games/snake_game/screens/snake_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Mini Game Collection',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildGameCard(
                        context,
                        'Snake Game',
                        Colors.red.shade400,
                        Icons.sports_esports,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SnakeScreen(),
                            
                          ),
                        ),
                      ),
                      _buildGameCard(
                        context,
                        'Flappy Bird',
                        Colors.blue.shade400,
                        Icons.flight,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlappyBirdGamePage(),
                          ),
                        ),
                      ),
                      _buildGameCard(
                        context,
                        'Brick Breaker',
                        Colors.green.shade400,
                        Icons.sports_volleyball,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const brick_breaker(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    final scoreProvider = Provider.of<ScoreProvider>(context);
    final highScore = scoreProvider.getHighScore(title);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'High Score: $highScore',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
