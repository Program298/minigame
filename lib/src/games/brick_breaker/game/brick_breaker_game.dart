import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:minigame/src/games/brick_breaker/game/components/ball.dart';
import 'package:minigame/src/games/brick_breaker/game/components/brick.dart';
import 'package:minigame/src/games/brick_breaker/game/components/paddle.dart';
import 'package:minigame/src/games/brick_breaker/game/components/power_up.dart';
import 'package:minigame/src/games/brick_breaker/game/components/score_text.dart';
import 'package:minigame/src/games/brick_breaker/game/components/lives_display.dart';
// import 'package:minigame/src/games/brick_breaker/services/audio_service.dart';

class BrickBreakerGame extends FlameGame with HasCollisionDetection, PanDetector {
  final Function(int) onGameOver;
  
  // Game components
  late Paddle paddle;
  final List<Ball> balls = [];
  final List<Brick> bricks = [];
  final List<PowerUp> powerUps = [];
  late ScoreText scoreText;
  late LivesDisplay livesDisplay;
  
  // Game state
  bool isGameStarted = false;
  int score = 0;
  int lives = 3;
  int currentLevel = 1;
  final Random random = Random();
  bool isTransitioningLevel = false;
  
  // Power-up timers
  Timer? expandPaddleTimer;
  Timer? slowMotionTimer;
  
  // Performance optimization
  final Vector2 _tempVector = Vector2.zero();
  int _lastPowerUpTime = 0;
  bool _isProcessingPowerUp = false;
  
  // Audio service
  // final AudioService _audioService = AudioService();
  
  // Level transition components
  TextComponent? levelCompleteText;
  Timer? levelTransitionTimer;
  
