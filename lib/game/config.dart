// Mirror of game js/game/config.js
class Area {
  final String name;
  final String short;
  final String platform;
  final String tint;
  const Area(this.name, this.short, this.platform, this.tint);
}

class Skin {
  final String id;
  final String name;
  final String skill;
  final String asset;
  final String animation;
  final int price;
  final String? effect;
  final int? effectSheet;
  const Skin(this.id, this.name, this.skill, this.asset, this.animation,
      this.price, [this.effect, this.effectSheet]);
}

class Encounter {
  final String animation;
  final int sheet;
  final bool reward;
  const Encounter(this.animation, this.sheet, [this.reward = false]);
}

class WeatherEvent {
  final String animation;
  final int sheet;
  final String? force;
  final bool harmful;
  const WeatherEvent(this.animation, this.sheet, this.harmful, [this.force]);
}

const double WORLD_WIDTH = 420;

const List<Area> AREAS = [
  Area("Padang Rumput", "MEADOW", "meadow_stump", "#b8df79"),
  Area("Hutan Berbisik", "WOODS", "forest_leaf", "#4f9a64"),
  Area("Air Terjun Kabut", "MIST", "waterfall_rock", "#77c8c5"),
  Area("Punggung Gugur", "AUTUMN", "autumn_branch", "#e59b4c"),
  Area("Tebing Dengung", "BUZZER", "honey_cliff", "#f4c34e"),
  Area("Puncak Beku", "FROST", "snow_ice", "#b8edff"),
  Area("Badai Petir", "STORM", "storm_cloud", "#7989d7"),
  Area("Reruntuhan Langit", "RUINS", "ruin_slab", "#e1b76f"),
  Area("Stratosfer", "STRATO", "strato_bubble", "#bc8ee8"),
  Area("Puncak Kosmik", "COSMIC", "cosmic_meteor", "#ee79d1"),
  Area("Taman Bulan", "MOON", "moon_crater_disc", "#d8d4ff"),
  Area("Kota Roda Waktu", "CLOCK", "clock_brass_gear", "#e1a958"),
  Area("Gua Kristal", "CRYSTAL", "crystal_amethyst_shelf", "#87e6ff"),
  Area("Gunung Naga", "VOLCANO", "volcano_basalt_ledge", "#ff7048"),
  Area("Kerajaan Awan Permen", "CANDY", "candy_wafer_bridge", "#ff9dcc"),
  Area("Samudra Langit", "OCEAN", "ocean_coral_shelf", "#5fe4dc"),
  Area("Karnaval Arwah", "CARNIVAL", "carnival_ticket_roof", "#b989ff"),
  Area("Perpustakaan Tak Berujung", "LIBRARY", "library_book_stack", "#e4b879"),
  Area("Dimensi Prisma", "PRISM", "prism_glass_shard", "#88f4ff"),
  Area("Pandai Bintang Abadi", "FORGE", "forge_star_iron", "#ffd56a"),
];

