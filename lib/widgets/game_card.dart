import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:minigame/models/game.dart';
import 'package:google_fonts/google_fonts.dart';


class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color darkColor;
    Color lightColor;

       switch (game.id) {
      case '1':
        darkColor = const Color(0xFF2E7D32); // สีเข้มของเขียว
        lightColor = const Color(0xFF81C784); // สีอ่อนของเขียว
        break;
      case '2':
        darkColor = const Color(0xFFC62828); // สีเข้มของแดง
        lightColor = const Color(0xFFE57373); // สีอ่อนของแดง
        break;
      case '3':
        darkColor = const Color(0xFFEF6C00); // สีเข้มของส้ม
        lightColor = const Color(0xFFFFCC80); // สีอ่อนของส้ม
        break;
      default:
        darkColor = const Color(0xFF2E7D32);
        lightColor = const Color(0xFF81C784);
    }


    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkColor, lightColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow children to overflow
        children: [
          // Content container
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      game.title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
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
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      game.rating.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Play',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Details',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
           Positioned(
            right: -10, // Negative value creates overflow effect
            top: -15,
            bottom: 0,
            child: Hero(
              tag: 'game-image-${game.id}',
              child: SimpleShadow(
                opacity: 0.5, // ความทึบของเงา
                color: Colors.black, // สีของเงา
                offset: const Offset(2, 4), // ตำแหน่งของเงา (x, y)
                sigma: 5, // ความเบลอของเงา
                child: Image.asset(
                  game.imageUrl,
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
           ),
        ],
      ),
    );
  }
}
