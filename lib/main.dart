import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/config.dart';
import 'game/art.dart';
import 'game/frames.dart';
import 'game/game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const CosmosApp());
}

class CosmosApp extends StatelessWidget {
  const CosmosApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: "Petualangan Kelinci Bintang",
        debugShowCheckedModeBanner: false,
        home: GameScreen(),
      );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CosmosGame game;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    game = CosmosGame(GameController());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(KeyEvent event) {
    final down = event is KeyDownEvent;
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.keyA) {
      game.input.setLeft(down);
    } else if (k == LogicalKeyboardKey.arrowRight ||
        k == LogicalKeyboardKey.keyD) {
      game.input.setRight(down);
    } else if (k == LogicalKeyboardKey.space ||
        k == LogicalKeyboardKey.arrowUp ||
        k == LogicalKeyboardKey.keyW) {
      if (down) {
        game.input.pressJump();
      } else {
        game.input.releaseJump();
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _screenJumpDown() {
    final ui = game.controller.uiNotifier.value;
    if (game.controller.showSkinsNotifier.value || ui.showResult) return;
    game.input.pressJump();
  }

  void _screenJumpUp() => game.input.releaseJump();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: _onKeyEvent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => _screenJumpDown(),
                      onTapUp: (_) => _screenJumpUp(),
                      onTapCancel: _screenJumpUp,
                      child: GameWidget(game: game),
                    ),
                  ),
                  const Hud(),
                  const SkinPicker(),
                  const MapPicker(),
                  const ResultPanel(),
                  const LoadingPanel(),
                ],
              ),
            ),
          ),
          const TouchControls(),
        ],
      ),
    );
  }
}