const List<Skin> SKINS = [
  Skin("ranger", "Bunny Ranger", "Sinyal 5 pijakan: lompat 1,5×", "RABBIT_12_RANGER", "ranger_leap", 0),
  Skin("cyber", "Cyber Hopper", "Double jump setiap 3 detik", "RABBIT_12_CYBER", "cyber_leap", 50),
  Skin("chef", "Cottontail Chef", "Power-up bertahan +2 detik", "RABBIT_12_CHEF", "chef_leap", 70),
  Skin("knight", "Royal Knight", "Mulai dengan satu perisai", "RABBIT_12_KNIGHT", "knight_leap", 90),
  Skin("wizard", "Wizard Cottontail", "Tahan lompat saat jatuh untuk melayang", "RABBIT_12_WIZARD", "wizard_leap", 100),
  Skin("farmer", "Farmer Bun", "Setiap wortel bernilai dua", "RABBIT_12_FARMER", "farmer_leap", 80),
  Skin("astro", "Astro Bunny", "Gravitasi 20% lebih ringan", "RABBIT_12_ASTRO", "astro_leap", 110),
  Skin("ninja", "Ninja Shadow", "Menempel dan wall jump tanpa batas", "RABBIT_12_NINJA", "ninja_leap", 130),
  Skin("dj", "DJ Hoppr", "Pendaratan tengah mengusir musuh", "RABBIT_12_DJ", "dj_leap", 140),
  Skin("pajama", "Pajama Sleeper", "Bangkit sekali dari pijakan terakhir", "RABBIT_12_PAJAMA", "pajama_leap", 150),
  Skin("alchemist", "Forest Alchemist", "8 wortel meracik satu perisai", "RABBIT_12_ALCHEMIST", "alchemist_leap", 150, "alchemist_brew", 0),
  Skin("pirate", "Pirate Bun", "Jangkauan wortel luas + harta bonus", "RABBIT_12_PIRATE", "pirate_leap", 120, "pirate_treasure", 0),
  Skin("lava", "Lava Sprinter", "Kebal duri dan bergerak lebih cepat", "RABBIT_12_LAVA", "lava_leap", 170, "lava_dash", 0),
  Skin("monk", "Cloud Monk", "Dorongan cuaca berkurang 65%", "RABBIT_12_MONK", "monk_leap", 140, "monk_zen", 0),
  Skin("beekeeper", "Bee Keeper", "Kebal lebah dan serbuk sari", "RABBIT_12_BEEKEEPER", "beekeeper_leap", 130, "beekeeper_honey", 1),
  Skin("miner", "Crystal Miner", "Checkpoint memberi dua perisai", "RABBIT_12_MINER", "miner_leap", 180, "miner_crystal", 1),
  Skin("timekeeper", "Time Keeper", "Dunia bergerak 22% lebih lambat", "RABBIT_12_TIMEKEEPER", "timekeeper_leap", 190, "timekeeper_clock", 1),
  Skin("moon", "Moon Dancer", "Lompatan kosmik lebih tinggi", "RABBIT_12_MOON", "moon_leap", 200, "moon_crescent", 1),
  Skin("dragon", "Dragon Bun", "Wing dash tambahan di udara", "RABBIT_12_DRAGON", "dragon_leap", 210, "dragon_wing", 2),
  Skin("rainbow", "Rainbow Idol", "Tiga wortel memicu prism burst", "RABBIT_12_RAINBOW", "rainbow_leap", 220, "rainbow_prism", 2),
];

const int PLATFORM_COUNT = 1000;
const int PLATFORMS_PER_AREA = 50;
const int METERS_PER_AREA = 1000;

const List<String> LANDMARKS = [
  "meadow_windmill",
  "woods_tree_spirit",
  "waterfall_frog_totem",
  "autumn_leaf_lantern",
  "buzzer_queen_hive",
  "frost_moon_arch",
  "storm_bell_tower",
  "ruins_guardian",
  "strato_weather_balloon",
  "cosmic_telescope",
  "moon_oracle_tree",
  "clock_grand_tower",
  "crystal_heart_geode",
  "volcano_dragon_skull",
  "candy_royal_gate",
  "ocean_pearl_palace",
  "carnival_ghost_wheel",
  "library_wise_door",
  "prism_light_throne",
  "forge_celestial_hammer",
];

const List<String> CHECKPOINTS = [
  "checkpoint_flag", "checkpoint_flag", "checkpoint_flag", "checkpoint_flag", "checkpoint_flag",
  "checkpoint_flag", "checkpoint_flag", "checkpoint_flag", "checkpoint_flag", "checkpoint_flag",
  "moon_checkpoint", "clock_checkpoint", "crystal_checkpoint", "volcano_checkpoint", "candy_checkpoint",
  "ocean_checkpoint", "carnival_checkpoint", "library_checkpoint", "prism_checkpoint", "forge_checkpoint",
];

