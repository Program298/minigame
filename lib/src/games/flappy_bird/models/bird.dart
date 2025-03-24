import 'dart:math';

class Bird {
  // Position
  double x;
  double y;
  
  // Size
  final double width;
  final double height;
  
  // Physics
  double velocity = 0;
  final double gravity = 0.6;
  final double jumpVelocity = -10.0;
  
  // Animation
  int wingIndex = 0;
  final List<String> wingImages = [
    'assets/images/bird_downflap.png',
    'assets/images/bird_midflap.png',
    'assets/images/bird_upflap.png',
  ];
  int frameCount = 0;
  
  // Rotation
  double rotation = 0;
  
  // Collision box reduction (percentage of the bird's size)
  final double collisionReduction = 0.3;

  Bird({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  void update() {
    // Apply gravity
    velocity += gravity;
    y += velocity;
    
    // Update rotation based on velocity
    rotation = min(pi / 4, max(-pi / 2, velocity * 0.04));
    
    // Update wing animation every 5 frames
    frameCount++;
    if (frameCount >= 5) {
      wingIndex = (wingIndex + 1) % wingImages.length;
      frameCount = 0;
    }
  }

  void jump() {
    velocity = jumpVelocity;
  }

  String get currentImage => wingImages[wingIndex];

  // Collision detection with reduced collision box
  bool isCollidingWith(double objectX, double objectY, double objectWidth, double objectHeight) {
    // Calculate reduced collision box dimensions
    final double reducedWidth = width * (1 - collisionReduction);
    final double reducedHeight = height * (1 - collisionReduction);
    
    // Calculate offset to center the reduced collision box
    final double offsetX = (width - reducedWidth) / 2;
    final double offsetY = (height - reducedHeight) / 2;
    
    // Check collision with reduced box
    return (x + offsetX) < (objectX + objectWidth) &&
           (x + offsetX + reducedWidth) > objectX &&
           (y + offsetY) < (objectY + objectHeight) &&
           (y + offsetY + reducedHeight) > objectY;
  }
  
  // For debugging - get the collision box coordinates
  Map<String, double> get collisionBox {
    final double reducedWidth = width * (1 - collisionReduction);
    final double reducedHeight = height * (1 - collisionReduction);
    final double offsetX = (width - reducedWidth) / 2;
    final double offsetY = (height - reducedHeight) / 2;
    
    return {
      'x': x + offsetX,
      'y': y + offsetY,
      'width': reducedWidth,
      'height': reducedHeight,
    };
  }
}
