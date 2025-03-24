import 'dart:math';
import 'package:flutter/material.dart';

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

enum Direction { up, down, left, right }

class Snake {
  List<Position> positions = [];
  Direction direction = Direction.right;
  bool growNextTime = false;

  Snake(int initialX, int initialY) {
    // Initialize with 3 segments
    positions = [
      Position(initialX, initialY),
      Position(initialX - 1, initialY),
      Position(initialX - 2, initialY),
    ];
  }

  Position get head => positions.first;

  void move() {
    Position newHead;

    switch (direction) {
      case Direction.up:
        newHead = Position(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Position(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Position(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Position(head.x + 1, head.y);
        break;
    }

    positions.insert(0, newHead);
    
    if (!growNextTime) {
      positions.removeLast();
    } else {
      growNextTime = false;
    }
  }

  void grow() {
    growNextTime = true;
  }

  bool checkCollision(int boardWidth, int boardHeight) {
    // Check if snake hits the walls
    if (head.x < 0 || head.y < 0 || head.x >= boardWidth || head.y >= boardHeight) {
      return true;
    }

    // Check if snake hits itself
    for (int i = 1; i < positions.length; i++) {
      if (head == positions[i]) {
        return true;
      }
    }

    return false;
  }

  bool eatFood(Position food) {
    if (head == food) {
      grow();
      return true;
    }
    return false;
  }

  void changeDirection(Direction newDirection) {
    // Prevent 180-degree turns
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    direction = newDirection;
  }
}

class Food {
  Position position;
  int foodType;

  Food(this.position, this.foodType);

  static Food generateRandom(int boardWidth, int boardHeight, List<Position> occupiedPositions) {
    Random random = Random();
    Position position;

    do {
      position = Position(
        random.nextInt(boardWidth),
        random.nextInt(boardHeight),
      );
    } while (occupiedPositions.contains(position));

    // Generate random food type (0-3 for different food images)
    int foodType = random.nextInt(4);

    return Food(position, foodType);
  }
}
