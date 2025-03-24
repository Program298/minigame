/// Represents the current state of the Flappy Bird game.
enum GameState {
  /// The game is at the start screen, waiting for the player to begin.
  start,
  
  /// The game is actively being played.
  playing,
  
  /// The game is temporarily paused.
  paused,
  
  /// The game has ended due to the player losing.
  gameOver,
}