class Hud extends StatelessWidget {
  const Hud({super.key});
  @override
  Widget build(BuildContext context) {
    final game = context.findAncestorStateOfType<_GameScreenState>()!.game;
    final controller = game.controller;
    return ValueListenableBuilder<CosmosUi>(
      valueListenable: _uiOf(controller),
      builder: (context, ui, _) => Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                _Badge(text: "${ui.height}m", icon: "↟"),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xcc291b32),
                    ),
                    child: Text(
                      "${ui.areaShort} · ${ui.stageIndex + 1}/5",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<int>(
                  valueListenable: controller.bank,
                  builder: (context, bank, _) =>
                      _Badge(text: "$bank", icon: "🥕"),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: game.audio.muted,
                  builder: (context, muted, _) => GestureDetector(
                    onTap: () {
                      game.audio.toggleMute();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: muted
                              ? const Color(0xffff9fbd)
                              : const Color(0xff80f0de),
                        ),
                        borderRadius: BorderRadius.circular(13),
                        color: muted
                            ? const Color(0x664a213b)
                            : const Color(0x66304d5c),
                      ),
                      child: Icon(
                        muted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: muted
                            ? const Color(0xffffb4cb)
                            : const Color(0xffbaffef),
                        size: 21,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => game.openShop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38),
                      borderRadius: BorderRadius.circular(13),
                      color: const Color(0xcc291b32),
                    ),
                    child: const Text(
                      "◈",
                      style: TextStyle(color: Color(0xfffff3c0), fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 56,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (ui.intensity < 0.2)
                  _Pip(text: "TENANG")
                else if (ui.intensity < 0.45)
                  _Pip(text: "MULAI RAMAI")
                else if (ui.intensity < 0.72)
                  _Pip(text: "HEBOH")
                else
                  _Pip(text: "KOSMIK!"),
                if (ui.shield > 1)
                  _Pip(text: "PERISAI ×${ui.shield}")
                else if (ui.shield == 1)
                  _Pip(text: "PERISAI"),
                if (ui.power.isNotEmpty) _Pip(text: ui.power),
                if (ui.phase == "playing" || ui.phase == "ready")
                  _Pip(text: "LOMPAT ${ui.height}m"),
              ],
            ),
          ),
          if (ui.messageVisible)
            Positioned(
              top: 92,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xcc2a1934),
                  ),
                  child: Text(
                    ui.message,
                    style: const TextStyle(
                      color: Color(0xfffff2bd),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

ValueNotifier<CosmosUi> _uiOf(GameController c) => c.uiNotifier;

class _Badge extends StatelessWidget {
  final String text;
  final String icon;
  const _Badge({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white24),
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xcc291b32),
    ),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(color: Color(0xffb8edff))),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xfffff6d6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _Pip extends StatelessWidget {
  final String text;
  const _Pip({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 5),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0x80c4eeff)),
      borderRadius: BorderRadius.circular(999),
      color: const Color(0xd4202241),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xffc9f3ff),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class TouchControls extends StatelessWidget {
  const TouchControls({super.key});
  @override
  Widget build(BuildContext context) {
    final game = context.findAncestorStateOfType<_GameScreenState>()!.game;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x6657d9ff))),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff182348), Color(0xff11152f)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x663d75ff),
            blurRadius: 22,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 22, height: 1, color: const Color(0x6680f0de)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Text(
                  "KONTROL KOSMIK",
                  style: TextStyle(
                    color: Color(0xffa4b5ed),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              Container(width: 22, height: 1, color: const Color(0x6680f0de)),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 340;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CtrlButton(
                    icon: Icons.chevron_left_rounded,
                    label: "GERAK",
                    compact: compact,
                    onDown: () => game.input.setLeft(true),
                    onUp: () => game.input.setLeft(false),
                  ),
                  _CtrlButton(
                    icon: Icons.keyboard_double_arrow_up_rounded,
                    label: compact ? "LOMPAT" : "TAHAN UNTUK\nLOMPAT",
                    compact: compact,
                    big: true,
                    onDown: () => game.input.pressJump(),
                    onUp: () => game.input.releaseJump(),
                  ),
                  _CtrlButton(
                    icon: Icons.chevron_right_rounded,
                    label: "GERAK",
                    compact: compact,
                    onDown: () => game.input.setRight(true),
                    onUp: () => game.input.setRight(false),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CtrlButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool compact;
  final bool big;
  final VoidCallback onDown;
  final VoidCallback onUp;
  const _CtrlButton({
    required this.label,
    required this.icon,
    this.compact = false,
    this.big = false,
    required this.onDown,
    required this.onUp,
  });
  @override
  State<_CtrlButton> createState() => _CtrlButtonState();
}

class _CtrlButtonState extends State<_CtrlButton> {
  bool pressed = false;

  void _setPressed(bool value) {
    if (mounted) setState(() => pressed = value);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) {
      _setPressed(true);
      widget.onDown();
    },
    onTapUp: (_) {
      _setPressed(false);
      widget.onUp();
    },
    onTapCancel: () {
      _setPressed(false);
      widget.onUp();
    },
    child: Container(
      width: widget.big
          ? (widget.compact ? 112 : 142)
          : (widget.compact ? 60 : 78),
      height: widget.big ? 72 : 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.big
              ? [const Color(0xff6e62ed), const Color(0xffa942bd)]
              : [const Color(0xff294b83), const Color(0xff202b60)],
        ),
        border: Border.all(
          color: widget.big ? const Color(0xffd8b2ff) : const Color(0xff6edff0),
          width: pressed ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(widget.big ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color:
                (widget.big ? const Color(0xffb45bff) : const Color(0xff32d4e8))
                    .withOpacity(pressed ? 0.55 : 0.25),
            blurRadius: pressed ? 20 : 12,
            spreadRadius: pressed ? 2 : 0,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Color(0x5510142e),
            blurRadius: 3,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: const Color(0xffefffff),
              size: widget.big ? 28 : 29,
            ),
            if (widget.big) ...[
              const SizedBox(width: 5),
              Text(
                widget.label,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ] else if (!widget.compact) ...[
              const SizedBox(width: 2),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xffbfeeff),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class SkinPicker extends StatelessWidget {
  const SkinPicker({super.key});
  @override
  Widget build(BuildContext context) {
    final game = context.findAncestorStateOfType<_GameScreenState>()!.game;
    final controller = game.controller;
    return ValueListenableBuilder<bool>(
      valueListenable: controller.showSkinsNotifier,
      builder: (context, show, _) {
        if (!show) return const SizedBox.shrink();
        final art = game.art;
        return Stack(
          children: [
            const Positioned.fill(child: _PickerBackdrop()),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        _PickerIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => controller.setShowSkins(false),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "PILIH PARTNER",
                                style: TextStyle(
                                  color: Color(0xff9effce),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                               "Petualangan Kelinci Bintang",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: controller.bank,
                          builder: (context, bank, _) =>
                              _CarrotPill(bank: bank),
                        ),
                        const SizedBox(width: 8),
                        _PickerIconButton(
                          icon: Icons.payments_rounded,
                          onTap: game.grantTestCarrots,
                        ),
                        const SizedBox(width: 8),
                        _PickerIconButton(
                          icon: Icons.map_rounded,
                          onTap: () => controller.showMapNotifier.value = true,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 8, 18, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pilih gaya kamu, lalu lompat lebih tinggi ✦",
                        style: TextStyle(
                          color: Color(0xffc5c9ef),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: controller.shopMessage,
                    builder: (context, msg, _) => msg.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              msg,
                              style: const TextStyle(
                                color: Color(0xffffa7c5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 720
                            ? 4
                            : constraints.maxWidth >= 470
                            ? 3
                            : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: columns == 2 ? 0.84 : 0.78,
                              ),
                          itemCount: SKINS.length,
                          itemBuilder: (context, index) {
                            final skin = SKINS[index];
                            final owned = game.ownedSkins.contains(skin.id);
                            final selected = game.selectedSkin == skin.id;
                            final affordable = game.bankCarrots >= skin.price;
                            return _SkinCard(
                              skin: skin,
                              accent: _skinAccents[index % _skinAccents.length],
                              owned: owned,
                              selected: selected,
                              locked: !owned && !affordable,
                              art: art,
                              onTap: () => game.chooseSkin(skin.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

const _skinAccents = <Color>[
  Color(0xff63f5a5),
  Color(0xff57d9ff),
  Color(0xffb58cff),
  Color(0xffff8fbd),
  Color(0xffffca68),
  Color(0xff80f0de),
  Color(0xff8da7ff),
  Color(0xffd79cff),
];

class _PickerBackdrop extends StatelessWidget {
  const _PickerBackdrop();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff111936), Color(0xff17132e), Color(0xff25113d)],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          top: -80,
          right: -50,
          child: _GlowOrb(color: Color(0xff3ee5c1), size: 230),
        ),
        Positioned(
          bottom: -90,
          left: -70,
          child: _GlowOrb(color: Color(0xff905cff), size: 260),
        ),
        Positioned(
          top: 190,
          left: 25,
          child: _GlowOrb(color: Color(0xff258fff), size: 90),
        ),
      ],
    ),
  );
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.12),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.18),
          blurRadius: 80,
          spreadRadius: 30,
        ),
      ],
    ),
  );
}

class _PickerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PickerIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x331cdbca),
        border: Border.all(color: const Color(0x669effce)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xffdffff5), size: 22),
    ),
  );
}

