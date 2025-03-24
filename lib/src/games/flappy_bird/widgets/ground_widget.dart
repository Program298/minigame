import 'package:flutter/material.dart';

class GroundWidget extends StatelessWidget {
  final double groundX;

  const GroundWidget({Key? key, required this.groundX}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: groundX,
      child: Row(
        children: [
          Image.asset(
            'assets/images/ground.png',
            width: MediaQuery.of(context).size.width,
            height: 100,
            fit: BoxFit.fill,
            // package: 'flappy_bird_game',
          ),
          Image.asset(
            'assets/images/ground.png',
            width: MediaQuery.of(context).size.width,
            height: 100,
            fit: BoxFit.fill,
            // package: 'flappy_bird_game',
          ),
        ],
      ),
    );
  }
}
