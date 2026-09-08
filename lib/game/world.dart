import 'dart:math' as math;
import 'config.dart';

double seeded(num index) {
  final value = math.sin(index * 91.73 + 17.2) * 43758.5453;
  return value - value.floor();
}

class Platform {
  int id;
  int area;
  double x;
  double baseX;
  double y;
  double width;
  String kind;
  int visualVariant;
  int stage;
  bool moving;
  double moveRange;
  double moveSpeed;
  double phase;
  double fallTimer;
  bool fallen;
  bool thorn;
  bool checkpoint;
  bool checkpointClaimed;
  double effectTime;
  String effectKind;
  Platform(
    this.id,
    this.area,
    this.x,
    this.baseX,
    this.y,
    this.width,
    this.kind,
    this.visualVariant,
    this.stage,
    this.moving,
    this.moveRange,
    this.moveSpeed,
    this.phase,
    this.fallTimer,
    this.fallen,
    this.thorn,
    this.checkpoint,
    this.checkpointClaimed,
    this.effectTime,
    this.effectKind,
  );
}

class Pickup {
  String id;
  String type;
  double x;
  double y;
  bool collected;
  double bob;
  Pickup(this.id, this.type, this.x, this.y, this.collected, this.bob);
}

class Enemy {
  String id;
  String type;
  double x;
  double baseY;
  double y;
  double direction;
  double speed;
  bool active;
  double phase;
  Enemy(
    this.id,
    this.type,
    this.x,
    this.baseY,
    this.y,
    this.direction,
    this.speed,
    this.active,
    this.phase,
  );
}

class Guardian {
  String id;
  int area;
  String animation;
  int sheet;
  bool reward;
  double x;
  double baseY;
  double y;
  double direction;
  double speed;
  double phase;
  bool active;
  double hitCooldown;
  Guardian(
    this.id,
    this.area,
    this.animation,
    this.sheet,
    this.reward,
    this.x,
    this.baseY,
    this.y,
    this.direction,
    this.speed,
    this.phase,
    this.active,
    this.hitCooldown,
  );
}

class Weather {
  String id;
  int area;
  String animation;
  int sheet;
  bool harmful;
  String force;
  double direction;
  double x;
  double y;
  double phase;
  int eventIndex;
  int frame;
  int cycle;
  int hitCycle;
  Weather(
    this.id,
    this.area,
    this.animation,
    this.sheet,
    this.harmful,
    this.force,
    this.direction,
    this.x,
    this.y,
    this.phase,
    this.eventIndex,
    this.frame,
    this.cycle,
    this.hitCycle,
  );
}

class Landmark {
  String name;
  int sheet;
  int area;
  double x;
  double y;
  double width;
  Landmark(this.name, this.sheet, this.area, this.x, this.y, this.width);
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  String color;
  Particle(this.x, this.y, this.vx, this.vy, this.life, this.color);
}

class Player {
  double x;
  double y;
  double previousY;
  double vx;
  double vy;
  double w;
  double h;
  double facing;
  bool grounded;
  double coyote;
  double jumpHold;
  double airTime;
  double wallCooldown;
  Skin skin;
  Platform lastPlatform;
  int shield;
  double magnet;
  double balloon;
  double invulnerable;
  double cyberCooldown;
  double dragonCooldown;
  int skinCounter;
  int rangerSteps;
  bool rangerBoost;
  bool revived;
  Platform checkpointPlatform;
  int checkpointRescues;
  Player(
    this.x,
    this.y,
    this.previousY,
    this.vx,
    this.vy,
    this.w,
    this.h,
    this.facing,
    this.grounded,
    this.coyote,
    this.jumpHold,
    this.airTime,
    this.wallCooldown,
    this.skin,
    this.lastPlatform,
    this.shield,
    this.magnet,
    this.balloon,
    this.invulnerable,
    this.cyberCooldown,
    this.dragonCooldown,
    this.skinCounter,
    this.rangerSteps,
    this.rangerBoost,
    this.revived,
    this.checkpointPlatform,
    this.checkpointRescues,
  );
}

class ComboFx {
  double time;
  double x;
  double y;
  ComboFx(this.time, this.x, this.y);
}

class SkillFx {
  double time;
  double x;
  double y;
  String effect;
  int sheet;
  SkillFx(this.time, this.x, this.y, this.effect, this.sheet);
}

class Storm {
  double x;
  int cycle;
  bool struck;
  Storm(this.x, this.cycle, this.struck);
}

class WorldState {
  String phase;
  double time;
  double cameraY;
  double viewHeight;
  int areaIndex;
  int stageIndex;
  int previousArea;
  int height;
  int best;
  int carrots;
  int combo;
  String message;
  double messageTime;
  double shake;
  double flash;
  double intensity;
  ComboFx comboFx;
  SkillFx skillFx;
  List<Platform> platforms;
  List<Pickup> pickups;
  List<Enemy> enemies;
  List<Guardian> guardians;
  List<Weather> weather;
  List<Landmark> landmarks;
  Storm storm;
  List<Particle> particles;
  Player player;
  WorldState(
    this.phase,
    this.time,
    this.cameraY,
    this.viewHeight,
    this.areaIndex,
    this.stageIndex,
    this.previousArea,
    this.height,
    this.best,
    this.carrots,
    this.combo,
    this.message,
    this.messageTime,
    this.shake,
    this.flash,
    this.intensity,
    this.comboFx,
    this.skillFx,
    this.platforms,
    this.pickups,
    this.enemies,
    this.guardians,
    this.weather,
    this.landmarks,
    this.storm,
    this.particles,
    this.player,
  );
}

