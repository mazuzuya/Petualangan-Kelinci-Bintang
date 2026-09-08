import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Frame {
  final ui.Rect crop;
  final ui.Offset anchor;
  final double? surfaceY;
  Frame(this.crop, this.anchor, [this.surfaceY]);
}

class Sheet {
  final ui.Image image;
  final Map<String, Frame> _frames;
  final Map<String, List<Frame>> _animations;

  Sheet(this.image, this._frames, this._animations);

  Frame? frame(String name) => _frames[name];

  String firstKey() => _frames.keys.first;

  ui.Rect cropOf(String name) => _frames[name]!.crop;
  ui.Offset anchorOf(String name) => _frames[name]!.anchor;
  double? surfaceYOf(String name) => _frames[name]!.surfaceY;

  bool hasFrame(String name) => _frames.containsKey(name);

  // Returns ordered animation frames; falls back to `name_1..name_8`.
  List<Frame> animation(String name) {
    final anim = _animations[name];
    if (anim != null && anim.isNotEmpty) return anim;
    final built = <Frame>[];
    for (int i = 1; i <= 8; i++) {
      final f = _frames['$name\_$i'];
      if (f != null) built.add(f);
    }
    return built;
  }

  // Contain + center inside a cell (matches drawFrameInCell / drawAnimationInCell).
  void drawCell(ui.Canvas canvas, String name, double x, double y, double w,
      double h, {double alpha = 1}) {
    final fr = _frames[name];
    if (fr == null) return;
    drawFrame(canvas, fr, x, y, w, h, alpha: alpha);
  }

  void drawFrame(ui.Canvas canvas, Frame fr, double x, double y, double w, double h,
      {double alpha = 1}) {
    final crop = fr.crop;
    final scale = (w / crop.width).clamp(0, 1e9) < (h / crop.height).clamp(0, 1e9)
        ? w / crop.width
        : h / crop.height;
    final dw = crop.width * scale;
    final dh = crop.height * scale;
    final dx = x + (w - dw) / 2;
    final dy = y + (h - dh) / 2;
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    if (alpha != 1) paint.color = const ui.Color(0xffffffff).withAlpha((alpha * 255).round());
    canvas.drawImageRect(image, crop, ui.Rect.fromLTWH(dx, dy, dw, dh), paint);
  }

  // Anchor-based draw (matches player / fox placement).
  void drawAnchored(ui.Canvas canvas, String name, double pivotX, double pivotY,
      double scale, {double alpha = 1, bool flipX = false}) {
    final fr = _frames[name];
    if (fr == null) return;
    final crop = fr.crop;
    final dw = crop.width * scale;
    final dh = crop.height * scale;
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    if (alpha != 1) paint.color = const ui.Color(0xffffffff).withAlpha((alpha * 255).round());

    if (flipX) {
      canvas.save();
      canvas.translate(pivotX, pivotY);
      canvas.scale(-1, 1);
      canvas.drawImageRect(
          image,
          crop,
          ui.Rect.fromLTWH(-(fr.anchor.dx - crop.left) * scale,
              -(fr.anchor.dy - crop.top) * scale, dw, dh),
          paint);
      canvas.restore();
    } else {
      canvas.drawImageRect(
          image,
          crop,
          ui.Rect.fromLTWH(pivotX - (fr.anchor.dx - crop.left) * scale,
              pivotY - (fr.anchor.dy - crop.top) * scale, dw, dh),
          paint);
    }
  }

  // Height of the tallest frame among a list of names (used for player scale).
  double maxHeight(List<String> names) {
    double max = 0;
    for (final n in names) {
      final fr = _frames[n];
      if (fr != null && fr.crop.height > max) max = fr.crop.height;
    }
    return max;
  }
}

Future<Sheet> loadSheet(String jsonPath, String imagePath, ui.Image image) async {
  final raw = await rootBundle.loadString(jsonPath);
  final data = json.decode(raw) as Map<String, dynamic>;
  final framesList = (data['frames'] as List).cast<Map<String, dynamic>>();
  final frames = <String, Frame>{};
  for (final f in framesList) {
    final name = f['name'] as String;
    final source = f['source'] as Map<String, dynamic>;
    final content = (f['content'] as Map<String, dynamic>?) ?? source;
    final anchor = (f['anchor'] as Map<String, dynamic>?) ??
        {'x': content['x'], 'y': content['y']};
    final crop = ui.Rect.fromLTWH(
      (content['x'] as num).toDouble(),
      (content['y'] as num).toDouble(),
      (content['w'] as num).toDouble(),
      (content['h'] as num).toDouble(),
    );
    final anchorOff = ui.Offset(
      (anchor['x'] as num).toDouble(),
      (anchor['y'] as num).toDouble(),
    );
    final surfaceY = (f['surfaceY'] as num?)?.toDouble();
    frames[name] = Frame(crop, anchorOff, surfaceY);
  }
  final animations = <String, List<Frame>>{};
  final animList = (data['animations'] as List? ?? []) as List;
  for (final a in animList.cast<Map<String, dynamic>>()) {
    final animName = a['name'] as String;
    final aframes = (a['frames'] as List).cast<Map<String, dynamic>>();
    animations[animName] = [
      for (final af in aframes)
        frames[af['name'] as String] ??
            Frame(
              ui.Rect.fromLTWH(
                (af['content']?['x'] ?? af['source']['x']).toDouble(),
                (af['content']?['y'] ?? af['source']['y']).toDouble(),
                (af['content']?['w'] ?? af['source']['w']).toDouble(),
                (af['content']?['h'] ?? af['source']['h']).toDouble(),
              ),
              ui.Offset(
                (af['anchor']?['x'] ?? af['content']?['x'] ?? af['source']['x']).toDouble(),
                (af['anchor']?['y'] ?? af['content']?['y'] ?? af['source']['y']).toDouble(),
              ),
            )
    ];
  }
  return Sheet(image, frames, animations);
}
