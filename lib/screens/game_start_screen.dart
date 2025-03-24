import 'package:flutter/material.dart';
import 'package:minigame/models/game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_shadow/simple_shadow.dart';

class GameStartScreen extends StatelessWidget {
  final Game game;

  const GameStartScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor;

    switch (game.id) {
      case '1':
        cardColor = const Color(0xFF4CAF50);
        break;
      case '2':
        cardColor = const Color(0xFFF44336);
        break;
      case '3':
        cardColor = const Color(0xFFFFB74D);
        break;
      default:
        cardColor = const Color(0xFF4CAF50);
    }

    return Scaffold(
      backgroundColor: cardColor,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    game.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    game.title,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < game.rating.floor()
                                ? Icons.star
                                : index < game.rating
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        game.rating.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ' ${game.Description}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // If the game has a screen property, navigate to it
                        if (game.screen != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => game.screen!,
                            ),
                          );
                        } else {
                          // Show a message if no screen is available
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${game.title} game is not available yet.',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: cardColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Start Game',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // Character image with overflow effect
            Positioned(

              right: 50,
              bottom: 120,
              child: Hero(
                tag: 'game-image-${game.id}',
                    child: SimpleShadow(
                opacity: 0.5, // ความทึบของเงา
                color: Colors.black, // สีของเงา
                offset: const Offset(2, 4), // ตำแหน่งของเงา (x, y)
                sigma: 5, // ความเบลอของเงา
                child: Image.asset(
                  game.imageUrl,
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