abstract class InputLike {
  bool get left;
  bool get right;
  bool get jump;
  bool consumeJumpPressed();
  bool consumeJumpReleased();
}

Skin skinById(String id) =>
    SKINS.firstWhere((s) => s.id == id, orElse: () => SKINS[0]);

const double START_Y = 64;
const double GRAVITY = 1180;

List<Platform> makePlatforms() {
  final platforms = <Platform>[];
  double y = START_Y;
  double center = WORLD_WIDTH / 2;
  for (int i = 0; i < PLATFORM_COUNT; i += 1) {
    final area = math.min(AREAS.length - 1, (i / PLATFORMS_PER_AREA).floor());
    final local = i % PLATFORMS_PER_AREA;
    final stage = math.min(4, (local / 10).floor());
    final double width = i == 0
        ? 170.0
        : math.max(72.0, 132 - area * 3.2 - stage * 5 - seeded(i + 4) * 18);
    if (i > 0) {
      y += 76 + math.min(area, 8) * 1.8 + seeded(i) * 16;
      final direction = seeded(i + 2) > 0.5 ? 1 : -1;
      center += direction * (42 + seeded(i + 8) * 44);
      center = math.max(
        width / 2 + 14,
        math.min(WORLD_WIDTH - width / 2 - 14, center),
      );
    }
    String kind = "normal";
    if (i > 2 && [10, 30].contains(local))
      kind = "mushroom";
    else if (stage > 0 && area == 1 && local % 3 == 1)
      kind = "falling";
    else if (stage > 0 && area == 6 && local % 3 == 0)
      kind = "falling";
    else if (stage > 0 && area == 7 && local % 4 == 2)
      kind = "portal";
    else if (stage > 0 && area == 9 && local % 2 == 1)
      kind = "falling";
    else if (stage > 0 && [12, 13, 16, 19].contains(area) && local % 3 == 1)
      kind = "falling";
    else if (stage > 0 && area == 18 && local % 4 == 2)
      kind = "portal";
    final moving =
        stage > 0 &&
        ((area >= 1 && local % 4 == 2) ||
            (area >= 7 && local % 3 == 0) ||
            (area == 11 && local % 2 == 0));
    platforms.add(
      Platform(
        i,
        area,
        center - width / 2,
        center - width / 2,
        y,
        width,
        kind,
        local % 5,
        stage,
        moving,
        28 + math.min(area, 10) * 3.0,
        0.7 + seeded(i + 5) * 0.8,
        seeded(i + 7) * math.pi * 2,
        -1,
        false,
        stage > 1 && area > 0 && local % 6 == 5,
        i > 0 && local % 10 == 9,
        false,
        0,
        "",
      ),
    );
  }
  return platforms;
}

List<Pickup> makePickups(List<Platform> platforms) {
  final pickups = <Pickup>[];
  for (int index = 0; index < platforms.length; index += 1) {
    final platform = platforms[index];
    if (index == 0 || index % 2 == 0) continue;
    final special = index % 17 == 0
        ? "balloon"
        : index % 13 == 0
        ? "flower_shield"
        : index % 19 == 0
        ? "flying_carrot"
        : "carrot";
    pickups.add(
      Pickup(
        "pickup-$index",
        special,
        platform.baseX + platform.width * (0.3 + seeded(index + 12) * 0.4),
        platform.y + 40,
        false,
        seeded(index + 20) * math.pi * 2,
      ),
    );
    if (platform.stage == 2 && index % 4 == 1) {
      pickups.add(
        Pickup(
          "bonus-$index",
          "carrot",
          platform.baseX + platform.width * 0.84,
          platform.y + 68,
          false,
          seeded(index + 70) * math.pi * 2,
        ),
      );
    }
  }
  return pickups;
}

List<Enemy> makeEnemies(List<Platform> platforms) {
  final enemies = <Enemy>[];
  for (int index = 0; index < platforms.length; index += 1) {
    final platform = platforms[index];
    final area = platform.area;
    if (index < 20 ||
        platform.stage == 0 ||
        index % 4 != 3 ||
        ![1, 4, 5, 7, 9].contains(area))
      continue;
    final type = area == 1
        ? "owl"
        : area == 4
        ? "bee_swarm"
        : area == 5
        ? "icicle"
        : area == 7
        ? "ancient_orb"
        : "satellite";
    enemies.add(
      Enemy(
        "enemy-$index",
        type,
        seeded(index + 30) * WORLD_WIDTH,
        platform.y + 78,
        platform.y + 78,
        seeded(index + 31) > 0.5 ? 1 : -1,
        type == "icicle" ? 0 : 45 + area * 6,
        true,
        seeded(index + 32) * math.pi * 2,
      ),
    );
  }
  return enemies;
}

