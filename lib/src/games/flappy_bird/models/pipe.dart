class Pipe {
  double x;
  final double topHeight;
  final double bottomHeight;
  final double width;
  final double gapHeight;
  bool passed = false;

  Pipe({
    required this.x,
    required this.topHeight,
    required this.bottomHeight,
    required this.width,
    required this.gapHeight,
  });

  void update(double speed) {
    x -= speed;
  }

  bool isOffScreen() {
    return x < -width;
  }
}
