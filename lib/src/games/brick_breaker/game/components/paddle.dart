import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:minigame/src/games/brick_breaker/game/brick_breaker_game.dart';

class Paddle extends RectangleComponent with HasGameRef<BrickBreakerGame>, CollisionCallbacks {
  Paddle({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
    paint: Paint()..color = Colors.blue,
    children: [RectangleHitbox()],
  );
}