List<Guardian> makeGuardians(List<Platform> platforms) {
  final guardians = <Guardian>[];
  for (int area = 0; area < AREAS.length; area += 1) {
    for (int encounterIndex = 0; encounterIndex < 2; encounterIndex += 1) {
      final local = [17, 38][encounterIndex];
      final platform = platforms[area * PLATFORMS_PER_AREA + local];
      final encounter = AREA_ENCOUNTERS[area];
      guardians.add(
        Guardian(
          "guardian-$area-$encounterIndex",
          area,
          encounter.animation,
          encounter.sheet,
          encounter.reward,
          encounterIndex == 0 ? 72 : WORLD_WIDTH - 72,
          platform.y + 76,
          platform.y + 76,
          encounterIndex == 0 ? 1 : -1,
          32 + area * 4,
          encounterIndex * math.pi + area * 0.7,
          true,
          0,
        ),
      );
    }
  }
  return guardians;
}

List<Weather> makeWeather(List<Platform> platforms) {
  final weather = <Weather>[];
  for (int area = 0; area < AREAS.length; area += 1) {
    for (int eventIndex = 0; eventIndex < 3; eventIndex += 1) {
      final local = [9, 29, 46][eventIndex];
      final platform = platforms[area * PLATFORMS_PER_AREA + local];
      final event = WEATHER_EVENTS[area];
      weather.add(
        Weather(
          "weather-$area-$eventIndex",
          area,
          event.animation,
          event.sheet,
          event.harmful,
          event.force ?? "",
          event.force == "alternate" && eventIndex % 2 != 0 ? -1 : 1,
          62 + seeded(area * 30 + eventIndex + 900) * (WORLD_WIDTH - 124),
          platform.y + 70,
          eventIndex * 1.5 + area * 0.37,
          eventIndex,
          0,
          -1,
          -1,
        ),
      );
    }
  }
  return weather;
}

int areaForY(List<Platform> platforms, double y) {
  int area = 0;
  for (int index = 1; index < AREAS.length; index += 1) {
    if (y >= platforms[index * PLATFORMS_PER_AREA].y) area = index;
  }
  return area;
}

int metersForY(List<Platform> platforms, double y) {
  final area = areaForY(platforms, y);
  final start = platforms[area * PLATFORMS_PER_AREA].y;
  final nextIndex = math.min(
    platforms.length - 1,
    (area + 1) * PLATFORMS_PER_AREA,
  );
  final end = platforms[nextIndex].y;
  final progress = ((y - start) / math.max(1, end - start)).clamp(0, 1);
  return (area * METERS_PER_AREA + progress * METERS_PER_AREA).round();
}

bool overlap(
  double ax,
  double ay,
  double aw,
  double ah,
  double bx,
  double by,
  double bw,
  double bh,
) {
  return ax + aw > bx && ax < bx + bw && ay + ah > by && ay < by + bh;
}

class World {
  final Map<String, double> balance;
  late final List<Platform> platforms;
  final WorldState state;

  World({
    required this.balance,
    required String skinId,
    int best = 0,
    int? startCheckpointId,
    int startCarrots = 0,
  }) : state = _buildState(
         makePlatforms(),
         balance,
         skinId,
         best,
         startCheckpointId,
         startCarrots,
       ) {
    platforms = state.platforms;
  }

  static WorldState _buildState(
    List<Platform> platforms,
    Map<String, double> balance,
    String skinId,
    int best,
    int? startCheckpointId,
    int startCarrots,
  ) {
    final start = platforms[0];
    final skin = skinById(skinId);
    final state = WorldState(
      "ready",
      0,
      0,
      620,
      0,
      0,
      0,
      0,
      best,
      0,
      0,
      "Tahan untuk lompat lebih tinggi",
      4,
      0,
      0,
      0,
      ComboFx(0, 0, 0),
      SkillFx(0, 0, 0, "", 0),
      platforms,
      makePickups(platforms),
      makeEnemies(platforms),
      makeGuardians(platforms),
      makeWeather(platforms),
      AREAS.asMap().entries.map((e) {
        final platform = platforms[e.key * PLATFORMS_PER_AREA + 25];
        return Landmark(
          LANDMARKS[e.key],
          e.key >= 10 ? 1 : 0,
          e.key,
          e.key % 2 == 0 ? -18 : WORLD_WIDTH - 100,
          platform.y + 42,
          118,
        );
      }).toList(),
      Storm(90, -1, false),
      [],
      Player(
        start.x + start.width / 2,
        start.y,
        start.y,
        0,
        0,
        34,
        53,
        1,
        true,
        balance["coyoteTime"]!,
        0,
        0,
        0,
        skin,
        start,
        skin.id == "knight" ? 1 : 0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        false,
        false,
        start,
        0,
      ),
    );

    if (startCheckpointId != null) {
      final cp = platforms.firstWhere(
        (p) => p.id == startCheckpointId,
        orElse: () => platforms[0],
      );
      final player = state.player;
      player.x = cp.x + cp.width / 2;
      player.y = cp.y + 8;
      player.previousY = player.y;
      player.vx = 0;
      player.vy = 0;
      player.grounded = true;
      player.lastPlatform = cp;
      player.checkpointPlatform = cp;
      player.checkpointRescues = 1;
      player.revived = false;
      state.areaIndex = cp.area;
      state.previousArea = cp.area;
      state.stageIndex = cp.stage;
      state.height = metersForY(platforms, cp.y);
      state.cameraY = math.max(0, cp.y - state.viewHeight * 0.5);
      state.phase = "playing";
      state.message = "Lanjut dari pos terakhir";
      state.messageTime = 2.2;
      state.carrots = startCarrots;
      state.intensity =
          ((state.height / (AREAS.length * METERS_PER_AREA) * 0.78) +
                  cp.stage * 0.055)
              .clamp(0, 1);
    }
    return state;
  }

