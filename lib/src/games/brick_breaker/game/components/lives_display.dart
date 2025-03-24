import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LivesDisplay extends TextComponent {
  int lives;
  
  LivesDisplay({required Vector2 position, required this.lives})
      : super(
          text: 'Lives: $lives',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: position,
          anchor: Anchor.topRight,
        );
  
  void updateLives(int newLives) {
    lives = newLives;
    text = 'Lives: $lives';
  }
}
