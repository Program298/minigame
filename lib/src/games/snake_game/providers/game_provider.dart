import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minigame/src/games/snake_game/models/snake.dart';

class GameProvider extends ChangeNotifier {
  static const int boardWidth = 20;
  static const int boardHeight = 20;
  static const Duration gameSpeed = Duration(milliseconds: 200);

  Snake? snake;
  Food? food;
  Timer? gameTimer;
  int score = 0;
  bool isGameOver = false;
  bool isGamePaused = false;
  bool isMusicPlaying = false;

  final AudioPlayer backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer eatSoundPlayer = AudioPlayer();

  // GameProvider() {
  //   _loadAudio();
  // }

  // void _loadAudio() async {
  //   try {
  //     // Set up background music with looping
  //     await backgroundMusicPlayer.setAsset('assets/audio/background_music.mp3');
  //     await backgroundMusicPlayer.setLoopMode(LoopMode.one);
      
  //     // Set up eat sound effect
  //     await eatSoundPlayer.setAsset('assets/audio/eat_sound.mp3');
  //   } catch (e) {
  //     debugPrint('Error loading audio: $e');
  //   }
  // }

  void startGame() {
    snake = Snake(boardWidth ~/ 2, boardHeight ~/ 2);
    food = Food.generateRandom(boardWidth, boardHeight, snake!.positions);
    score = 0;
    isGameOver = false;
    isGamePaused = false;
    
    if (gameTimer != null && gameTimer!.isActive) {
      gameTimer!.cancel();
    }
    
    gameTimer = Timer.periodic(gameSpeed, _onTimerTick);
    // playBackgroundMusic();
    notifyListeners();
  }

  void _onTimerTick(Timer timer) {
    if (isGamePaused || isGameOver) return;

    snake!.move();

    // Check for collisions
    if (snake!.checkCollision(boardWidth, boardHeight)) {
      gameOver();
      return;
    }

    // Check if snake eats food
    if (snake!.eatFood(food!.position)) {
      score += 10;
      // playEatSound();
      food = Food.generateRandom(boardWidth, boardHeight, snake!.positions);
    }

    notifyListeners();
  }

  void changeDirection(Direction direction) {
    if (snake != null && !isGameOver) {
      snake!.changeDirection(direction);
    }
  }

  void togglePause() {
    isGamePaused = !isGamePaused;
    // if (isGamePaused) {
    //   pauseBackgroundMusic();
    // } else {
    //   resumeBackgroundMusic();
    // }
    notifyListeners();
  }

  void gameOver() {
    isGameOver = true;
    gameTimer?.cancel();
    // stopBackgroundMusic();
    notifyListeners();
  }

  void resetGame() {
    startGame();
  }

  // void playBackgroundMusic() async {
  //   try {
  //     if (!isMusicPlaying) {
  //       await backgroundMusicPlayer.play();
  //       isMusicPlaying = true;
  //     }
  //   } catch (e) {
  //     debugPrint('Error playing background music: $e');
  //   }
  // }

  // void pauseBackgroundMusic() async {
  //   try {
  //     if (isMusicPlaying) {
  //       await backgroundMusicPlayer.pause();
  //       isMusicPlaying = false;
  //     }
  //   } catch (e) {
  //     debugPrint('Error pausing background music: $e');
  //   }
  // }

  // void resumeBackgroundMusic() async {
  //   try {
  //     if (!isMusicPlaying) {
  //       await backgroundMusicPlayer.play();
  //       isMusicPlaying = true;
  //     }
  //   } catch (e) {
  //     debugPrint('Error resuming background music: $e');
  //   }
  // }

  // void stopBackgroundMusic() async {
  //   try {
  //     await backgroundMusicPlayer.stop();
  //     isMusicPlaying = false;
  //   } catch (e) {
  //     debugPrint('Error stopping background music: $e');
  //   }
  // }

  // void playEatSound() async {
  //   try {
  //     await eatSoundPlayer.seek(Duration.zero);
  //     await eatSoundPlayer.play();
  //   } catch (e) {
  //     debugPrint('Error playing eat sound: $e');
  //   }
  // }

  @override
  void dispose() {
    // gameTimer?.cancel();
    // backgroundMusicPlayer.dispose();
    // eatSoundPlayer.dispose();
    super.dispose();
  }
}