  void announce(String text, [double duration = 1.6]) {
    state.message = text;
    state.messageTime = duration;
  }

  void burst(double x, double y, String color, [int count = 8]) {
    final amount = (count * balance["effectsIntensity"]!).round();
    for (int i = 0; i < amount; i += 1) {
      final angle =
          (math.pi * 2 * i) / math.max(1, amount) +
          seeded(state.time + i) * 0.4;
      state.particles.add(
        Particle(
          x,
          y,
          math.cos(angle) * (30 + seeded(i) * 70),
          math.sin(angle) * 55 + 35,
          0.55,
          color,
        ),
      );
    }
  }

  void activateSkill(
    String text,
    List<String> events, [
    double x = 0,
    double y = 0,
  ]) {
    x = x == 0 ? state.player.x : x;
    y = y == 0 ? state.player.y + 24 : y;
    final skin = state.player.skin;
    if (skin.effect != null) {
      state.skillFx = SkillFx(0.78, x, y, skin.effect!, skin.effectSheet!);
    }
    announce(text, 1.4);
    events.add("skill");
  }

  String jump([double multiplier = 1, double horizontal = 0]) {
    final player = state.player;
    if (player.skin.id == "moon" && state.areaIndex >= 8) multiplier *= 1.18;
    // Semua kelinci mendapat lompatan dasar yang lebih bertenaga.
    player.vy = balance["jumpVelocity"]! * multiplier * 1.5;
    if (horizontal != 0) player.vx = horizontal;
    player.grounded = false;
    player.coyote = 0;
    player.jumpHold = 0;
    player.airTime = 0;
    burst(player.x, player.y + 2, "#d7f49d", 7);
    return "jump";
  }

  void takeHit(List<String> events) {
    final player = state.player;
    if (player.invulnerable > 0) return;
    if (player.shield > 0) {
      player.shield -= 1;
      player.invulnerable = 1.1;
      announce("Perisai bunga pecah!");
      burst(player.x, player.y + 25, "#90e6ff", 18);
    } else {
      player.invulnerable = 1.2;
      player.vy = 250;
      player.vx *= -1.1;
      state.shake = 0.28;
      announce("Kena! Kembali ke checkpoint", 1.8);
      events.add("hit");
      // A hit spends the checkpoint rescue immediately instead of waiting for
      // the player to fall, making hazards costly while keeping the run alive.
      // A checkpoint is a permanent respawn point for enemy hits. Falling
      // still consumes the limited rescue chance in fail().
      _rescueAtCheckpoint(events, consumeRescue: false);
    }
  }

  void _rescueAtCheckpoint(List<String> events, {bool consumeRescue = true}) {
    final player = state.player;
    if (consumeRescue) player.checkpointRescues -= 1;
    player.x =
        player.checkpointPlatform.x + player.checkpointPlatform.width / 2;
    player.y = player.checkpointPlatform.y + 8;
    player.previousY = player.y;
    player.vx = 0;
    player.vy = 250;
    player.grounded = false;
    player.airTime = 0;
    state.cameraY = math.max(0, player.y - state.viewHeight * 0.35);
    player.invulnerable = 1.4;
    announce("Checkpoint menyelamatkanmu", 2);
    burst(player.x, player.y, "#ffe181", 20);
    events.add("revive");
  }

  void fail(List<String> events) {
    final player = state.player;
    if (player.skin.id == "pajama" && !player.revived) {
      player.revived = true;
      player.x = player.lastPlatform.x + player.lastPlatform.width / 2;
      player.y = player.lastPlatform.y + 8;
      player.vx = 0;
      player.vy = 270;
      state.cameraY = math.max(0, player.y - state.viewHeight * 0.35);
      announce("Dream Catcher! Bangkit lagi", 2.2);
      burst(player.x, player.y, "#d6b4ff", 24);
      events.add("revive");
      return;
    }
    if (player.checkpointRescues > 0) {
      _rescueAtCheckpoint(events);
      return;
    }
    state.phase = "gameover";
    state.best = math.max(state.best, state.height);
    events.add("gameover");
  }

