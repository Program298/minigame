import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:minigame/src/games/brick_breaker/game/brick_breaker_game.dart';
import 'package:minigame/src/games/brick_breaker/game/components/brick.dart';
import 'package:minigame/src/games/brick_breaker/game/components/paddle.dart';

class Ball extends CircleComponent with HasGameRef<BrickBreakerGame>, CollisionCallbacks {
  Vector2 velocity;
  final Function(Ball) onBallLost;
  bool _collisionEnabled = true;
  
  // Reusable vectors to avoid object creation during gameplay
  final Vector2 _collisionNormal = Vector2.zero();
  final Vector2 _reflectionVector = Vector2.zero();
  final Vector2 _tempPosition = Vector2.zero();
  
  // Collision tracking
  final Map<int, int> _recentCollisions = {};
  static const int _collisionCooldownMs = 100;
  
  Ball({
    required Vector2 position,
    required double radius,
    required this.velocity,
    required this.onBallLost,
  }) : super(
    position: position,
    radius: radius,
    paint: Paint()..color = Colors.white,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add hitbox with slightly smaller size for more precise collision detection
    add(CircleHitbox(radius: radius * 0.9));
  }
  
@override
void update(double dt) {
  // จำกัด dt เพื่อป้องกันการกระโดดข้ามเฟรม
  final cappedDt = dt > 0.05 ? 0.05 : dt;
  
  super.update(cappedDt);
  
  // เก็บตำแหน่งก่อนเคลื่อนที่
  final previousPosition = Vector2(position.x, position.y);
  
  // คำนวณตำแหน่งใหม่
  final newPosition = position + velocity * cappedDt;
  
  // ตรวจสอบการชนด้วย Ray Casting ระหว่างตำแหน่งเก่าและตำแหน่งใหม่
  bool collision = false;
  Brick? hitBrick;
  Vector2? hitPoint;
  double closestDistance = double.infinity;
  
  // ตรวจสอบทุกก้อนอิฐ
  for (final component in parent!.children.whereType<Brick>()) {
    final brick = component as Brick;
    final brickRect = Rect.fromCenter(
      center: Offset(brick.position.x, brick.position.y),
      width: brick.size.x,
      height: brick.size.y,
    );
    
    // ตรวจสอบว่าเส้นทางของลูกบอลตัดกับอิฐหรือไม่
    final intersection = _lineRectIntersection(
      previousPosition.x, previousPosition.y,
      newPosition.x, newPosition.y,
      brickRect
    );
    
    if (intersection != null) {
      // คำนวณระยะทางจากตำแหน่งเก่าถึงจุดชน
      final distance = (intersection - previousPosition).length;
      
      // เลือกจุดชนที่ใกล้ที่สุด (อิฐก้อนแรกที่ชน)
      if (distance < closestDistance) {
        closestDistance = distance;
        hitBrick = brick;
        hitPoint = intersection;
        collision = true;
      }
    }
  }
  
  // ถ้ามีการชน
  if (collision && hitBrick != null && hitPoint != null) {
    // ย้ายลูกบอลไปยังจุดที่ชน
    position.setFrom(hitPoint!);
    
    // จัดการการชนกับอิฐ
    _handleBrickCollisionWithRayCast(hitBrick!, previousPosition);
  } else {
    // ไม่มีการชน ย้ายลูกบอลไปยังตำแหน่งใหม่
    position.setFrom(newPosition);
  }
  
  // ตรวจสอบขอบเขตหน้าจอเหมือนเดิม
  if (position.x <= radius) {
    position.x = radius;
    velocity.x = -velocity.x;
  } else if (position.x >= gameRef.size.x - radius) {
    position.x = gameRef.size.x - radius;
    velocity.x = -velocity.x;
  }
  
  if (position.y <= radius) {
    position.y = radius;
    velocity.y = -velocity.y;
  } else if (position.y >= gameRef.size.y + radius * 2) {
    onBallLost(this);
  }
}

// ฟังก์ชันตรวจสอบการตัดกันระหว่างเส้นและสี่เหลี่ยมผืนผ้า
Vector2? _lineRectIntersection(double x1, double y1, double x2, double y2, Rect rect) {
  // ตรวจสอบการตัดกันกับแต่ละด้านของสี่เหลี่ยม
  final lines = [
    [rect.left, rect.top, rect.right, rect.top],       // ด้านบน
    [rect.right, rect.top, rect.right, rect.bottom],   // ด้านขวา
    [rect.right, rect.bottom, rect.left, rect.bottom], // ด้านล่าง
    [rect.left, rect.bottom, rect.left, rect.top]      // ด้านซ้าย
  ];
  
  Vector2? closestIntersection;
  double minDistance = double.infinity;
  
  for (final line in lines) {
    final intersection = _lineLineIntersection(
      x1, y1, x2, y2,
      line[0], line[1], line[2], line[3]
    );
    
    if (intersection != null) {
      final distance = (Vector2(x1, y1) - intersection).length;
      if (distance < minDistance) {
        minDistance = distance;
        closestIntersection = intersection;
      }
    }
  }
  
  return closestIntersection;
}

// ฟังก์ชันตรวจสอบการตัดกันระหว่างเส้นสองเส้น
Vector2? _lineLineIntersection(
  double x1, double y1, double x2, double y2,
  double x3, double y3, double x4, double y4
) {
  // คำนวณตัวแบ่ง (denominator)
  final denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
  
  // ถ้าตัวแบ่งเป็น 0 แสดงว่าเส้นขนานกัน
  if (denom.abs() < 0.0001) return null;
  
  // คำนวณตัวเศษ
  final ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom;
  final ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom;
  
  // ตรวจสอบว่าจุดตัดอยู่บนส่วนของเส้นทั้งสองหรือไม่
  if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) {
    return Vector2(
      x1 + ua * (x2 - x1),
      y1 + ua * (y2 - y1)
    );
  }
  
