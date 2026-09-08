import 'dart:ui' as ui;
import 'dart:math' as math;
import 'config.dart';
import 'frames.dart';
import 'world.dart';
import 'art.dart';

ui.Color fromHex(String hex) =>
    ui.Color(int.parse('0xff${hex.replaceFirst('#', '')}'));

class Renderer {
  final Art art;

  Renderer(this.art);

  Frame? _anim(Sheet sheet, String name, int index) {
    final list = sheet.animation(name);
    if (list.isEmpty) return null;
    return list[index.clamp(0, list.length - 1)];
  }

  double _screenY(WorldState state, double worldY, double logicalHeight) =>
      logicalHeight - (worldY - state.cameraY);

  ui.Paint _paint([double alpha = 1]) {
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    if (alpha != 1) {
      paint.color = const ui.Color(0xffffffff)
          .withAlpha((alpha * 255).round().clamp(0, 255));
    }
    return paint;
  }

  void _drawCover(ui.Canvas canvas, ui.Image image, double width, double height,
      [double offset = 0, double alpha = 1]) {
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    final scale = math.max(width / iw, height / ih);
    final dw = iw * scale;
    final dh = ih * scale;
    final drift = (dh - height) * offset;
    canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, iw, ih),
        ui.Rect.fromLTWH((width - dw) / 2, -drift, dw, dh),
        _paint(alpha));
  }

  void _drawPlatform(ui.Canvas canvas, WorldState state, Platform platform,
      double logicalHeight) {
    final y = _screenY(state, platform.y, logicalHeight);
    if (y < -90 || y > logicalHeight + 120) return;
    final alpha = platform.fallTimer >= 0 && !platform.fallen
        ? 0.65 + math.sin(state.time * 18) * 0.25
        : 1.0;
    if (platform.kind == "mushroom") {
      final fr = art.mushroom.frame(art.mushroom.firstKey());
      if (fr != null) {
        final crop = fr.crop;
        final scale = (platform.width * 1.05) / crop.width;
        final surface = fr.surfaceY ?? fr.anchor.dy;
        canvas.drawImageRect(
            art.mushroom.image,
            crop,
            ui.Rect.fromLTWH(
                platform.x - platform.width * 0.025,
                y - (surface - crop.top) * scale,
                crop.width * scale,
                crop.height * scale),
            _paint(alpha));
      }
    } else {
      final isNewRealm = platform.area >= 10;
      final useVariant = platform.visualVariant > 0;
      late final Sheet sheet;
      late final String frameName;
      if (isNewRealm) {
        sheet = art.realmPlatforms[NEW_PLATFORM_SHEETS[platform.area - 10]];
        frameName = NEW_PLATFORM_VARIANTS[platform.area - 10][platform.visualVariant];
      } else if (useVariant) {
        sheet = platform.visualVariant > 2 ? art.platformVariants2 : art.platformVariants;
        frameName = PLATFORM_VARIANTS[platform.area][platform.visualVariant - 1];
      } else {
        sheet = art.platforms;
        frameName = AREAS[platform.area].platform;
      }
      final fr = sheet.frame(frameName);
      if (fr != null) {
        final crop = fr.crop;
        final scale = platform.width / crop.width;
        final surface = fr.surfaceY ?? fr.anchor.dy;
        canvas.drawImageRect(
            sheet.image,
            crop,
            ui.Rect.fromLTWH(platform.x,
                y - (surface - crop.top) * scale, crop.width * scale, crop.height * scale),
            _paint(alpha));
      }
    }
    if (platform.thorn) art.objects.drawCell(canvas, "thorn_bush",
        platform.x + platform.width * 0.62, y - 25, platform.width * 0.38, 32);
    if (platform.kind == "portal") {
      art.objects.drawCell(canvas, "portal",
          platform.x + platform.width * 0.25, y - 48, platform.width * 0.5, 48, alpha: 0.86);
      art.effects.drawFrame(
          canvas,
          art.effects.animation("portal_pulse")[(state.time * 8).floor() % 6],
          platform.x + platform.width * 0.18, y - 57, platform.width * 0.64, 58,
          alpha: 0.76);
    }
    if (platform.checkpoint) {
      final ckSheet = platform.area >= 10 ? art.realmLandmarks : art.landmarks;
      ckSheet.drawCell(canvas, CHECKPOINTS[platform.area],
          platform.x + platform.width * 0.55, y - 58, 48, 60);
    }
    if (platform.effectTime > 0) {
      final progress = 1 - platform.effectTime / (platform.effectKind == "mushroom_bounce" ? 0.7 : 0.9);
      art.effects.drawFrame(
          canvas,
          art.effects.animation(platform.effectKind)[(progress * 6).floor()],
          platform.x + platform.width / 2 - 44, y - 42, 88, 72);
    }
  }

  void _drawPlayer(ui.Canvas canvas, WorldState state, double logicalHeight) {
    final player = state.player;
    final sheet = art.rabbitSkins[player.skin.id]!;
    final animName = player.skin.animation;
    final frames = List<Frame?>.generate(12,
        (i) => sheet.frame('$animName\_${i + 1}'));
    int index = 0;
    if (!player.grounded && player.airTime < 0.04) index = 1;
    else if (!player.grounded && player.airTime < 0.08) index = 2;
    else if (!player.grounded && player.airTime < 0.13) index = 3;
    else if (!player.grounded && player.vy > 250) index = 4;
    else if (!player.grounded && player.vy > 140) index = 5;
    else if (!player.grounded && player.vy > 45) index = 6;
    else if (!player.grounded && player.vy > -45) index = 7;
    else if (!player.grounded && player.vy > -135) index = 8;
    else if (!player.grounded && player.vy > -230) index = 9;
    else if (!player.grounded && player.vy > -340) index = 10;
    else if (!player.grounded) index = 11;
    final frame = frames[index];
    if (frame == null) return;
    final crop = frame.crop;
    double largestHeight = 0;
    for (final f in frames) {
      if (f != null && f.crop.height > largestHeight) largestHeight = f.crop.height;
    }
    final scale = 64 / largestHeight;
    final x = player.x;
    final y = _screenY(state, player.y, logicalHeight);
    final playerAlpha = (player.invulnerable > 0 && (state.time * 14).floor() % 2 == 0) ? 0.42 : 1.0;
    sheet.drawAnchored(canvas, '$animName\_${index + 1}', x, y, scale,
        alpha: playerAlpha, flipX: player.facing < 0);

    if (player.shield > 0) {
      final glow = ui.Gradient.radial(
        ui.Offset(x, y - 28), 40,
        [const ui.Color(0x147ee1ff), const ui.Color(0x33b6e4ff), const ui.Color(0x00b6e4ff)],
        [0.0, 0.6, 1.0]);
      canvas.drawCircle(ui.Offset(x, y - 28), 40, ui.Paint()..shader = glow);
      canvas.drawCircle(ui.Offset(x, y - 28), 40,
          ui.Paint()..color = const ui.Color(0xa6b6faff)..style = ui.PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  void _drawGuardian(ui.Canvas canvas, WorldState state, Guardian guardian,
      double logicalHeight) {
    final sheet = art.creatures[guardian.sheet];
    final cycle = sheet.animation(guardian.animation);
    if (cycle.isEmpty) return;
    final index = (state.time * 7 + guardian.phase * 2).floor() % cycle.length;
    final frame = cycle[index];
    final crop = frame.crop;
    final boxWidth = guardian.area == 2 || guardian.area == 7 ? 88 : 76;
    final boxHeight = guardian.area == 2 ? 66 : 76;
    final scale = math.min(boxWidth / crop.width, boxHeight / crop.height);
    final y = _screenY(state, guardian.y, logicalHeight);
    if (state.intensity > 0.55 && guardian.area >= 4) {
      art.crescendo.drawFrame(
          canvas,
          art.crescendo.animation("guardian_rage_aura")[(state.time * (7 + state.intensity * 5)).floor() % 8],
          guardian.x - 51, y - 51, 102, 102,
          alpha: 0.55 + state.intensity * 0.35);
    }
    canvas.save();
    canvas.translate(guardian.x, y);
    if (guardian.direction < 0) canvas.scale(-1, 1);
    canvas.drawImageRect(
        sheet.image,
        crop,
        ui.Rect.fromLTWH(-crop.width * scale / 2, -crop.height * scale / 2,
            crop.width * scale, crop.height * scale),
        ui.Paint()..filterQuality = ui.FilterQuality.medium);
    canvas.restore();
  }

  void _drawFox(ui.Canvas canvas, WorldState state, double logicalHeight) {
    if (state.intensity < 0.28) return;
    final frames = art.fox.animation("fox_chase");
    if (frames.isEmpty) return;
    final frame = frames[(state.time * (9 + state.intensity * 7)).floor() % frames.length];
    final crop = frame.crop;
    final scale = 58 / crop.height;
    final wave = math.sin(state.time * (1.1 + state.intensity));
    final x = 50 + (wave + 1) * 0.5 * (WORLD_WIDTH - 100);
    final y = logicalHeight - 5;
    final foxAlpha = math.min(1.0, (state.intensity - 0.22) * 2.2);
    canvas.save();
    canvas.translate(x, y);
    if (math.cos(state.time * (1.1 + state.intensity)) < 0) canvas.scale(-1, 1);
    art.fox.drawAnchored(canvas, "fox_chase_${(state.time * (9 + state.intensity * 7)).floor() % frames.length + 1}", 0, 0, scale, alpha: foxAlpha);
    canvas.restore();
  }

  void _drawWeather(ui.Canvas canvas, WorldState state, Weather weather,
      double logicalHeight) {
    final sheet = art.weather[weather.sheet];
    final cycle = sheet.animation(weather.animation);
    if (cycle.isEmpty) return;
    final frame = cycle[weather.frame];
    final crop = frame.crop;
    final width = [7, 9].contains(weather.area) ? 150 : 122;
    final height = weather.area == 9 ? 118 : 96;
    final scale = math.min(width / crop.width, height / crop.height);
    final y = _screenY(state, weather.y, logicalHeight);
    canvas.save();
    canvas.translate(weather.x, y);
    if (weather.direction < 0) canvas.scale(-1, 1);
    canvas.drawImageRect(
        sheet.image,
        crop,
        ui.Rect.fromLTWH(-crop.width * scale / 2, -crop.height * scale / 2,
            crop.width * scale, crop.height * scale),
        _paint(weather.frame < 3 ? 0.58 : 0.9));
    canvas.restore();
  }

  void render(ui.Canvas canvas, ui.Size size, WorldState state) {
    final cssWidth = size.width;
    final cssHeight = size.height;
    final logicalHeight = WORLD_WIDTH * (cssHeight / cssWidth);
    state.viewHeight = logicalHeight;

    canvas.save();
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, cssWidth, cssHeight),
        ui.Paint()..color = const ui.Color(0xff101820));

    final areaProgress = (state.height % METERS_PER_AREA) / METERS_PER_AREA;
    _drawCover(canvas, art.backgrounds[state.areaIndex], cssWidth, cssHeight, areaProgress);
    if (state.areaIndex < AREAS.length - 1 && areaProgress > 0.78) {
      _drawCover(canvas, art.backgrounds[state.areaIndex + 1], cssWidth, cssHeight, 0,
          (areaProgress - 0.78) / 0.22);
    }
    final wash = ui.Gradient.linear(ui.Offset(0, 0), ui.Offset(0, cssHeight),
        [const ui.Color(0x14141028), const ui.Color(0x380e1218)]);
    canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, cssWidth, cssHeight),
        ui.Paint()..shader = wash);

    final scale = cssWidth / WORLD_WIDTH;
    canvas.save();
    canvas.scale(scale, scale);
    if (state.shake > 0) {
      canvas.translate((math.Random().nextDouble() - 0.5) * 7,
          (math.Random().nextDouble() - 0.5) * 5);
    }

    if (state.best > 0 && state.best < AREAS.length * METERS_PER_AREA) {
      final bestArea = math.min(AREAS.length - 1, (state.best / METERS_PER_AREA).floor());
      final bestStart = state.platforms[bestArea * PLATFORMS_PER_AREA].y;
      final bestEnd = state.platforms[math.min(state.platforms.length - 1,
          (bestArea + 1) * PLATFORMS_PER_AREA)].y;
      final bestY = bestStart +
          ((state.best % METERS_PER_AREA) / METERS_PER_AREA) * (bestEnd - bestStart);
      final y = _screenY(state, bestY, logicalHeight);
      if (y > 30 && y < logicalHeight - 20) {
        final dash = ui.Paint()
          ..color = const ui.Color(0xb8fff6b0)
          ..strokeWidth = 2;
        canvas.drawLine(ui.Offset(0, y), ui.Offset(WORLD_WIDTH, y), dash);
        canvas.drawRect(ui.Rect.fromLTWH(8, y - 22, 80, 20),
            ui.Paint()..color = const ui.Color(0xdc2d1c37));
        final tb = ui.ParagraphBuilder(ui.ParagraphStyle(
            textAlign: ui.TextAlign.left,
            fontSize: 12,
            fontFamily: 'Nunito',
            fontWeight: ui.FontWeight.bold))
          ..pushStyle(ui.TextStyle(color: ui.Color(0xfffff3bd)))
          ..addText('REKOR ${state.best}m');
        final p = tb.build()..layout(const ui.ParagraphConstraints(width: 80));
        canvas.drawParagraph(p, ui.Offset(14, y - 20));
      }
    }

    for (final landmark in state.landmarks) {
      final y = _screenY(state, landmark.y, logicalHeight);
      if (y < -150 || y > logicalHeight + 150) continue;
      final lkSheet = landmark.sheet == 1 ? art.realmLandmarks : art.landmarks;
      lkSheet.drawCell(canvas, landmark.name, landmark.x, y - 115, landmark.width, 140, alpha: 0.92);
    }

    for (final platform in state.platforms) _drawPlatform(canvas, state, platform, logicalHeight);
    final finalPlatform = state.platforms[state.platforms.length - 1];
    final finishY = _screenY(state, finalPlatform.y, logicalHeight);
    if (finishY > -140 && finishY < logicalHeight + 100) {
      art.landmarks.drawCell(canvas, "finish_beacon",
          finalPlatform.x + finalPlatform.width / 2 - 52, finishY - 114, 104, 116);
    }
    for (final pickup in state.pickups) {
      if (pickup.collected) continue;
      final y = _screenY(state, pickup.y + math.sin(state.time * 3 + pickup.bob) * 5, logicalHeight);
      if (y < -50 || y > logicalHeight + 40) continue;
      art.objects.drawCell(canvas, pickup.type, pickup.x - 16, y - 18, 32, 36);
    }
    for (final weather in state.weather) {
      final y = _screenY(state, weather.y, logicalHeight);
      if (y < -100 || y > logicalHeight + 100) continue;
      _drawWeather(canvas, state, weather, logicalHeight);
    }
    for (final guardian in state.guardians) {
      if (!guardian.active) continue;
      final y = _screenY(state, guardian.y, logicalHeight);
      if (y < -80 || y > logicalHeight + 80) continue;
      if (!guardian.reward) {
        canvas.drawLine(
            ui.Offset(20, y), ui.Offset(WORLD_WIDTH - 20, y),
            ui.Paint()
              ..color = const ui.Color(0x61ffebad)
              ..strokeWidth = 1.5);
      }
      _drawGuardian(canvas, state, guardian, logicalHeight);
    }
    for (final enemy in state.enemies) {
      if (!enemy.active) continue;
      final y = _screenY(state, enemy.y, logicalHeight);
      if (y < -60 || y > logicalHeight + 60) continue;
      art.objects.drawCell(canvas, enemy.type, enemy.x - 25, y - 24, 50, 48);
    }
    if (state.areaIndex == 6) {
      final phase = state.time % 4;
      if (phase > 1.25 && phase < 2.72) {
        final frameIndex = math.min(5, ((phase - 1.25) / 1.47 * 6).floor());
        final alpha = phase > 2.35 ? 1.0 : 0.55;
        for (double yy = 40; yy < logicalHeight; yy += 92) {
          art.effects.drawFrame(canvas, art.effects.animation("storm_warning")[frameIndex],
              state.storm.x - 34, yy - 42, 68, 84, alpha: alpha);
        }
      }
    }
    for (final particle in state.particles) {
      final y = _screenY(state, particle.y, logicalHeight);
      final pa = math.max(0, particle.life / 0.55).clamp(0, 1);
      canvas.drawCircle(
          ui.Offset(particle.x, y), 2.4,
          ui.Paint()..color = fromHex(particle.color).withAlpha((pa * 255).round().clamp(0, 255)));
    }
    if (state.comboFx.time > 0) {
      final progress = 1 - state.comboFx.time / 0.8;
      art.crescendo.drawFrame(
          canvas,
          art.crescendo.animation("carrot_combo_burst")[math.min(7, (progress * 8).floor())],
          state.comboFx.x - 55, _screenY(state, state.comboFx.y, logicalHeight) - 55, 110, 110);
    }
    if (state.skillFx.time > 0) {
      final progress = 1 - state.skillFx.time / 0.78;
      art.skillEffects[state.skillFx.sheet].drawFrame(
          canvas,
          art.skillEffects[state.skillFx.sheet].animation(state.skillFx.effect)[math.min(5, (progress * 6).floor())],
          state.skillFx.x - 59, _screenY(state, state.skillFx.y, logicalHeight) - 59, 118, 118,
          alpha: 0.96);
    }
    if (state.areaIndex == AREAS.length - 1 && state.stageIndex >= 4) {
      final starFrame = (state.time * 8).floor() % 8;
      art.crescendo.drawFrame(canvas, art.crescendo.animation("summit_star_explosion")[starFrame],
          18, 55, 120, 120, alpha: 0.85);
      art.crescendo.drawFrame(
          canvas,
          art.crescendo.animation("summit_star_explosion")[(starFrame + 4) % 8],
          WORLD_WIDTH - 138, logicalHeight * 0.35, 120, 120, alpha: 0.8);
    }
    _drawPlayer(canvas, state, logicalHeight);

    final dangerY = logicalHeight - 26;
    final dangerColor = state.areaIndex < 6
        ? ui.Color.fromRGBO(173, 92, 46, 0.35 + state.intensity * 0.55)
        : ui.Color.fromRGBO(92, 28, 112, 0.45 + state.intensity * 0.5);
    final danger = ui.Gradient.linear(
        ui.Offset(0, dangerY - 55), ui.Offset(0, logicalHeight),
        [const ui.Color(0x00622a30), dangerColor]);
    canvas.drawRect(ui.Rect.fromLTWH(0, dangerY - 55, WORLD_WIDTH, 82),
        ui.Paint()..shader = danger);
    _drawFox(canvas, state, logicalHeight);
    canvas.restore();

    if (state.flash > 0) {
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, cssWidth, cssHeight),
          ui.Paint()..color = ui.Color.fromRGBO(226, 242, 255, state.flash));
    }
    canvas.restore();
  }
}