  void collectPickup(Pickup pickup, List<String> events) {
    final player = state.player;
    pickup.collected = true;
    if (pickup.type == "carrot") {
      final value = player.skin.id == "farmer" ? 2 : 1;
      state.carrots += value;
      state.combo = math.min(12, state.combo + 1);
      player.skinCounter += 1;
      if (player.skin.id == "alchemist" && player.skinCounter % 8 == 0) {
        player.shield += 1;
        activateSkill("Ramuan bunga: +1 perisai", events, pickup.x, pickup.y);
      }
      if (player.skin.id == "pirate" && player.skinCounter % 5 == 0) {
        state.carrots += 2;
        activateSkill("Harta kompas: +2 wortel", events, pickup.x, pickup.y);
      }
      if (player.skin.id == "rainbow" && player.skinCounter % 3 == 0) {
        for (final enemy in state.enemies) {
          if (enemy.active && (enemy.y - pickup.y).abs() < 230)
            enemy.active = false;
        }
        for (final guardian in state.guardians) {
          if (guardian.active &&
              !guardian.reward &&
              (guardian.y - pickup.y).abs() < 180) {
            guardian.hitCooldown = 3;
          }
        }
        activateSkill("PRISM BURST!", events, pickup.x, pickup.y);
      }
      if (state.combo % 5 == 0) {
        state.comboFx = ComboFx(0.8, pickup.x, pickup.y);
        events.add("combo");
      }
      announce(value == 2 ? "+2 panen emas" : "+1 wortel", 0.7);
    } else if (pickup.type == "flower_shield") {
      player.shield = 1;
      announce("Perisai bunga siap", 1.3);
    } else if (pickup.type == "flying_carrot") {
      player.magnet = player.skin.id == "chef" ? 8 : 6;
      announce("Magnet wortel!", 1.3);
    } else if (pickup.type == "balloon") {
      player.balloon = player.skin.id == "chef" ? 7 : 5;
      announce("Balon naik!", 1.3);
    }
    burst(pickup.x, pickup.y, "#ffc64f", 13);
    events.add("pickup");
  }

  void landOn(Platform platform, List<String> events, bool jumpHeld) {
    final player = state.player;
    player.y = platform.y;
    player.vy = 0;
    player.grounded = true;
    player.airTime = 0;
    player.coyote = balance["coyoteTime"]!;
    player.lastPlatform = platform;
    state.combo = math.min(12, state.combo + 1);
    if (platform.kind == "falling" && platform.fallTimer < 0) {
      platform.fallTimer = [9, 19].contains(platform.area)
          ? 0.42
          : math.max(0.48, 1.2 - state.intensity * 0.65);
    }
    if (platform.kind == "falling") {
      platform.effectTime = 0.9;
      platform.effectKind = "leaf_crumble";
    }

    final centered =
        (player.x - (platform.x + platform.width / 2)).abs() <
        platform.width * 0.2;
    if (player.skin.id == "dj" && centered) {
      int cleared = 0;
      for (final enemy in state.enemies) {
        if (enemy.active && (enemy.y - platform.y).abs() < 190) {
          enemy.active = false;
          cleared += 1;
          burst(enemy.x, enemy.y, "#ee7ee7", 12);
        }
      }
      if (cleared > 0) announce("Beat Drop! $cleared musuh pergi", 1.4);
    }
    if (player.skin.id == "ranger") {
      player.rangerSteps += 1;
      if (player.rangerSteps >= 5) {
        player.rangerSteps = 0;
        player.rangerBoost = true;
        announce("Sinyal Morse: lompat 1,5×", 1.6);
      }
    }
    burst(player.x, platform.y + 2, AREAS[platform.area].tint, 9);
    events.add("land");

    if (platform.checkpoint && !platform.checkpointClaimed) {
      platform.checkpointClaimed = true;
      player.shield = math.max(
        player.shield,
        player.skin.id == "miner" ? 2 : 1,
      );
      player.checkpointPlatform = platform;
      player.checkpointRescues = 1;
      state.carrots += 2;
      final checkpointPart = (platform.id % PLATFORMS_PER_AREA) ~/ 10 + 1;
      announce(
        "Pos ${platform.area + 1}.${checkpointPart} · perisai pulih",
        2.1,
      );
      events.add("checkpoint");
      if (["miner", "monk", "timekeeper"].contains(player.skin.id)) {
        activateSkill(
          player.skin.id == "miner"
              ? "Benteng kristal: 2 perisai"
              : player.skin.id == "monk"
              ? "Mandala awan aktif"
              : "Waktu melambat",
          events,
        );
      }
    }

    if (platform.kind == "mushroom" && jumpHeld) {
      player.vy = balance["jumpVelocity"]! * 1.45;
      player.grounded = false;
      announce("SUPER JUMP!", 1.1);
      platform.effectTime = 0.7;
      platform.effectKind = "mushroom_bounce";
      events.add("super");
    }

    if (platform.kind == "portal") {
      player.x = WORLD_WIDTH - player.x;
      player.vy = 120;
      player.grounded = false;
      announce("Portal memindahkanmu!", 1.2);
    }
  }

