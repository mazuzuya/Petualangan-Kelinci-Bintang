import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'world.dart';
import 'art.dart';
import 'renderer.dart';
import 'audio.dart';

const Map<String, double> _balance = {
  "moveSpeed": 155,
  "jumpVelocity": 430,
  "coyoteTime": 0.14,
  "effectsIntensity": 1,
};

class InputState implements InputLike {
  bool _left = false;
  bool _right = false;
  bool _jump = false;
  bool _jumpPressed = false;
  bool _jumpReleased = false;

  @override
  bool get left => _left;
  @override
  bool get right => _right;
  @override
  bool get jump => _jump;

  void setLeft(bool v) => _left = v;
  void setRight(bool v) => _right = v;
  void pressJump() {
    if (!_jump) _jumpPressed = true;
    _jump = true;
  }

  void releaseJump() {
    if (_jump) _jumpReleased = true;
    _jump = false;
  }

  @override
  bool consumeJumpPressed() {
    final v = _jumpPressed;
    _jumpPressed = false;
    return v;
  }

  @override
  bool consumeJumpReleased() {
    final v = _jumpReleased;
    _jumpReleased = false;
    return v;
  }
}

class CosmosUi {
  final int height;
  final int carrots;
  final int best;
  final String areaShort;
  final String areaName;
  final int stageIndex;
  final double intensity;
  final String phase;
  final String message;
  final bool messageVisible;
  final String selectedSkin;
  final int shield;
  final String power;
  final bool showSkins;
  final bool showResult;
  CosmosUi({
    required this.height,
    required this.carrots,
    required this.best,
    required this.areaShort,
    required this.areaName,
    required this.stageIndex,
    required this.intensity,
    required this.phase,
    required this.message,
    required this.messageVisible,
    required this.selectedSkin,
    this.shield = 0,
    this.power = "",
    this.showSkins = false,
    this.showResult = false,
  });
}

class GameController extends ChangeNotifier {
  final ValueNotifier<bool> ready = ValueNotifier(false);
  final ValueNotifier<CosmosUi> uiNotifier = ValueNotifier(
    CosmosUi(
      height: 0,
      carrots: 0,
      best: 0,
      areaShort: "MEADOW",
      areaName: "Padang Rumput",
      stageIndex: 0,
      intensity: 0,
      phase: "ready",
      message: "Tahan untuk lompat lebih tinggi",
      messageVisible: true,
      selectedSkin: "ranger",
    ),
  );
  final ValueNotifier<bool> showSkinsNotifier = ValueNotifier(false);
  final ValueNotifier<int> bank = ValueNotifier(0);
  final ValueNotifier<String> shopMessage = ValueNotifier("");
  final ValueNotifier<bool> showMapNotifier = ValueNotifier(false);
  bool _showResult = false;

  void sync(WorldState s, String selectedSkin) {
    _showResult = _showResult || s.phase == "gameover" || s.phase == "won";
    final player = s.player;
    final power = player.balloon > 0
        ? "BALON ${player.balloon.ceil()}s"
        : player.magnet > 0
        ? "MAGNET ${player.magnet.ceil()}s"
        : player.rangerBoost
        ? "LOMPAT 1,5×"
        : "";
    uiNotifier.value = CosmosUi(
      height: s.height,
      carrots: s.carrots,
      best: s.best,
      areaShort: AREAS[s.areaIndex].short,
      areaName: AREAS[s.areaIndex].name,
      stageIndex: s.stageIndex,
      intensity: s.intensity,
      phase: s.phase,
      message: s.message,
      messageVisible: s.messageTime > 0,
      selectedSkin: selectedSkin,
      shield: player.shield,
      power: power,
      showSkins: showSkinsNotifier.value,
      showResult: _showResult,
    );
  }

  void setShowSkins(bool v) => showSkinsNotifier.value = v;

  void setShowResult(bool v) {
    _showResult = v;
  }
}

class CosmosGame extends Game {
  final InputState input = InputState();
  final GameController controller;
  final AudioController audio = AudioController();
  Art? art;
  Renderer? renderer;
  World? world;
  bool loaded = false;
  String selectedSkin = "ranger";
  int best = 0;
  int bankCarrots = 0;
  final Set<String> ownedSkins = {"ranger"};
  int? savedCheckpointId;

  CosmosGame(this.controller);

  @override
  Future<void> onLoad() async {
    final save = await _loadSave();
    selectedSkin = save.skin;
    best = save.best;
    bankCarrots = save.bank;
    ownedSkins
      ..clear()
      ..addAll(save.owned);
    savedCheckpointId = save.checkpoint;
    art = await loadArt();
    renderer = Renderer(art!);
    await audio.prepare();
    world = World(
      balance: _balance,
      skinId: selectedSkin,
      best: best,
      startCheckpointId: savedCheckpointId,
    );
    loaded = true;
    controller.ready.value = true;
    controller.bank.value = bankCarrots;
    controller.sync(world!.state, selectedSkin);
    audio.startBgm(index: world!.state.areaIndex ~/ 4);
  }

  void _makeRun({int? checkpointId}) {
    world = World(
      balance: _balance,
      skinId: selectedSkin,
      best: best,
      startCheckpointId: checkpointId,
    );
    controller.setShowResult(false);
    controller.sync(world!.state, selectedSkin);
    audio.setArea(world!.state.areaIndex);
  }

