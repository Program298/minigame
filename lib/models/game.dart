import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minigame/src/games/snake_game/screens/snake_screen.dart';
import 'package:minigame/src/games/flappy_bird/flappy_bird_game_page.dart';
import 'package:minigame/src/games/brick_breaker/screens/brick_breaker_screen.dart';
import 'package:minigame/src/games/brick_breaker/screens/game_screen.dart';

class Game {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final double price;
  final Widget? screen;
  final String Description;

  Game({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.screen,
    required this.Description,
  });
}

final List<Game> games = [
  Game(
    id: '1',
    title: 'Flappy Bird',
    subtitle: '',
    imageUrl: 'assets/images/bird_downflap.png',
    rating: 4.0,
    price: 14.99,
    screen: FlappyBirdGamePage(),
    Description: 'A game where players tap the screen to make a bird flap its wings and stay airborne. The goal is to navigate through gaps between pipes without crashing.',
  ),
  Game(
    id: '2',
    title: 'brick breaker',
    subtitle: '',
    imageUrl: 'assets/images/brick_breaker_logo.png',
    rating: 4.5,
    price: 7.99,
    screen: GameScreen(),
    Description: 'A game where players control a paddle to bounce a ball and break bricks on the screen. The goal is to destroy all the bricks without letting the ball fall off the screen.',
  ),
  Game(
    id: '3',
    title: 'Snake Game',
    subtitle: '',
    imageUrl: 'assets/images/angry_bird.png',
    rating: 4.2,
    price: 14.99,
    screen: SnakeScreen(),
    Description: 'A game where players tap the screen to make a bird flap its wings and stay airborne. The goal is to navigate through gaps between pipes without crashing.',
  ),
];
