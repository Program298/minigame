import 'package:flutter/material.dart';
import '../models/bird.dart';

class BirdWidget extends StatelessWidget {
  final Bird bird;

  const BirdWidget({Key? key, required this.bird}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: bird.x,
      top: bird.y,
      child: Transform.rotate(
        angle: bird.rotation,
        child: Image.asset(
          bird.currentImage,
          width: bird.width,
          height: bird.height,
          // package: 'flappy_bird_game',
        ),
      ),
    );
  }
}
