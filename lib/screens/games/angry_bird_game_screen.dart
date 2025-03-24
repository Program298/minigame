import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class AngryBirdGameScreen extends StatefulWidget {
  const AngryBirdGameScreen({Key? key}) : super(key: key);

  @override
  State<AngryBirdGameScreen> createState() => _AngryBirdGameScreenState();
}

class _AngryBirdGameScreenState extends State<AngryBirdGameScreen>
    with SingleTickerProviderStateMixin {
  int score = 0;
  late AnimationController _controller;
  double birdPositionY = 0;
  bool isFlying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void launchBird() {
    setState(() {
      isFlying = true;
      score += 10;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isFlying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB74D),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB74D),
        elevation: 0,
        title: Text(
          'Angry Bird Game',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Score: $score',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Sky background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.lightBlue.shade300,
                    Colors.lightBlue.shade100,
                  ],
                ),
              ),
            ),
          ),
          
          // Clouds
          Positioned(
            top: 50,
            left: 30,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(10 * math.sin(_controller.value * 2 * math.pi), 0),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            top: 100,
            right: 50,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-15 * math.sin(_controller.value * 2 * math.pi), 0),
                  child: Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Ground
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.brown.shade600,
            ),
          ),
          
          // Slingshot
          Positioned(
            bottom: 100,
            left: 50,
            child: Container(
              width: 20,
              height: 120,
              color: Colors.brown.shade800,
            ),
          ),
          
          // Bird
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOut,
            bottom: isFlying ? 300 : 120,
            left: isFlying ? 250 : 60,
            child: GestureDetector(
              onTap: launchBird,
              child: Hero(
                tag: 'game-image-3',
                child: Image.asset(
                  'assets/images/angry_bird.png',
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'แตะที่นกเพื่อยิง',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Reset button
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  score = 0;
                  isFlying = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFFB74D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'รีเซ็ต',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