const List<List<String>> SUB_AREAS = [
  ["Kebun Bunga", "Jalur Gerobak", "Bukit Kincir", "Lembah Duri", "Gerbang Hutan"],
  ["Akar Rendah", "Lorong Pakis", "Pohon Roh", "Kanopi Burung", "Puncak Pinus"],
  ["Batu Basah", "Kolam Teratai", "Totem Katak", "Jeram Licin", "Tirai Air"],
  ["Lereng Jingga", "Jembatan Biji", "Hutan Lentera", "Pusaran Daun", "Jalur Angin"],
  ["Kebun Madu", "Bunga Serbuk", "Sarang Ratu", "Lorong Lilin", "Kawanan Penjaga"],
  ["Hutan Salju", "Danau Beku", "Gerbang Bulan", "Gua Kristal", "Hujan Es"],
  ["Awan Hujan", "Jalur Layang", "Menara Lonceng", "Pusaran Badai", "Lorong Petir"],
  ["Pilar Patah", "Jembatan Rantai", "Penjaga Kuno", "Ruang Rune", "Gerbang Portal"],
  ["Batas Ozon", "Sayap Kapal", "Balon Cuaca", "Debu Bulan", "Arus Gravitasi"],
  ["Sabuk Meteor", "Pecahan Planet", "Observatorium", "Nebula Retak", "Tangga Bintang"],
  ["Kebun Kawah", "Jalur Mutiara", "Pohon Oracle", "Hujan Bulan", "Gerbang Sabit"],
  ["Pipa Rendah", "Lorong Pegas", "Menara Jam", "Hujan Roda", "Puncak Tengah Malam"],
  ["Akar Kuarsa", "Danau Geode", "Jantung Kristal", "Retakan Prisma", "Mahkota Amethyst"],
  ["Tebing Basalt", "Jembatan Tulang", "Sarang Wyvern", "Sungai Lava", "Mulut Gunung"],
  ["Ladang Wafer", "Lembah Karamel", "Gerbang Permen", "Badai Gula", "Istana Gumdrop"],
  ["Taman Karang", "Arus Gelembung", "Istana Mutiara", "Jalur Hiu", "Puncak Ombak"],
  ["Gerbang Tiket", "Lorong Komidi", "Roda Hantu", "Panggung Arwah", "Tenda Terakhir"],
  ["Rak Tua", "Jembatan Gulungan", "Pintu Bijak", "Tornado Halaman", "Arsip Bintang"],
  ["Lantai Cermin", "Lorong Spektrum", "Takhta Cahaya", "Kipas Laser", "Inti Kaleidoskop"],
  ["Tambang Bintang", "Rantai Tungku", "Palu Langit", "Badai Nova", "Mahkota Abadi"],
];

const List<List<String>> PLATFORM_VARIANTS = [
  ["meadow_flower_rock", "meadow_fallen_log", "meadow_clover_turf", "meadow_wagon_plank"],
  ["woods_root_shelf", "woods_fern_leaf", "woods_mushroom_root", "woods_pinecone_bridge"],
  ["waterfall_lily_stone", "waterfall_cascade_ledge", "waterfall_foam_rock", "waterfall_reed_shelf"],
  ["autumn_maple_bough", "autumn_woven_nest", "autumn_pumpkin_vine", "autumn_acorn_bridge"],
  ["buzzer_wax_shelf", "buzzer_flower_cliff", "buzzer_pollen_pad", "buzzer_honey_jar_lid"],
  ["frost_snow_branch", "frost_crystal_slab", "frost_frozen_log", "frost_aurora_crystal"],
  ["storm_rain_cloud", "storm_thunderhead", "storm_torn_kite", "storm_metal_cloud"],
  ["ruins_column_cap", "ruins_rune_bridge", "ruins_mosaic_slab", "ruins_chain_lift"],
  ["strato_ozone_bubble", "strato_satellite_panel", "strato_airship_panel", "strato_moon_dust"],
  ["cosmic_comet_rock", "cosmic_star_crystal", "cosmic_planet_shard", "cosmic_nebula_crystal"],
];

