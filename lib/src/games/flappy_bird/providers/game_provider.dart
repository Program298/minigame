import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/bird.dart';
import '../models/pipe.dart';
import '../models/game_state.dart';

class GameProvider extends ChangeNotifier {
  // Game state
  GameState _gameState = GameState.start;
  GameState get gameState => _gameState;
  
  // Game objects
  late Bird bird;
  List<Pipe> pipes = [];
  
  // Game settings
  final double screenWidth = 360;
  final double screenHeight = 960;
  final double groundHeight = 100;
  final double pipeWidth = 60;
  final double pipeGap = 220;
  final double birdSize = 60;
  final double pipeDistance = 400;
  final double gameSpeed = 3.0;
  
  // Game variables
  int score = 0;
  int highScore = 0;
  double groundX = 0;
  Timer? gameTimer;
  final Random random = Random();
  
  // Audio
  // final AudioPlayer audioPlayer = AudioPlayer();
  
  // Difficulty settings
  final double pipeHitboxReduction = 0.05; // Reduce pipe hitbox by 5%
  
  GameProvider({int? initialHighScore}) {
    if (initialHighScore != null) {
      highScore = initialHighScore;
    } else {
      _loadHighScore();
    }
    
    _initGame();
  }

  void _initGame() {
    // Initialize bird
    bird = Bird(
      x: screenWidth / 4,
      y: screenHeight / 2,
      width: birdSize,
      height: birdSize,
    );
    
    // Initialize pipes
    pipes = [];
    
    // Reset score
    score = 0;
    
    // Reset ground position
    groundX = 0;
  }

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      highScore = prefs.getInt('flappyBirdHighScore') ?? 0;
      notifyListeners();
    } catch (e) {
      // Handle error or just use default 0
      print('Error loading high score: $e');
    }
  }

  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('flappyBirdHighScore', highScore);
    } catch (e) {
      print('Error saving high score: $e');
    }
  }

  void startGame() {
    if (_gameState != GameState.start && _gameState != GameState.gameOver) return;
    
    _initGame();
    _gameState = GameState.playing;
    
    // Start game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
    
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState != GameState.playing) return;
    
    _gameState = GameState.paused;
    gameTimer?.cancel();
    notifyListeners();
  }

  void resumeGame() {
    if (_gameState != GameState.paused) return;
    
    _gameState = GameState.playing;
    
    // Restart game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
    
    notifyListeners();
  }

  void resetGame() {
    gameTimer?.cancel();
    _gameState = GameState.start;
    _initGame();
    notifyListeners();
  }

  void onTap() {
    if (_gameState != GameState.playing) return;
    
    bird.jump();
    // _playSound('wing.wav');
  }

  void _updateGame() {
    // Update bird
    bird.update();
    
    // Update ground
    groundX -= gameSpeed;
    if (groundX <= -screenWidth) {
      groundX = 0;
    }
    
    // Update pipes
    for (var i = pipes.length - 1; i >= 0; i--) {
      pipes[i].update(gameSpeed);
      
      // Check if pipe is passed
      if (!pipes[i].passed && pipes[i].x + pipes[i].width < bird.x) {
        pipes[i].passed = true;
        score++;
        // _playSound('point.wav');
      }
      
      // Remove pipes that are off screen
      if (pipes[i].isOffScreen()) {
        pipes.removeAt(i);
      }
    }
    
    // Add new pipes if needed
    if (pipes.isEmpty || pipes.last.x < screenWidth - pipeDistance) {
      _addPipe();
    }
    
    // Check collisions
    if (_checkCollisions()) {
      _gameOver();
      return;
    }
    
    notifyListeners();
  }

  void _addPipe() {
    final pipeGapY = random.nextDouble() * (screenHeight - groundHeight - pipeGap - 100) + 50;
    
    pipes.add(Pipe(
      x: screenWidth,
      topHeight: pipeGapY,
      bottomHeight: screenHeight - groundHeight - pipeGapY - pipeGap,
      width: pipeWidth,
      gapHeight: pipeGap,
    ));
  }

  bool _checkCollisions() {
    // Check if bird hits the ground
    if (bird.y + bird.height > screenHeight - groundHeight) {
      return true;
    }
    
    // Check if bird hits the ceiling
    if (bird.y < 0) {
      return true;
    }
    
    // Check if bird hits any pipe
    for (var pipe in pipes) {
      // Apply hitbox reduction to pipes
      final double pipeWidthReduced = pipe.width * (1 - pipeHitboxReduction);
      final double pipeOffsetX = (pipe.width - pipeWidthReduced) / 2;
      
      // Check collision with top pipe (with reduced hitbox)
      if (bird.isCollidingWith(
        pipe.x + pipeOffsetX, 
        0, 
        pipeWidthReduced, 
        pipe.topHeight
      )) {
        return true;
      }
      
      // Check collision with bottom pipe (with reduced hitbox)
      if (bird.isCollidingWith(
        pipe.x + pipeOffsetX,
        pipe.topHeight + pipe.gapHeight,
        pipeWidthReduced,
        pipe.bottomHeight,
      )) {
        return true;
      }
    }
    
    return false;
  }

  void _gameOver() {
    // _playSound('hit.wav');
    
    gameTimer?.cancel();
    _gameState = GameState.gameOver;
    
    // Update high score if needed
    if (score > highScore) {
      highScore = score;
      _saveHighScore();
    }
    
    notifyListeners();
  }

  // Future<void> _playSound(String soundFile) async {
  //   try {
  //     await audioPlayer.play(AssetSource('audio/$soundFile'));
  //   } catch (e) {
  //     print('Error playing sound: $e');
  //   }
  // }

  @override
  void dispose() {
    gameTimer?.cancel();
    // audioPlayer.dispose();
    super.dispose();
  }
}
