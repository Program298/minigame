import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:minigame/src/games/brick_breaker/game/brick_breaker_game.dart';
import 'package:minigame/src/games/brick_breaker/game/components/paddle.dart';
import 'package:minigame/src/games/brick_breaker/game/components/brick.dart';

enum PowerUpType {
  ballMultiplier,
  expandPaddle,
  speedBoost,
  slowMotion,
  extraLife,
}

class PowerUp extends SpriteComponent with HasGameRef<BrickBreakerGame>, CollisionCallbacks {
  final PowerUpType type;
  final Function(PowerUpType) onCollected;
  
  static const double fallSpeed = 100.0;
  Vector2 _previousPosition = Vector2.zero();
  
  PowerUp({
    required Vector2 position,
    required Vector2 size,
    required this.type,
    required this.onCollected,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load appropriate sprite based on power-up type
    final String imagePath;
    switch (type) {
      case PowerUpType.ballMultiplier:
        imagePath = 'power_up_ball_multiplier.png';
        break;
      case PowerUpType.expandPaddle:
        imagePath = 'power_up_expand_paddle.png';
        break;
      case PowerUpType.speedBoost:
        imagePath = 'power_up_speed_boost.png';
        break;
      case PowerUpType.slowMotion:
        imagePath = 'power_up_slow_motion.png';
        break;
      case PowerUpType.extraLife:
        imagePath = 'power_up_extra_life.png';
        break;
    }
    
    try {
      sprite = await gameRef.loadSprite(imagePath);
    } catch (e) {
      // Fallback to colored rectangle if image not found
      final paint = Paint()..color = _getColorForType(type);
      add(RectangleComponent(
        size: size,
        paint: paint,
      ));
    }
    
    // Add hitbox
    add(RectangleHitbox());
    
    // Store initial position
    _previousPosition.setFrom(position);
  }
  
  Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.ballMultiplier:
        return Colors.purple;
      case PowerUpType.expandPaddle:
        return Colors.blue;
      case PowerUpType.speedBoost:
        return Colors.orange;
      case PowerUpType.slowMotion:
        return Colors.lightBlue;
      case PowerUpType.extraLife:
        return Colors.red;
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Store previous position for collision resolution
    _previousPosition.setFrom(position);
    
    // Move power-up down
    position.y += fallSpeed * dt;
    
    // Remove if it goes off screen
    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
      gameRef.powerUps.remove(this);
    }
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Paddle) {
      // Collect power-up
      onCollected(type);
      removeFromParent();
      gameRef.powerUps.remove(this);
    } else if (other is Brick) {
      // Prevent passing through intact bricks
      // Restore previous position
      position.setFrom(_previousPosition);
    }
  }
}