const List<List<String>> NEW_PLATFORM_VARIANTS = [
  ["moon_crater_disc", "moon_crescent_stone", "moon_pearl_vine", "moon_flower_bed", "moon_stardust_slab"],
  ["clock_brass_gear", "clock_copper_pipe", "clock_hour_hand", "clock_balcony", "clock_spring_pad"],
  ["crystal_amethyst_shelf", "crystal_geode_cap", "crystal_quartz_bridge", "crystal_prism_shard", "crystal_root"],
  ["volcano_basalt_ledge", "volcano_obsidian_plate", "volcano_lava_crust", "volcano_dragon_bone", "volcano_ember_rock"],
  ["candy_wafer_bridge", "candy_marshmallow", "candy_caramel_brittle", "candy_lollipop_disc", "candy_gumdrop_cloud"],
  ["ocean_coral_shelf", "ocean_giant_shell", "ocean_bubble_raft", "ocean_kelp_braid", "ocean_wave_slab"],
  ["carnival_ticket_roof", "carnival_big_drum", "carnival_carousel_base", "carnival_candyfloss_cloud", "carnival_spirit_plank"],
  ["library_book_stack", "library_scroll_bridge", "library_wood_shelf", "library_ink_cloud", "library_flying_pages"],
  ["prism_glass_shard", "prism_mirror_disc", "prism_rainbow_crystal", "prism_light_bridge", "prism_kaleidoscope_tile"],
  ["forge_star_iron", "forge_golden_anvil", "forge_molten_crust", "forge_chain_plate", "forge_crown_metal"],
];

const List<int> NEW_PLATFORM_SHEETS = [0, 0, 0, 1, 1, 2, 2, 2, 3, 3];

const List<Encounter> AREA_ENCOUNTERS = [
  Encounter("meadow_butterflies", 0, true),
  Encounter("woods_owl", 0),
  Encounter("waterfall_frog", 0),
  Encounter("autumn_leaf_spirit", 1),
  Encounter("buzzer_bee_guardian", 1),
  Encounter("frost_snowball", 1),
  Encounter("storm_thunderbird", 2),
  Encounter("ruins_rune_golem", 2),
  Encounter("strato_jellyfish", 2),
  Encounter("cosmic_starling", 3),
  Encounter("moon_moth", 4),
  Encounter("clock_gear_crow", 4),
  Encounter("crystal_mole", 4),
  Encounter("volcano_wyvern", 5),
  Encounter("candy_wasp", 5),
  Encounter("ocean_bubble_shark", 5),
  Encounter("carnival_ghost_jester", 6),
  Encounter("library_ink_owl", 6),
  Encounter("prism_mimic", 6),
  Encounter("forge_star_titan", 7),
];

const List<WeatherEvent> WEATHER_EVENTS = [
  WeatherEvent("meadow_dandelion_gust", 0, false, "right"),
  WeatherEvent("woods_firefly_spiral", 0, false),
  WeatherEvent("waterfall_splash_column", 0, true),
  WeatherEvent("autumn_wind_vortex", 1, false, "alternate"),
  WeatherEvent("buzzer_pollen_burst", 1, true),
  WeatherEvent("frost_snow_gust", 1, false, "left"),
  WeatherEvent("storm_chain_lightning", 2, true),
  WeatherEvent("ruins_rune_beam", 2, true),
  WeatherEvent("strato_gravity_ripple", 2, false, "up"),
  WeatherEvent("cosmic_meteor_shower", 3, true),
  WeatherEvent("moon_meteor_bloom", 4, true),
  WeatherEvent("clock_gear_rain", 4, true),
  WeatherEvent("crystal_shard_quake", 4, true),
  WeatherEvent("volcano_lava_geyser", 5, true),
  WeatherEvent("candy_sugar_storm", 5, true, "alternate"),
  WeatherEvent("ocean_tidal_bubble", 5, false, "up"),
  WeatherEvent("carnival_spectral_spotlight", 6, true),
  WeatherEvent("library_page_tornado", 6, false, "alternate"),
  WeatherEvent("prism_laser_fan", 6, true),
  WeatherEvent("forge_nova_hammer", 7, true),
];