  void retry() {
    // Platform 0 is a safe fallback so a fresh run is active immediately,
    // while saved progress still resumes from the latest real checkpoint.
    final checkpointId = savedCheckpointId ?? 0;
    _makeRun(checkpointId: checkpointId);
  }

  void openShop() {
    if (world != null) {
      bankCarrots += world!.state.carrots;
      world!.state.carrots = 0;
      _saveGame();
    }
    controller.bank.value = bankCarrots;
    controller.setShowSkins(true);
  }

  void grantTestCarrots() {
    bankCarrots = 9999;
    controller.bank.value = bankCarrots;
    controller.shopMessage.value = "Mode testing: 9999 wortel tersedia";
  }

  void travelToTestMap(int areaIndex) {
    if (areaIndex < 0 || areaIndex >= AREAS.length) return;
    final platformId = areaIndex * PLATFORMS_PER_AREA;
    _makeRun(checkpointId: platformId);
    audio.setArea(world!.state.areaIndex);
    controller.setShowSkins(false);
    controller.showMapNotifier.value = false;
    controller.shopMessage.value = "Testing map: ${AREAS[areaIndex].name}";
  }

  void chooseSkin(String id) {
    final skin = SKINS.firstWhere((s) => s.id == id, orElse: () => SKINS[0]);
    if (!ownedSkins.contains(id)) {
      if (bankCarrots < skin.price) {
        controller.shopMessage.value = "Wortel kurang! Butuh ${skin.price}";
        return;
      }
      bankCarrots -= skin.price;
      ownedSkins.add(id);
    }
    selectedSkin = id;
    final checkpointId = world?.state.player.checkpointPlatform.id;
    _saveGame();
    _makeRun(checkpointId: checkpointId);
    controller.setShowSkins(false);
    controller.shopMessage.value = "";
    controller.bank.value = bankCarrots;
  }

  void _finishRun(bool won) {
    best = math.max(best, world!.state.height);
    world!.state.best = best;
    bankCarrots += world!.state.carrots;
    world!.state.carrots = 0;
    _saveGame();
    controller.bank.value = bankCarrots;
    if (won) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _handleEvents(List<String> events) {
    for (final event in events) {
      if (event == "jump" || event == "super") {
        audio.unlock();
        if (event == "super") {
          audio.superJump();
        } else {
          audio.jump();
        }
      } else if (event == "land") {
        audio.land();
      } else if (event == "pickup") {
        audio.pickup();
      } else if (event == "combo") {
        audio.combo();
      } else if (event == "skill") {
        audio.skill();
      } else if (event == "checkpoint") {
        audio.checkpoint();
      } else if (event == "area") {
        audio.area();
      } else if (event == "hit") {
        audio.hit();
      } else if (event == "revive") {
        audio.revive();
      }
       if (event == "area") {
         HapticFeedback.lightImpact();
         audio.setArea(world!.state.areaIndex);
       }
      if (event == "checkpoint") {
        savedCheckpointId = world!.state.player.checkpointPlatform.id;
        _saveGame();
      }
      if (event == "gameover") {
        audio.gameOver();
        _finishRun(false);
      }
      if (event == "won") {
        audio.win();
        _finishRun(true);
      }
    }
  }

  @override
  void update(double dt) {
    if (!loaded || world == null) return;
    final step = math.min(0.033, math.max(0.001, dt));
    final events = world!.update(step, input);
    _handleEvents(events);
    controller.sync(world!.state, selectedSkin);
  }

  @override
  void render(Canvas canvas) {
    if (loaded && art != null && world != null && size.x > 0) {
      renderer!.render(canvas, Size(size.x, size.y), world!.state);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xff345e43),
      );
    }
  }

  Future<void> _saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('skin', selectedSkin);
      await prefs.setInt('best', best);
      await prefs.setString('owned', ownedSkins.join(','));
      await prefs.setInt('bank', bankCarrots);
      await prefs.setInt('checkpoint', savedCheckpointId ?? -1);
    } catch (_) {}
  }
}

// Persisted progress, mirroring game js/game/game.js (sdk.gameState save/load).
Future<({String skin, int best, List<String> owned, int bank, int? checkpoint})>
_loadSave() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final skinRaw = prefs.getString('skin');
    final skin = skinRaw != null && SKINS.any((s) => s.id == skinRaw)
        ? skinRaw
        : "ranger";
    final best = math.max(0, prefs.getInt('best') ?? 0);
    final ownedRaw = prefs.getString('owned');
    final owned =
        (ownedRaw?.isNotEmpty == true
                ? ownedRaw!.split(',').where((s) => s.isNotEmpty)
                : <String>[])
            .toList();
    if (!owned.contains('ranger')) owned.add('ranger');
    final bank = math.max(0, prefs.getInt('bank') ?? 0);
    final cp = prefs.getInt('checkpoint') ?? -1;
    return (
      skin: skin,
      best: best,
      owned: owned,
      bank: bank,
      checkpoint: cp >= 0 ? cp : null,
    );
  } catch (_) {
    return (
      skin: 'ranger',
      best: 0,
      owned: ['ranger'],
      bank: 0,
      checkpoint: null,
    );
  }
}
