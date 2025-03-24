import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreText extends TextComponent {
  int score = 0;
  
  ScoreText({required Vector2 position})
      : super(
          text: 'Score: 0',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: position,
        );
  
  void updateScore(int newScore) {
    score = newScore;
    text = 'Score: $score';
  }
}
