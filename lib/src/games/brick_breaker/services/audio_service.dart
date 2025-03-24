import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio players
  late final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _soundEffectPlayers = {};

  // State
  bool _isMuted = false;
  bool _isPaused = false;
  double _musicVolume = 0.5;
  double _sfxVolume = 1.0;

  // Getters
  bool get isMuted => _isMuted;
  bool get isPaused => _isPaused;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // Initialize the audio service
  Future<void> initialize() async {
    try {
      // Load background music
      await _backgroundMusicPlayer.setAsset(
        'assets/audio/background_music.mp3',
      );
      await _backgroundMusicPlayer.setLoopMode(LoopMode.one);
      await _backgroundMusicPlayer.setVolume(_musicVolume);

      // Preload sound effects
      await _preloadSoundEffects([
        'brick_hit.mp3',
        'paddle_hit.mp3',
        'power_up.mp3',
        'game_over.mp3',
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing audio: $e');
      }
    }
  }

  // Preload sound effects
  Future<void> _preloadSoundEffects(List<String> soundEffects) async {
    for (final sound in soundEffects) {
      try {
        final player = AudioPlayer();
        await player.setAsset('assets/audio/brick_hit.mp3');
        await player.setVolume(_sfxVolume);
        _soundEffectPlayers[sound] = player;
        if (kDebugMode) {
          print('Successfully loaded sound effect: $sound');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load sound effect: $sound - $e');
        }
      }
    }
  }

  // Play background music
  Future<void> playBackgroundMusic() async {
    if (_isMuted || _isPaused) return;

    try {
      if (!_backgroundMusicPlayer.playing) {
        await _backgroundMusicPlayer.seek(Duration.zero);
        await _backgroundMusicPlayer.play();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing background music: $e');
      }
    }
  }

  // Play sound effect
  Future<void> playSoundEffect(String soundName) async {
    if (_isMuted || _isPaused) return;

    try {
      final player = _soundEffectPlayers[soundName];
      if (player != null) {
        await player.seek(Duration.zero);
        await player.play();
      } else {
        if (kDebugMode) {
          print('Sound effect not found: $soundName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound effect: $e');
      }
    }
  }

  // Pause all audio
  Future<void> pauseAll() async {
    _isPaused = true;
    try {
      await _backgroundMusicPlayer.pause();
      for (final player in _soundEffectPlayers.values) {
        await player.pause();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error pausing audio: $e');
      }
    }
  }

  // Resume all audio
  Future<void> resumeAll() async {
    _isPaused = false;
    if (_isMuted) return;

    try {
      await _backgroundMusicPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error resuming audio: $e');
      }
    }
  }

  // Mute/unmute all audio
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;

    try {
      if (muted) {
        await _backgroundMusicPlayer.pause();
      } else if (!_isPaused) {
        await _backgroundMusicPlayer.play();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting mute state: $e');
      }
    }
  }

  // Set music volume
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    try {
      await _backgroundMusicPlayer.setVolume(volume);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting music volume: $e');
      }
    }
  }

  // Set sound effects volume
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    try {
      for (final player in _soundEffectPlayers.values) {
        await player.setVolume(volume);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting SFX volume: $e');
      }
    }
  }

  // Dispose all audio players
  Future<void> dispose() async {
    try {
      await _backgroundMusicPlayer.dispose();
      for (final player in _soundEffectPlayers.values) {
        await player.dispose();
      }
      _soundEffectPlayers.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing audio: $e');
      }
    }
  }
}