  return null;
}

// ฟังก์ชันจัดการการชนด้วย Ray Casting
void _handleBrickCollisionWithRayCast(Brick brick, Vector2 previousPosition) {
  // คำนวณเวกเตอร์ปกติของการชน
  final brickRect = Rect.fromCenter(
    center: Offset(brick.position.x, brick.position.y),
    width: brick.size.x,
    height: brick.size.y,
  );
  
  // หาด้านที่ชน
  final Vector2 normal = _calculateCollisionNormal(previousPosition, position, brickRect);
  
  // คำนวณเวกเตอร์สะท้อน
  final incidentVector = velocity.normalized();
  final double dot = 2 * (incidentVector.dot(normal));
  final reflectionVector = incidentVector - normal.scaled(dot);
  
  // อัพเดตความเร็ว (เพิ่มขึ้นเล็กน้อยเพื่อป้องกันการติด)
  final speed = velocity.length * 1.01;
  velocity.setFrom(reflectionVector.normalized().scaled(speed));
  
  // เลื่อนลูกบอลออกจากอิฐเล็กน้อย
  position.add(normal.scaled(0.1));
  
  // ทำความเสียหายอิฐ
  brick.hit();
  
  // เพิ่มอิฐเข้าไปในรายการล่าสุดที่ชน
  final brickId = brick.hashCode;
  final now = DateTime.now().millisecondsSinceEpoch;
  _recentCollisions[brickId] = now;
}

