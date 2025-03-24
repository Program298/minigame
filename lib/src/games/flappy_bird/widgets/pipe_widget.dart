import 'package:flutter/material.dart';
import '../models/pipe.dart';

class PipeWidget extends StatelessWidget {
  final Pipe pipe;

  const PipeWidget({Key? key, required this.pipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top pipe
        Positioned(
          left: pipe.x,
          top: 0,
          child: Transform.flip(
            flipY: true,
            child: Image.asset(
              'assets/images/pipe_top.png',
              width: pipe.width,
              height: pipe.topHeight,
              fit: BoxFit.fill,
              //  package: 'flappy_bird_game',
            ),
          ),
        ),
        
        // Bottom pipe
        Positioned(
          left: pipe.x,
          top: pipe.topHeight + pipe.gapHeight,
          child: Image.asset(
            'assets/images/pipe_bottom.png',
            width: pipe.width,
            height: pipe.bottomHeight,
            fit: BoxFit.fill,
            // package: 'flappy_bird_game',
          ),
        ),
      ],
    );
  }
}
