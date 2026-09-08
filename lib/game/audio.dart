import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioController {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _jumpPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = [AudioPlayer(), AudioPlayer()];
  final ValueNotifier<bool> muted = ValueNotifier(false);
  bool _ready = false;
  bool _bgmStarted = false;
  int? _bgmIndex;
  bool _jumpReady = false;
  bool _jumpBusy = false;
  bool _bgmBusy = false;
  int _sfxIndex = 0;
  final List<bool> _sfxBusy = [false, false];
  final List<String?> _sfxSource = [null, null];
  int _lastLandMs = 0;
  double sfxVolume = 0.28;
  double bgmVolume = 0.35;

  AudioContext _noFocusContext() => AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const <AVAudioSessionOptions>{
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
  );

  Future<void> _setup(AudioPlayer player, ReleaseMode mode) async {
    player.eventStream.listen((_) {}, onError: (_) {});
    await player.setAudioContext(_noFocusContext());
    await player.setReleaseMode(mode);
    await player.setVolume(0);
  }

  Future<void> startBgm({int index = 0}) async {
    if (!_ready) return;
    final nextIndex = index.clamp(0, 4).toInt();
    if (_bgmStarted && _bgmIndex == nextIndex) return;
    if (_bgmBusy) return;
    _bgmBusy = true;
    _bgmStarted = true;
    _bgmIndex = nextIndex;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setVolume(muted.value ? 0 : bgmVolume);
      await _bgmPlayer.play(AssetSource('audio/bgm${nextIndex + 1}.mp3'));
    } catch (_) {
      _bgmStarted = false;
      _bgmIndex = null;
    } finally {
      _bgmBusy = false;
    }
  }

  void setArea(int areaIndex) {
    unawaited(startBgm(index: areaIndex ~/ 4));
  }

  Future<void> prepare() async {
    AudioLogger.logLevel = AudioLogLevel.none;
    try {
      await _setup(_bgmPlayer, ReleaseMode.loop);
      await _setup(_jumpPlayer, ReleaseMode.stop);
      for (final player in _sfxPlayers) {
        await _setup(player, ReleaseMode.stop);
      }
      await _jumpPlayer.setVolume(sfxVolume);
      await _jumpPlayer.setSource(AssetSource('audio/sfx_jump.mp3'));
      _jumpReady = true;
      _ready = true;
    } catch (_) {
      _jumpReady = false;
      _ready = true;
    }
  }

  void unlock() {
    unawaited(startBgm(index: _bgmIndex ?? 0));
  }

  void toggleMute() {
    muted.value = !muted.value;
    unawaited(
      _bgmPlayer.setVolume(muted.value ? 0 : bgmVolume).catchError((_) {}),
    );
  }

  Future<void> _play(String filename, {double volumeScale = 1}) async {
    if (!_ready || muted.value) return;
    int slot = -1;
    for (int i = 0; i < _sfxPlayers.length; i += 1) {
      final index = (_sfxIndex + i) % _sfxPlayers.length;
      if (!_sfxBusy[index]) {
        slot = index;
        break;
      }
    }
    if (slot < 0) return;
    _sfxIndex = (slot + 1) % _sfxPlayers.length;
    _sfxBusy[slot] = true;
    final player = _sfxPlayers[slot];
    try {
      await player.setVolume((sfxVolume * volumeScale).clamp(0, 1).toDouble());
      if (_sfxSource[slot] != filename) {
        await player.stop();
        await player.setSource(AssetSource('audio/$filename'));
        _sfxSource[slot] = filename;
      } else {
        await player.seek(Duration.zero);
      }
      await player.resume();
    } catch (_) {
      _sfxSource[slot] = null;
    } finally {
      _sfxBusy[slot] = false;
    }
  }

  void jump() {
    if (!_ready || muted.value) return;
    if (!_jumpReady) {
      unawaited(_play('sfx_jump.mp3'));
      return;
    }
    if (_jumpBusy) return;
    _jumpBusy = true;
    unawaited(() async {
      try {
        await _jumpPlayer.seek(Duration.zero);
        await _jumpPlayer.resume();
      } catch (_) {
        _jumpReady = false;
      } finally {
        _jumpBusy = false;
      }
    }());
  }

  void superJump() => unawaited(_play('sfx_super_jump.mp3', volumeScale: 1.15));
  void land() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastLandMs < 120) return;
    _lastLandMs = now;
    unawaited(_play('sfx_land.mp3', volumeScale: 0.8));
  }

  void pickup() => unawaited(_play('sfx_pickup.mp3'));
  void combo() => unawaited(_play('sfx_click.mp3', volumeScale: 1.05));
  void skill() => unawaited(_play('sfx_skill.mp3', volumeScale: 1.1));
  void checkpoint() => unawaited(_play('checkpoint.wav', volumeScale: 1.15));
  void area() => unawaited(_play('sfx_area.mp3'));
  void hit() => unawaited(_play('sfx_hit.mp3', volumeScale: 1.15));
  void revive() => unawaited(_play('sfx_revive.mp3', volumeScale: 1.1));
  void gameOver() => unawaited(_play('sfx_gameover.mp3', volumeScale: 1.15));
  void win() => unawaited(_play('sfx_win.mp3', volumeScale: 1.15));
  void click() => unawaited(_play('sfx_click.mp3', volumeScale: 0.7));

  Future<void> dispose() async {
    muted.dispose();
    for (final p in _sfxPlayers) {
      unawaited(p.dispose());
    }
    await _jumpPlayer.dispose();
    await _bgmPlayer.dispose();
  }
}
