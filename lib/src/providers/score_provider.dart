import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreProvider extends ChangeNotifier {
  final Map<String, int> _highScores = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  ScoreProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadScores();
    _initialized = true;
    notifyListeners();
  }

  void _loadScores() {
    if (_prefs == null) return;
    
    // Load high scores for all games
    final games = ['Snake Game', 'Flappy Bird', 'Brick Breaker'];
    
    for (final game in games) {
      final score = _prefs!.getInt('highScore_$game') ?? 0;
      _highScores[game] = score;
    }
  }

  int getHighScore(String gameName) {
    return _highScores[gameName] ?? 0;
  }

  Future<void> setHighScore(String gameName, int score) async {
    if (!_initialized) await _initPrefs();
    
    if (score > (_highScores[gameName] ?? 0)) {
      _highScores[gameName] = score;
      await _prefs?.setInt('highScore_$gameName', score);
      notifyListeners();
    }
  }
}
