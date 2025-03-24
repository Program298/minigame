import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:minigame/src/games/brick_breaker/game/brick_breaker_game.dart';

class Brick extends RectangleComponent with HasGameRef<BrickBreakerGame>, CollisionCallbacks {
  final int initialHitPoints;
  int hitPoints;
  final Function(Vector2) onDestroyed;
  late TextComponent hitPointsText;
  
  // Solid collision hitbox
  late RectangleHitbox solidHitbox;
  
  Brick({
    required Vector2 position,
    required Vector2 size,
    required this.hitPoints,
    required this.onDestroyed,
  }) : 
    initialHitPoints = hitPoints,
    super(
      position: position,
      size: size,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.red,
    );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add solid hitbox with precise collision
    solidHitbox = RectangleHitbox(
      isSolid: true,  // Mark as solid to prevent pass-through
    );
    add(solidHitbox);
    
    // Add hit points text
    hitPointsText = TextComponent(
      text: hitPoints.toString(),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(hitPointsText);
  }
  
  void hit() {
    hitPoints--;
    
    // Update text
    hitPointsText.text = hitPoints.toString();
    
    // Update color opacity based on remaining hit points
    final opacity = 0.5 + (hitPoints / initialHitPoints) * 0.5; // Keep minimum opacity at 0.5
    paint.color = Colors.red.withOpacity(opacity);
    
    if (hitPoints <= 0) {
      // Remove from game and notify
      removeFromParent();
      gameRef.bricks.remove(this);
      onDestroyed(position);
    }
  }
}
