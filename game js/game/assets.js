import { AREAS, SKINS } from "./config.js";

function loadImage(url) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error(`Gagal memuat ${url}`));
    image.src = url;
  });
}

function frameUrl(imageUrl) {
  return imageUrl.replace(/\.webp(?:\?.*)?$/, ".frames.json");
}

async function loadSheet(url) {
  const [image, response] = await Promise.all([loadImage(url), fetch(frameUrl(url))]);
  if (!response.ok) throw new Error(`Gagal memuat frame ${url}`);
  const data = await response.json();
  return {
    image,
    frames: new Map(data.frames.map((frame) => [frame.name, frame])),
    animations: new Map((data.animations || []).map((animation) => [animation.name, animation.frames])),
  };
}

export async function loadGameAssets(assets) {
  const get = (key) => assets?.get(key);
  const backgrounds = await Promise.all(
    Array.from({ length: AREAS.length }, (_, index) => loadImage(get(`AREA_${index + 1}_BG`))),
  );
  const rabbitSkins = new Map(await Promise.all(SKINS.map(async (skin) => [skin.id, await loadSheet(get(skin.asset))])));
  const loaded = await Promise.all([
    loadSheet(get("PLATFORM_ATLAS")),
    loadSheet(get("PLATFORM_VARIANTS")),
    loadSheet(get("PLATFORM_VARIANTS_2")),
    loadSheet(get("OBJECT_ATLAS")),
    loadSheet(get("MUSHROOM_PLATFORM")),
    loadSheet(get("LANDMARK_ATLAS")),
    loadSheet(get("AREA_EFFECTS")),
    loadSheet(get("AREA_CREATURES_1")),
    loadSheet(get("AREA_CREATURES_2")),
    loadSheet(get("AREA_CREATURES_3")),
    loadSheet(get("AREA_CREATURES_4")),
    loadSheet(get("WEATHER_EFFECTS_1")),
    loadSheet(get("WEATHER_EFFECTS_2")),
    loadSheet(get("WEATHER_EFFECTS_3")),
    loadSheet(get("WEATHER_EFFECTS_4")),
    loadSheet(get("CRESCENDO_EFFECTS")),
    loadSheet(get("FOX_CHASE")),
    loadSheet(get("SKILL_EFFECTS_1")),
    loadSheet(get("SKILL_EFFECTS_2")),
    loadSheet(get("SKILL_EFFECTS_3")),
    loadSheet(get("PLATFORMS_11_13")),
    loadSheet(get("PLATFORMS_14_15")),
    loadSheet(get("PLATFORMS_16_18")),
    loadSheet(get("PLATFORMS_19_20")),
    loadSheet(get("LANDMARKS_11_20")),
    loadSheet(get("ENEMIES_11_13")),
    loadSheet(get("ENEMIES_14_16")),
    loadSheet(get("ENEMIES_17_19")),
    loadSheet(get("ENEMIES_20")),
    loadSheet(get("WEATHER_11_13")),
    loadSheet(get("WEATHER_14_16")),
    loadSheet(get("WEATHER_17_19")),
    loadSheet(get("WEATHER_20")),
  ]);
  const [platforms, platformVariants, platformVariants2, objects, mushroom, landmarks, effects, ...animated] = loaded;
  return {
    backgrounds,
    rabbitSkins,
    platforms,
    platformVariants,
    platformVariants2,
    objects,
    mushroom,
    landmarks,
    effects,
    crescendo: animated[8],
    fox: animated[9],
    skillEffects: animated.slice(10, 13),
    realmPlatforms: animated.slice(13, 17),
    realmLandmarks: animated[17],
    creatures: [...animated.slice(0, 4), ...animated.slice(18, 22)],
    weather: [...animated.slice(4, 8), ...animated.slice(22, 26)],
  };
}
