import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'config.dart';
import 'frames.dart';

// Maps the logical asset key (from assets.json / link.json) to the real
// filename inside assets/images. Frames live in assets/jsons as
// `<filename>.frames.json`.
const Map<String, String> assetFiles = {
  'AREA_3_BG': 'area_3_bg.webp',
  'AREA_4_BG': 'area_4_bg.webp',
  'AREA_2_BG': 'area_2_bg.webp',
  'AREA_1_BG': 'area_1_bg.webp',
  'AREA_5_BG': 'area_5_bg.webp',
  'PLATFORM_ATLAS': 'platform_atlas-transparent.webp',
  'OBJECT_ATLAS': 'object_atlas-transparent.webp',
  'AREA_6_BG': 'area_6_bg.webp',
  'AREA_7_BG': 'area_7_bg.webp',
  'AREA_9_BG': 'area_9_bg.webp',
  'AREA_8_BG': 'area_8_bg.webp',
  'AREA_10_BG': 'area_10_bg.webp',
  'MUSHROOM_PLATFORM': 'mushroom_platform-transparent.webp',
  'LANDMARK_ATLAS': 'landmark_atlas-transparent.webp',
  'AREA_EFFECTS': 'area_effects-transparent.webp',
  'PLATFORM_VARIANTS': 'platform_variants-transparent.webp',
  'RABBIT_12_PAJAMA': 'rabbit_12_pajama-transparent.webp',
  'RABBIT_12_RANGER': 'rabbit_12_ranger-transparent.webp',
  'RABBIT_12_CYBER': 'rabbit_12_cyber-transparent.webp',
  'PLATFORM_VARIANTS_2': 'platform_variants_2-transparent.webp',
  'RABBIT_12_NINJA': 'rabbit_12_ninja-transparent.webp',
  'RABBIT_12_FARMER': 'rabbit_12_farmer-transparent.webp',
  'RABBIT_12_CHEF': 'rabbit_12_chef-transparent.webp',
  'RABBIT_12_KNIGHT': 'rabbit_12_knight-transparent.webp',
  'RABBIT_12_ASTRO': 'rabbit_12_astro-transparent.webp',
  'RABBIT_12_DJ': 'rabbit_12_dj-transparent.webp',
  'RABBIT_12_WIZARD': 'rabbit_12_wizard-transparent.webp',
  'AREA_CREATURES_4': 'area_creatures_4-transparent.webp',
  'AREA_CREATURES_1': 'area_creatures_1-transparent.webp',
  'AREA_CREATURES_2': 'area_creatures_2-transparent.webp',
  'AREA_CREATURES_3': 'area_creatures_3-transparent.webp',
  'WEATHER_EFFECTS_1': 'weather_effects_1-transparent.webp',
  'WEATHER_EFFECTS_4': 'weather_effects_4-transparent.webp',
  'WEATHER_EFFECTS_3': 'weather_effects_3-transparent.webp',
  'WEATHER_EFFECTS_2': 'weather_effects_2-transparent.webp',
  'FOX_CHASE': 'fox_chase-transparent.webp',
  'CRESCENDO_EFFECTS': 'crescendo_effects-transparent.webp',
  'RABBIT_12_DRAGON': 'rabbit_12_dragon-transparent.webp',
  'RABBIT_12_ALCHEMIST': 'rabbit_12_alchemist-transparent.webp',
  'RABBIT_12_BEEKEEPER': 'rabbit_12_beekeeper-transparent.webp',
  'SKILL_EFFECTS_1': 'skill_effects_1-transparent.webp',
  'RABBIT_12_MONK': 'rabbit_12_monk-transparent.webp',
  'RABBIT_12_PIRATE': 'rabbit_12_pirate-transparent.webp',
  'RABBIT_12_RAINBOW': 'rabbit_12_rainbow-transparent.webp',
  'RABBIT_12_TIMEKEEPER': 'rabbit_12_timekeeper-transparent.webp',
  'RABBIT_12_MOON': 'rabbit_12_moon-transparent.webp',
  'SKILL_EFFECTS_3': 'skill_effects_3-transparent.webp',
  'RABBIT_12_MINER': 'rabbit_12_miner-transparent.webp',
  'SKILL_EFFECTS_2': 'skill_effects_2-transparent.webp',
  'RABBIT_12_LAVA': 'rabbit_12_lava-transparent.webp',
  'AREA_14_BG': 'area_14_bg.webp',
  'AREA_12_BG': 'area_12_bg.webp',
  'AREA_11_BG': 'area_11_bg.webp',
  'AREA_13_BG': 'area_13_bg.webp',
  'AREA_17_BG': 'area_17_bg.webp',
  'AREA_15_BG': 'area_15_bg.webp',
  'AREA_16_BG': 'area_16_bg.webp',
  'AREA_19_BG': 'area_19_bg.webp',
  'AREA_18_BG': 'area_18_bg.webp',
  'AREA_20_BG': 'area_20_bg.webp',
  'LANDMARKS_11_20': 'landmarks_11_20-transparent.webp',
  'PLATFORMS_14_15': 'platforms_14_15-transparent.webp',
  'PLATFORMS_19_20': 'platforms_19_20-transparent.webp',
  'PLATFORMS_16_18': 'platforms_16_18-transparent.webp',
  'PLATFORMS_11_13': 'platforms_11_13-transparent.webp',
  'ENEMIES_20': 'enemies_20-transparent.webp',
  'ENEMIES_14_16': 'enemies_14_16-transparent.webp',
  'ENEMIES_11_13': 'enemies_11_13-transparent.webp',
  'ENEMIES_17_19': 'enemies_17_19-transparent.webp',
  'WEATHER_20': 'weather_20-transparent.webp',
  'WEATHER_14_16': 'weather_14_16-transparent.webp',
  'WEATHER_17_19': 'weather_17_19-transparent.webp',
  'WEATHER_11_13': 'weather_11_13-transparent.webp',
};

