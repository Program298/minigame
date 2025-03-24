import 'package:flutter/material.dart';
import 'models/bird.dart';
import 'models/pipe.dart';
import 'widgets/bird_widget.dart';
import 'widgets/pipe_widget.dart';
import 'widgets/ground_widget.dart';
import 'widgets/background_widget.dart';
import 'widgets/score_widget.dart';

class GameScreen extends StatelessWidget {
  final VoidCallback? onTap;
  final Bird bird;
  final List<Pipe> pipes;
  final int score;
  final double groundX;

  const GameScreen({
    Key? key,
    required this.onTap,
    required this.bird,
    required this.pipes,
    required this.score,
    required this.groundX,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.blue,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            const BackgroundWidget(),
            
            // Pipes
            ...pipes.map((pipe) => PipeWidget(pipe: pipe)),
            
            // Ground
            GroundWidget(groundX: groundX),
            
            // Bird
            BirdWidget(bird: bird),
            
            // Score
            ScoreWidget(score: score),
          ],
        ),
      ),
    );
  }
}