  void _movePlayer(double dt, InputLike input, Player player, int area) {
    final direction = (input.right ? 1 : 0) - (input.left ? 1 : 0);
    if (direction != 0) player.facing = direction.toDouble();
    final acceleration = player.grounded ? 1150 : 760;
    final target =
        direction * balance["moveSpeed"]! * (player.skin.id == "lava" ? 1.16 : 1);
    final grip = [2, 5, 12].contains(area) ? 3.2 : 8.5;
    player.vx += math.max(
      -acceleration * dt,
      math.min(acceleration * dt, target - player.vx),
    );
    if (direction == 0 && player.grounded)
      player.vx *= math.max(0, 1 - grip * dt);
  }

  List<String> update(double dt, InputLike input) {
    final events = <String>[];
    final jumpHeld = input.jump;
    final player = state.player;
    state.time += dt;
    state.messageTime = math.max(0, state.messageTime - dt);
    state.shake = math.max(0, state.shake - dt);
    state.flash = math.max(0, state.flash - dt);
    state.comboFx.time = math.max(0, state.comboFx.time - dt);
    state.skillFx.time = math.max(0, state.skillFx.time - dt);
    player.invulnerable = math.max(0, player.invulnerable - dt);
    player.wallCooldown = math.max(0, player.wallCooldown - dt);
    player.cyberCooldown = math.max(0, player.cyberCooldown - dt);
    player.dragonCooldown = math.max(0, player.dragonCooldown - dt);
    player.magnet = math.max(0, player.magnet - dt);
    player.balloon = math.max(0, player.balloon - dt);

    for (final particle in state.particles) {
      particle.life -= dt;
      particle.x += particle.vx * dt;
      particle.y += particle.vy * dt;
      particle.vy -= 300 * dt;
    }
    state.particles = state.particles.where((p) => p.life > 0).toList();

    final skinTempo = player.skin.id == "timekeeper" ? 0.78 : 1;
    for (final platform in platforms) {
      if (platform.moving) {
        platform.x =
            platform.baseX +
            math.sin(
                  state.time *
                          skinTempo *
                          platform.moveSpeed *
                          (0.82 + state.intensity * 0.9) +
                      platform.phase,
                ) *
                platform.moveRange *
                (0.86 + state.intensity * 0.28);
      }
      if (platform.fallTimer >= 0) {
        platform.fallTimer -= dt;
        if (platform.fallTimer <= 0) platform.fallen = true;
      }
      if (platform.fallen) platform.y -= 190 * dt;
      platform.effectTime = math.max(0, platform.effectTime - dt);
    }

    for (final enemy in state.enemies) {
      if (!enemy.active) continue;
      if (enemy.type == "icicle") {
        if ((player.x - enemy.x).abs() < 40 && player.y < enemy.y)
          enemy.y -= 250 * dt;
      } else {
        enemy.x +=
            enemy.direction *
            enemy.speed *
            (0.82 + state.intensity * 0.75) *
            skinTempo *
            dt;
        if (enemy.x < -30) enemy.x = WORLD_WIDTH + 30;
        if (enemy.x > WORLD_WIDTH + 30) enemy.x = -30;
        enemy.y = enemy.baseY + math.sin(state.time * 2 + enemy.phase) * 14;
      }
    }

    for (final guardian in state.guardians) {
      if (!guardian.active) continue;
      guardian.hitCooldown = math.max(0, guardian.hitCooldown - dt);
      final tempo = (0.8 + state.intensity * 0.8) * skinTempo;
      if (guardian.area == 2) {
        guardian.x += guardian.direction * guardian.speed * tempo * dt;
        guardian.y =
            guardian.baseY +
            (math.sin(state.time * 1.8 + guardian.phase).abs()) * 38;
      } else if (guardian.area == 5) {
        guardian.x += guardian.direction * guardian.speed * 1.45 * tempo * dt;
        guardian.y = guardian.baseY;
      } else if (guardian.area == 7) {
        guardian.x += guardian.direction * guardian.speed * 0.55 * tempo * dt;
        guardian.y =
            guardian.baseY + math.sin(state.time * 1.2 + guardian.phase) * 9;
      } else {
        guardian.x += guardian.direction * guardian.speed * tempo * dt;
        guardian.y =
            guardian.baseY + math.sin(state.time * 1.7 + guardian.phase) * 28;
      }
      if (guardian.x < 36) guardian.direction = 1;
      if (guardian.x > WORLD_WIDTH - 36) guardian.direction = -1;
    }

    for (final weather in state.weather) {
      final period = 6.2 - state.intensity * 2.5 - weather.eventIndex * 0.22;
      final weatherTime = state.time * skinTempo + weather.phase;
      weather.frame = ((weatherTime % period) / period * 8).floor();
      weather.cycle = (weatherTime / period).floor();
    }

    if (state.phase == "ready") {
      _movePlayer(dt, input, player, state.areaIndex);
      if (input.consumeJumpPressed()) {
        state.phase = "playing";
        events.add(jump());
      }
      return events;
    }
    if (state.phase != "playing") return events;

    final area = state.areaIndex;
    final direction = (input.right ? 1 : 0) - (input.left ? 1 : 0);
    _movePlayer(dt, input, player, area);

    final touchingLeft = player.x <= player.w / 2 + 1;
    final touchingRight = player.x >= WORLD_WIDTH - player.w / 2 - 1;
    final touchingWall = touchingLeft || touchingRight;
    final pressed = input.consumeJumpPressed();
    if (pressed) {
      if (player.grounded || player.coyote > 0) {
        // The global 1.5x jump applies to Ranger too; do not stack its old
        // skill multiplier on top of the new shared jump strength.
        const boost = 1.0;
        player.rangerBoost = false;
        events.add(jump(boost));
      } else if (touchingWall && player.wallCooldown <= 0) {
        player.wallCooldown = player.skin.id == "ninja" ? 0.05 : 0.24;
        events.add(
          jump(
            0.98,
            touchingLeft ? balance["moveSpeed"]! : -balance["moveSpeed"]!,
          ),
        );
        announce("WALL JUMP", 0.65);
      } else if (player.skin.id == "cyber" && player.cyberCooldown <= 0) {
        player.cyberCooldown = 3;
        events.add(jump(0.9));
        announce("DOUBLE JUMP", 0.8);
      } else if (player.skin.id == "dragon" && player.dragonCooldown <= 0) {
        player.dragonCooldown = 3.5;
        events.add(jump(0.78, player.facing * balance["moveSpeed"]! * 1.25));
        activateSkill("WING DASH!", events);
      }
    }

    if (input.consumeJumpReleased() && player.vy > 0) player.vy *= 0.55;
    if (input.jump && player.vy > 0 && player.jumpHold < 0.19) {
      player.vy += 760 * dt;
      player.jumpHold += dt;
    }

    double gravityScale =
        (player.skin.id == "astro" || [8, 10, 15].contains(area)) ? 0.8 : 1;
    if (player.skin.id == "moon" && area >= 8) gravityScale *= 0.72;
    if (player.skin.id == "wizard" && input.jump && player.vy < 0)
      gravityScale *= 0.28;
    if (player.balloon > 0) {
      gravityScale = 0.12;
      player.vy = math.max(player.vy, 82);
    }
    if (area == 3) player.vx += math.sin(state.time * 1.6) * 210 * dt;
    if (area == 17) player.vx += math.sin(state.time * 2.2) * 125 * dt;
    for (final weather in state.weather) {
      if (weather.area != area || weather.frame < 3 || weather.frame > 5)
        continue;
      if ((player.y - weather.y).abs() > 70 ||
          (player.x - weather.x).abs() > 85)
        continue;
      if (weather.force == "up") {
        player.vy += 210 * dt;
      } else if (weather.force.isNotEmpty) {
        player.vx +=
            (weather.force == "left" ? -1 : weather.direction) *
            180 *
            dt *
            (player.skin.id == "monk" ? 0.35 : 1);
      }
    }
    if (player.skin.id == "ninja" &&
        touchingWall &&
        direction != 0 &&
        player.vy < -40)
      player.vy = -40;

    player.previousY = player.y;
    if (!player.grounded) player.airTime += dt;
    player.vy -= GRAVITY * gravityScale * dt;
    player.x += player.vx * dt;
    player.y += player.vy * dt;
    player.x = math.max(
      player.w / 2,
      math.min(WORLD_WIDTH - player.w / 2, player.x),
    );

    final wasGrounded = player.grounded;
    player.grounded = false;
    if (player.vy <= 0 && player.balloon <= 0) {
      for (final platform in platforms) {
        if (platform.fallen && platform.y < state.cameraY - 100) continue;
        // Require an actual crossing so a grounded player does not land on the
        // same platform again on every subsequent frame.
        final crossed = player.previousY >= platform.y && player.y <= platform.y;
        final horizontal =
            player.x + player.w * 0.34 > platform.x &&
            player.x - player.w * 0.34 < platform.x + platform.width;
        if (crossed && horizontal) {
          if (platform.thorn && player.x > platform.x + platform.width * 0.62) {
            if (player.skin.id == "lava") {
              activateSkill("Sepatu lava membakar duri", events);
            } else {
              takeHit(events);
            }
          }
          landOn(platform, events, jumpHeld);
          break;
        }
      }
    }
    if (!player.grounded) {
      player.coyote = wasGrounded
          ? balance["coyoteTime"]!
          : math.max(0, player.coyote - dt);
    }

    for (final pickup in state.pickups) {
      if (pickup.collected) continue;
      final distance = math.sqrt(
        math.pow(player.x - pickup.x, 2) +
            math.pow(player.y + 24 - pickup.y, 2),
      );
      if (player.magnet > 0 && pickup.type == "carrot" && distance < 125) {
        pickup.x += (player.x - pickup.x) * math.min(1, dt * 7);
        pickup.y += (player.y + 24 - pickup.y) * math.min(1, dt * 7);
      }
      if (distance < (player.skin.id == "pirate" ? 46 : 28))
        collectPickup(pickup, events);
    }

    final playerBoxX = player.x - 14;
    final playerBoxY = player.y + 5;
    const double playerBoxW = 28;
    const double playerBoxH = 44;
    for (final enemy in state.enemies) {
      if (!enemy.active) continue;
      if (player.skin.id == "beekeeper" && enemy.type == "bee_swarm") continue;
      final double size = enemy.type == "bee_swarm" ? 36 : 42;
      if (overlap(
        playerBoxX,
        playerBoxY,
        playerBoxW,
        playerBoxH,
        enemy.x - size / 2,
        enemy.y - size / 2,
        size,
        size,
      )) {
        takeHit(events);
      }
    }

    for (final guardian in state.guardians) {
      if (!guardian.active || guardian.hitCooldown > 0) continue;
      if (!overlap(
        playerBoxX,
        playerBoxY,
        playerBoxW,
        playerBoxH,
        guardian.x - 30,
        guardian.y - 28,
        60.0,
        56.0,
      ))
        continue;
      if (player.skin.id == "beekeeper" && guardian.area == 4) {
        guardian.hitCooldown = 2;
        activateSkill("Lebah mengenali penjaganya", events);
        continue;
      }
      if (guardian.reward) {
        guardian.active = false;
        final reward = player.skin.id == "farmer" ? 6 : 3;
        state.carrots += reward;
        announce("Tarian kupu-kupu · +$reward wortel", 1.5);
        burst(guardian.x, guardian.y, "#ffe77b", 22);
        events.add("pickup");
      } else {
        guardian.hitCooldown = 1.3;
        guardian.direction *= -1;
        takeHit(events);
      }
    }

    for (final weather in state.weather) {
      if (!weather.harmful ||
          weather.frame < 3 ||
          weather.frame > 5 ||
          weather.hitCycle == weather.cycle)
        continue;
      if (!overlap(
        playerBoxX,
        playerBoxY,
        playerBoxW,
        playerBoxH,
        weather.x - 48,
        weather.y - 44,
        96.0,
        88.0,
      ))
        continue;
      if (player.skin.id == "beekeeper" && weather.area == 4) {
        weather.hitCycle = weather.cycle;
        activateSkill("Jubah madu menahan serbuk sari", events);
        continue;
      }
      weather.hitCycle = weather.cycle;
      takeHit(events);
    }

    if (state.areaIndex == 6) {
      final cycle = (state.time / 4).floor();
      final phase = state.time % 4;
      if (cycle != state.storm.cycle) {
        state.storm.cycle = cycle;
        state.storm.x = 55 + seeded(cycle + 600) * (WORLD_WIDTH - 110);
        state.storm.struck = false;
      }
      if (phase > 2.35 &&
          phase < 2.62 &&
          !state.storm.struck &&
          (player.x - state.storm.x).abs() < 34) {
        state.storm.struck = true;
        takeHit(events);
      }
    }

    state.height = math.max(state.height, metersForY(platforms, player.y));
    final nextArea = math.min(
      AREAS.length - 1,
      (state.height / METERS_PER_AREA).floor(),
    );
    final nextStage = math.min(
      4,
      (((state.height % METERS_PER_AREA) / METERS_PER_AREA) * 5).floor(),
    );
    if (nextArea != state.areaIndex) {
      state.previousArea = state.areaIndex;
      state.areaIndex = nextArea;
      state.stageIndex = 0;
      announce("${AREAS[nextArea].name} · ${SUB_AREAS[nextArea][0]}", 2.2);
      events.add("area");
      state.flash = nextArea == 6 ? 0.35 : 0;
      if (player.skin.id == "moon" && nextArea >= 8) {
        activateSkill("Cahaya bulan memperkuat lompatan", events);
      }
    } else if (nextStage != state.stageIndex) {
      state.stageIndex = nextStage;
      announce(
        "${SUB_AREAS[state.areaIndex][nextStage]} · bagian ${nextStage + 1}/5",
        1.8,
      );
      events.add("area");
    }
    state.intensity =
        (state.height / (AREAS.length * METERS_PER_AREA) * 0.78 +
                state.stageIndex * 0.055)
            .clamp(0, 1);
    final targetCamera = math.max(0, player.y - state.viewHeight * 0.5);
    if (targetCamera > state.cameraY) {
      state.cameraY += (targetCamera - state.cameraY) * math.min(1, dt * 4.5);
    }
    if (player.y < state.cameraY - 45 + state.intensity * 50) fail(events);

    final finalPlatform = platforms[platforms.length - 1];
    if (player.y >= finalPlatform.y - 12) {
      state.height = AREAS.length * METERS_PER_AREA;
      state.best = math.max(state.best, state.height);
      state.phase = "won";
      announce("PANDAI BINTANG TERCAPAI!", 99);
      events.add("won");
    }
    return events;
  }
}