  BrickBreakerGame({required this.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize audio service
    // await _audioService.initialize();
    
    // Add background
    add(
      SpriteComponent(
        sprite: await loadSprite('bg3.png'),
        size: size,
      ),
    );
    
    // Add paddle
    paddle = Paddle(
      position: Vector2(size.x / 2, size.y - 50),
      size: Vector2(100, 20),
    );
    add(paddle);
    
    // Add score display
    scoreText = ScoreText(position: Vector2(20, 20));
    add(scoreText);
    
    // Add lives display
    livesDisplay = LivesDisplay(position: Vector2(size.x - 20, 20), lives: lives);
    add(livesDisplay);
    
    // Setup initial bricks
    await setupBricks();
  }
  
  Future<void> setupBricks() async {
    // Clear any existing bricks first
    for (final brick in [...bricks]) {
      brick.removeFromParent();
    }
    bricks.clear();
    
    // Configure level difficulty based on current level
    final int rows = min(5 + (currentLevel ~/ 2), 8); // Increase rows with level, max 8
    final int bricksPerRow = min(8 + (currentLevel ~/ 3), 12); // Increase bricks per row, max 12
    
    // Adjust brick size based on number of bricks to fit screen
    final double brickWidth = size.x / (bricksPerRow + 1);
    const double brickHeight = 25;
    const double padding = 5;
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < bricksPerRow; j++) {
        // Calculate hit points based on row and level
        final int baseHitPoints = rows - i;
        final int levelBonus = (currentLevel - 1) ~/ 3;
        final int hitPoints = min(baseHitPoints + levelBonus, 5); // Cap at 5 hit points
        
        final brick = Brick(
          position: Vector2(
            j * (brickWidth + padding) + brickWidth / 2 + padding,
            i * (brickHeight + padding) + brickHeight / 2 + 100,
          ),
          size: Vector2(brickWidth, brickHeight),
          hitPoints: hitPoints,
          onDestroyed: (position) {
            score += hitPoints * 10;
            scoreText.updateScore(score);
            
            // Play brick hit sound
            // _audioService.playSoundEffect('brick_hit.mp3');
            
            // Chance to spawn power-up - with throttling
            final currentTime = DateTime.now().millisecondsSinceEpoch;
            if (random.nextDouble() < 0.3 && currentTime - _lastPowerUpTime > 500) {
              spawnPowerUp(position);
              _lastPowerUpTime = currentTime;
            }
            
            // Check if all bricks are destroyed
            if (bricks.isEmpty && !isTransitioningLevel) {
              completeLevel();
            }
          },
        );
        bricks.add(brick);
        add(brick);
      }
    }
  }
  
  void completeLevel() {
    isTransitioningLevel = true;
    
    // Play level complete sound
    // _audioService.playSoundEffect('power_up.mp3');
    
    // Show level complete text
    levelCompleteText = TextComponent(
      text: 'LEVEL $currentLevel COMPLETE!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    
    // Add scale animation to the text
    levelCompleteText!.add(
      SequenceEffect(
        [
          ScaleEffect.by(
            Vector2.all(1.2),
            EffectController(duration: 0.5, curve: Curves.elasticOut),
          ),
          ScaleEffect.by(
            Vector2.all(0.8),
            EffectController(duration: 0.3, curve: Curves.easeInOut),
          ),
        ],
        infinite: true,
      ),
    );
    
    add(levelCompleteText!);
    
    // Schedule level transition
    levelTransitionTimer = Timer(3, onTick: () {
      resetForNextLevel();
    });
  }
  
  void resetForNextLevel() {
    // Increment level
    currentLevel++;
    
    // Remove level complete text
    levelCompleteText?.removeFromParent();
    levelCompleteText = null;
    
    // Clear all game elements except paddle
    clearGameElements();
    
    // Reset paddle position
    paddle.position = Vector2(size.x / 2, size.y - 50);
    paddle.size = Vector2(100, 20);
    
    // Cancel any active power-up timers
    expandPaddleTimer?.stop();
    expandPaddleTimer = null;
    slowMotionTimer?.stop();
    slowMotionTimer = null;
    
    // Add a new ball
    addBall();
    
    // Setup new bricks for the next level
    setupBricks();
    
    // Update displays
    scoreText.updateScore(score);
    livesDisplay.updateLives(lives);
    
    // Reset transition flag
    isTransitioningLevel = false;
  }
  
  void clearGameElements() {
    // Clear all balls
    for (final ball in [...balls]) {
      ball.removeFromParent();
    }
    balls.clear();
    
    // Clear all power-ups
    for (final powerUp in [...powerUps]) {
      powerUp.removeFromParent();
    }
    powerUps.clear();
    
    // Clear any other projectiles or temporary components
    // (Add more specific cleanup for any other game elements)
    
    // Remove any effects from paddle
    paddle.children.whereType<Effect>().forEach((effect) {
      effect.removeFromParent();
    });
  }
  
  void startGame() {
    if (isGameStarted) return;
    
    isGameStarted = true;
    score = 0;
    lives = 3;
    currentLevel = 1;
    
    // Start background music
    // _audioService.playBackgroundMusic();
    
    // Reset paddle
    paddle.size = Vector2(100, 20);
    paddle.position = Vector2(size.x / 2, size.y - 50);
    
    // Clear existing balls and add a new one
    clearGameElements();
    
    // Add initial ball
    addBall();
    
    // Update score and lives display
    scoreText.updateScore(score);
    livesDisplay.updateLives(lives);
    
    // Setup bricks for level 1
    setupBricks();
  }
  
  void addBall() {
    final ball = Ball(
      position: Vector2(paddle.position.x, paddle.position.y - 20),
      radius: 10,
      velocity: Vector2(random.nextDouble() * 200 - 100, -300),
      onBallLost: handleBallLost,
    );
    balls.add(ball);
    add(ball);
  }
  
  void handleBallLost(Ball ball) {
    ball.removeFromParent();
    balls.remove(ball);
    
    if (balls.isEmpty && !isTransitioningLevel) {
      lives--;
      livesDisplay.updateLives(lives);
      
      // Play sound effect
      // _audioService.playSoundEffect('game_over.mp3');
      
      if (lives <= 0) {
        gameOver();
      } else {
        addBall();
      }
    }
  }
  
  void gameOver() {
    isGameStarted = false;
    isTransitioningLevel = false;
    
    // Clear all game elements
    clearGameElements();
    
    // Cancel timers
    expandPaddleTimer?.stop();
    slowMotionTimer?.stop();
    levelTransitionTimer?.stop();
    
    // Pause audio
    // _audioService.pauseAll();
    
    // Notify game screen
    onGameOver(score);
  }
  
  void spawnPowerUp(Vector2 position) {
    final powerUpTypes = PowerUpType.values;
    final type = powerUpTypes[random.nextInt(powerUpTypes.length)];
    
    // Reuse vector to avoid object creation
    _tempVector.setFrom(position);
    
    final powerUp = PowerUp(
      position: _tempVector.clone(),
      size: Vector2(30, 30),
      type: type,
      onCollected: (PowerUpType collectedType) {
        // Play power-up sound
        // _audioService.playSoundEffect('power_up.mp3');
        
        // Use Future.microtask to avoid concurrent modification issues
        Future.microtask(() => activatePowerUp(collectedType));
      },
    );
    
    // Add a spawn animation
    powerUp.add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.3,
          reverseDuration: 0.3,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
    
    powerUps.add(powerUp);
    add(powerUp);
  }
  
  void activatePowerUp(PowerUpType type) {
    // Prevent concurrent activation of power-ups
    if (_isProcessingPowerUp) return;
    _isProcessingPowerUp = true;
    
    try {
      switch (type) {
        case PowerUpType.ballMultiplier:
          _activateBallMultiplier();
          break;
          
        case PowerUpType.expandPaddle:
          _activateExpandPaddle();
          break;
          
        case PowerUpType.speedBoost:
          _activateSpeedBoost();
          break;
          
        case PowerUpType.slowMotion:
          _activateSlowMotion();
          break;
          
        case PowerUpType.extraLife:
          _activateExtraLife();
          break;
      }
    } catch (e) {
      print('Error activating power-up: $e');
    } finally {
      _isProcessingPowerUp = false;
    }
  }
  
  void _activateBallMultiplier() {
    // Add two more balls - limit to prevent too many balls
    if (balls.length < 5 && balls.isNotEmpty) {
      for (int i = 0; i < 2; i++) {
        final ball = Ball(
          position: balls.first.position.clone(),
          radius: 10,
          velocity: Vector2(
            random.nextDouble() * 400 - 200,
            random.nextDouble() * -300 - 100,
          ),
          onBallLost: handleBallLost,
        );
        balls.add(ball);
        add(ball);
      }
    }
  }
  
  void _activateExpandPaddle() {
    // Expand paddle for 10 seconds
    expandPaddleTimer?.stop();
    
    // Add animation for paddle expansion
    paddle.add(
      ScaleEffect.to(
        Vector2(1.5, 1.0),
        EffectController(duration: 0.3),
      ),
    );
    
    paddle.size = Vector2(150, 20);
    expandPaddleTimer = Timer(10, onTick: () {
      // Add animation for paddle shrinking
      paddle.add(
        ScaleEffect.to(
          Vector2(1.0, 1.0),
          EffectController(duration: 0.3),
        ),
      );
      
      paddle.size = Vector2(100, 20);
    });
  }
  
  void _activateSpeedBoost() {
    // Increase ball speed
    for (final ball in balls) {
      ball.velocity = ball.velocity * 1.5;
      
      // Add trail effect
      ball.add(
        ColorEffect(
          Colors.orange,
          EffectController(duration: 0.3, infinite: true, alternate: true),
          opacityTo: 0.7,
        ),
      );
    }
  }
  
  void _activateSlowMotion() {
    // Slow down balls for 5 seconds
    slowMotionTimer?.stop();
    for (final ball in balls) {
      ball.velocity = ball.velocity * 0.5;
      
      // Add slow motion visual effect
      ball.add(
        ColorEffect(
          Colors.lightBlue,
          EffectController(duration: 0.3, infinite: true, alternate: true),
          opacityTo: 0.7,
        ),
      );
    }
    slowMotionTimer = Timer(5, onTick: () {
      for (final ball in [...balls]) {
        if (ball.parent != null) {
          ball.velocity = ball.velocity * 2;
          
          // Remove slow motion effect
          ball.children.whereType<ColorEffect>().forEach((effect) {
            effect.removeFromParent();
          });
        }
      }
    });
  }
  
  void _activateExtraLife() {
    // Safely add an extra life with visual feedback
    if (lives < 5) {  // Cap maximum lives
      lives++;
      livesDisplay.updateLives(lives);
      
      // Add a flash effect to the lives display
      // livesDisplay.add(
      //   ColorEffect(
      //     Colors.white,
      //     EffectController(duration: 0.2, reverseDuration: 0.2),
      //     opacityTo: 0.8,
      //   ),
      // );
    }
  }
  
  @override
  void update(double dt) {
    // Cap delta time to prevent large jumps after frame skips
    final cappedDt = dt > 0.05 ? 0.05 : dt;
    
    super.update(cappedDt);
    
    if (!isGameStarted) return;
    
    // Update timers
    expandPaddleTimer?.update(cappedDt);
    slowMotionTimer?.update(cappedDt);
    levelTransitionTimer?.update(cappedDt);
    
    // Play paddle hit sound when ball hits paddle
    for (final ball in balls) {
      if (ball.position.y >= paddle.position.y - paddle.size.y/2 - ball.radius &&
          ball.position.y <= paddle.position.y &&
          ball.position.x >= paddle.position.x - paddle.size.x/2 &&
          ball.position.x <= paddle.position.x + paddle.size.x/2 &&
          ball.velocity.y > 0) {
        // _audioService.playSoundEffect('paddle_hit.mp3');
      }
    }
  }
  
  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!isGameStarted || isTransitioningLevel) return;
    
    paddle.position.x += info.delta.global.x;
    
    // Keep paddle within screen bounds
    if (paddle.position.x < paddle.size.x / 2) {
      paddle.position.x = paddle.size.x / 2;
    } else if (paddle.position.x > size.x - paddle.size.x / 2) {
      paddle.position.x = size.x - paddle.size.x / 2;
    }
  }
  
  @override
  void onRemove() {
    // _audioService.dispose();
    super.onRemove();
  }
}