Future<ui.Image> loadImageFile(String file) async {
  final data = await rootBundle.load('assets/images/$file');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final fi = await codec.getNextFrame();
  return fi.image;
}

class Art {
  final List<ui.Image> backgrounds;
  final Map<String, Sheet> rabbitSkins;
  final Sheet platforms;
  final Sheet platformVariants;
  final Sheet platformVariants2;
  final Sheet objects;
  final Sheet mushroom;
  final Sheet landmarks;
  final Sheet effects;
  final Sheet crescendo;
  final Sheet fox;
  final List<Sheet> skillEffects;
  final List<Sheet> realmPlatforms;
  final Sheet realmLandmarks;
  final List<Sheet> creatures;
  final List<Sheet> weather;

  Art({
    required this.backgrounds,
    required this.rabbitSkins,
    required this.platforms,
    required this.platformVariants,
    required this.platformVariants2,
    required this.objects,
    required this.mushroom,
    required this.landmarks,
    required this.effects,
    required this.crescendo,
    required this.fox,
    required this.skillEffects,
    required this.realmPlatforms,
    required this.realmLandmarks,
    required this.creatures,
    required this.weather,
  });
}

// Order mirrors game js/game/assets.js loadGameAssets.
const List<String> _sheetKeys = [
  'PLATFORM_ATLAS', 'PLATFORM_VARIANTS', 'PLATFORM_VARIANTS_2', 'OBJECT_ATLAS',
  'MUSHROOM_PLATFORM', 'LANDMARK_ATLAS', 'AREA_EFFECTS',
  'AREA_CREATURES_1', 'AREA_CREATURES_2', 'AREA_CREATURES_3', 'AREA_CREATURES_4',
  'WEATHER_EFFECTS_1', 'WEATHER_EFFECTS_2', 'WEATHER_EFFECTS_3', 'WEATHER_EFFECTS_4',
  'CRESCENDO_EFFECTS', 'FOX_CHASE',
  'SKILL_EFFECTS_1', 'SKILL_EFFECTS_2', 'SKILL_EFFECTS_3',
  'PLATFORMS_11_13', 'PLATFORMS_14_15', 'PLATFORMS_16_18', 'PLATFORMS_19_20',
  'LANDMARKS_11_20',
  'ENEMIES_11_13', 'ENEMIES_14_16', 'ENEMIES_17_19', 'ENEMIES_20',
  'WEATHER_11_13', 'WEATHER_14_16', 'WEATHER_17_19', 'WEATHER_20',
];

Future<Art> loadArt() async {
  final backgrounds = await Future.wait(
    List.generate(AREAS.length, (i) => loadImageFile(assetFiles['AREA_${i + 1}_BG']!)),
  );

  String stripExt(String file) => file.replaceAll(RegExp(r'\.webp$'), '');

  final rabbitSkins = <String, Sheet>{};
  for (final skin in SKINS) {
    final file = assetFiles[skin.asset]!;
    final image = await loadImageFile(file);
    rabbitSkins[skin.id] = await loadSheet(
      'assets/jsons/${stripExt(file)}.frames.json', 'assets/images/$file', image);
  }

  final loaded = await Future.wait(_sheetKeys.map((key) async {
    final file = assetFiles[key]!;
    final image = await loadImageFile(file);
    return loadSheet('assets/jsons/${stripExt(file)}.frames.json', 'assets/images/$file', image);
  }));

  final platforms = loaded[0];
  final platformVariants = loaded[1];
  final platformVariants2 = loaded[2];
  final objects = loaded[3];
  final mushroom = loaded[4];
  final landmarks = loaded[5];
  final effects = loaded[6];
  final animated = loaded.sublist(7);

  return Art(
    backgrounds: backgrounds,
    rabbitSkins: rabbitSkins,
    platforms: platforms,
    platformVariants: platformVariants,
    platformVariants2: platformVariants2,
    objects: objects,
    mushroom: mushroom,
    landmarks: landmarks,
    effects: effects,
    crescendo: animated[8],
    fox: animated[9],
    skillEffects: animated.sublist(10, 13),
    realmPlatforms: animated.sublist(13, 17),
    realmLandmarks: animated[17],
    creatures: [...animated.sublist(0, 4), ...animated.sublist(18, 22)],
    weather: [...animated.sublist(4, 8), ...animated.sublist(22, 26)],
  );
}