// คำนวณเวกเตอร์ปกติของการชน
Vector2 _calculateCollisionNormal(Vector2 fromPoint, Vector2 toPoint, Rect rect) {
  final Vector2 normal = Vector2.zero();
  
  // คำนวณระยะห่างจากจุดชนถึงแต่ละด้านของอิฐ
  final distToLeft = (fromPoint.x - rect.left).abs();
  final distToRight = (fromPoint.x - rect.right).abs();
  final distToTop = (fromPoint.y - rect.top).abs();
  final distToBottom = (fromPoint.y - rect.bottom).abs();
  
  // หาด้านที่ใกล้ที่สุด
  final minDist = [distToLeft, distToRight, distToTop, distToBottom].reduce(min);
  
  if (minDist == distToLeft) {
    normal.setValues(-1, 0); // ชนด้านซ้าย
  } else if (minDist == distToRight) {
    normal.setValues(1, 0);  // ชนด้านขวา
  } else if (minDist == distToTop) {
    normal.setValues(0, -1); // ชนด้านบน
  } else {
    normal.setValues(0, 1);  // ชนด้านล่าง
  }
  
  return normal;
}
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_collisionEnabled) return;
    
    if (other is Brick) {
      // Check if we've recently collided with this brick
      final brickId = other.hashCode;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (_recentCollisions.containsKey(brickId) && 
          now - _recentCollisions[brickId]! < _collisionCooldownMs) {
        return; // Skip if we've recently collided with this brick
      }
      
      _handleBrickCollision(other, intersectionPoints);
      _recentCollisions[brickId] = now;
    }
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_collisionEnabled) return;
    
    if (other is Paddle) {
      _handlePaddleCollision(other);
    }
  }
  
  void _handlePaddleCollision(Paddle paddle) {
    // Calculate bounce angle based on where the ball hit the paddle
    final paddleCenter = paddle.position.x;
    final ballCenter = position.x;
    final relativeIntersection = (paddleCenter - ballCenter) / (paddle.size.x / 2);
    
    // Bounce angle between -60 and 60 degrees
    final bounceAngle = relativeIntersection * (pi / 3);
    
    // Set new velocity - reuse existing vector
    final speed = velocity.length;
    velocity.x = -speed * sin(bounceAngle);
    velocity.y = -speed * cos(bounceAngle).abs();
    
    // Move ball slightly above paddle to prevent multiple collisions
    position.y = paddle.position.y - radius - paddle.size.y / 2 - 1;
    
    // Temporarily disable collision to prevent multiple bounces
    _collisionEnabled = false;
    Future.delayed(const Duration(milliseconds: 50), () {
      _collisionEnabled = true;
    });
  }
  
  void _handleBrickCollision(Brick brick, Set<Vector2> intersectionPoints) {
    // Determine which side of the brick was hit by analyzing intersection points
    if (intersectionPoints.isEmpty) return;
    
    // Calculate the average intersection point
    final Vector2 averageIntersection = Vector2.zero();
    for (final point in intersectionPoints) {
      averageIntersection.add(point);
    }
    averageIntersection.scale(1 / intersectionPoints.length);
    
    // Determine collision side by comparing ball's previous position
    final brickRect = Rect.fromCenter(
      center: Offset(brick.position.x, brick.position.y),
      width: brick.size.x,
      height: brick.size.y,
    );
    
    // Calculate collision normal based on which side was hit
    _determineCollisionNormal(brickRect, _tempPosition, averageIntersection);
    
    // Calculate reflection vector - reuse existing vector
    final Vector2 incidentVector = velocity.normalized();
    final double dot = 2 * (incidentVector.dot(_collisionNormal));
    _reflectionVector
      ..setFrom(incidentVector)
      ..sub(_collisionNormal.scaled(dot))
      ..normalize();
    
    // Apply reflection with a slight speed increase to prevent sticking
    final double speed = velocity.length * 1.01; // Small speed boost
    velocity.setFrom(_reflectionVector.scaled(speed));
    
    // Move ball slightly away from brick to prevent sticking
    position.add(_collisionNormal.scaled(1.0));
    
    // Damage the brick
    brick.hit();
  }
  
  void _determineCollisionNormal(Rect brickRect, Vector2 previousPosition, Vector2 intersection) {
    // Determine if collision is more horizontal or vertical
    final double deltaX = (previousPosition.x - intersection.x).abs();
    final double deltaY = (previousPosition.y - intersection.y).abs();
    
    if (deltaX > deltaY) {
      // Horizontal collision (left or right side)
      if (previousPosition.x < brickRect.left) {
        // Left side collision
        _collisionNormal.setValues(-1, 0);
      } else if (previousPosition.x > brickRect.right) {
        // Right side collision
        _collisionNormal.setValues(1, 0);
      } else {
        // Fallback to vertical collision
        _collisionNormal.setValues(0, previousPosition.y < brickRect.top ? -1 : 1);
      }
    } else {
      // Vertical collision (top or bottom)
      if (previousPosition.y < brickRect.top) {
        // Top side collision
        _collisionNormal.setValues(0, -1);
      } else if (previousPosition.y > brickRect.bottom) {
        // Bottom side collision
        _collisionNormal.setValues(0, 1);
      } else {
        // Fallback to horizontal collision
        _collisionNormal.setValues(previousPosition.x < brickRect.left ? -1 : 1, 0);
      }
    }
  }
}