class _CarrotPill extends StatelessWidget {
  final int bank;
  const _CarrotPill({required this.bank});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0x3329ddbb),
      border: Border.all(color: const Color(0x669effce)),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      children: [
        const Text("🥕", style: TextStyle(fontSize: 15)),
        const SizedBox(width: 5),
        Text(
          "$bank",
          style: const TextStyle(
            color: Color(0xffdffff5),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _SkinCard extends StatelessWidget {
  final Skin skin;
  final Color accent;
  final bool owned;
  final bool selected;
  final bool locked;
  final Art? art;
  final VoidCallback onTap;
  const _SkinCard({
    required this.skin,
    required this.accent,
    required this.owned,
    required this.selected,
    required this.locked,
    required this.art,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final label = owned ? (selected ? "DIPAKAI" : "PILIH") : "${skin.price} 🥕";
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withOpacity(locked ? 0.07 : 0.18),
              const Color(0xcc171936),
            ],
          ),
          border: Border.all(
            color: selected ? accent : accent.withOpacity(0.35),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(selected ? 0.28 : 0.08),
              blurRadius: selected ? 18 : 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(locked ? 0.05 : 0.14),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.22),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  if (art != null)
                    Opacity(
                      opacity: locked ? 0.38 : 1,
                      child: CustomPaint(
                        painter: SkinPreviewPainter(
                          art!.rabbitSkins[skin.id]!,
                          skin.animation,
                        ),
                        size: const Size(90, 92),
                      ),
                    ),
                  if (locked)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(
                        Icons.lock_rounded,
                        color: Color(0xff9b9abf),
                        size: 16,
                      ),
                    ),
                  if (selected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: accent,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              skin.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              skin.skill,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xffb9bddc),
                fontSize: 10,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withOpacity(locked ? 0.08 : 0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: locked ? const Color(0xff9294b6) : accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPicker extends StatelessWidget {
  const MapPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.findAncestorStateOfType<_GameScreenState>()!.game;
    final controller = game.controller;
    return ValueListenableBuilder<bool>(
      valueListenable: controller.showMapNotifier,
      builder: (context, show, _) {
        if (!show) return const SizedBox.shrink();
        return Stack(
          children: [
            const Positioned.fill(child: _PickerBackdrop()),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        _PickerIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => controller.showMapNotifier.value = false,
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MODE TESTING",
                              style: TextStyle(
                                color: Color(0xffffca68),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Pilih Map",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pilih area untuk langsung teleport ke sana ✦",
                        style: TextStyle(
                          color: Color(0xffc5c9ef),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                      itemCount: AREAS.length,
                      itemBuilder: (context, index) {
                        final area = AREAS[index];
                        final accent =
                            _skinAccents[index % _skinAccents.length];
                        return GestureDetector(
                          onTap: () => game.travelToTestMap(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accent.withOpacity(0.18),
                                  const Color(0xcc171936),
                                ],
                              ),
                              border: Border.all(
                                color: accent.withOpacity(0.45),
                              ),
                              borderRadius: BorderRadius.circular(17),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.1),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent.withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    Icons.public_rounded,
                                    color: accent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "AREA ${index + 1} · ${area.short}",
                                        style: TextStyle(
                                          color: accent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        area.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.bolt_rounded,
                                  color: accent,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SkinPreviewPainter extends CustomPainter {
  final Sheet sheet;
  final String anim;
  SkinPreviewPainter(this.sheet, this.anim);
  @override
  void paint(Canvas canvas, Size size) {
    final fr = sheet.frame('${anim}_1');
    if (fr == null) return;
    final crop = fr.crop;
    final scale =
        math.min(size.width / crop.width, size.height / crop.height) * 0.95;
    final dw = crop.width * scale;
    final dh = crop.height * scale;
    canvas.drawImageRect(
      sheet.image,
      crop,
      Rect.fromLTWH((size.width - dw) / 2, size.height - dh, dw, dh),
      ui.Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class ResultPanel extends StatelessWidget {
  const ResultPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final game = context.findAncestorStateOfType<_GameScreenState>()!.game;
    return ValueListenableBuilder<CosmosUi>(
      valueListenable: game.controller.uiNotifier,
      builder: (context, ui, _) {
        if (!(ui.showResult)) return const SizedBox.shrink();
        final won = ui.phase == "won";
        return Container(
          color: const Color(0x9e181e22),
          child: Center(
            child: Container(
              width: 330,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xfff5dda2)),
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xff392744),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    won ? "PUNCAK TERCAPAI" : "KETINGGIAN LOMPATAN",
                    style: const TextStyle(
                      color: Color(0xffe9c96f),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${ui.height}m",
                    style: const TextStyle(
                      color: Color(0xfffff1b8),
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: game.controller.bank,
                    builder: (context, bank, _) => Text(
                      "Rekor ${ui.best}m · $bank wortel",
                      style: const TextStyle(color: Color(0xffd5c8da)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => game.retry(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffdf714c),
                    ),
                    child: const Text("Lompat Lagi"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final game = context.findAncestorStateOfType<_GameScreenState>()!.game;
    return ValueListenableBuilder<bool>(
      valueListenable: game.controller.ready,
      builder: (context, ready, _) {
        if (ready) return const SizedBox.shrink();
        return Container(
          color: const Color(0xff345e43),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 34,
                  height: 55,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0xfffff0df), width: 5),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Menyiapkan jalur...",
                  style: TextStyle(color: Color(0xfffff2c2)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
