import { AREAS, CHECKPOINTS, METERS_PER_AREA, NEW_PLATFORM_SHEETS, NEW_PLATFORM_VARIANTS, PLATFORMS_PER_AREA, PLATFORM_VARIANTS, WORLD_WIDTH } from "./config.js";

function drawCover(ctx, image, width, height, offset = 0) {
  const scale = Math.max(width / image.width, height / image.height);
  const drawWidth = image.width * scale;
  const drawHeight = image.height * scale;
  const drift = (drawHeight - height) * offset;
  ctx.drawImage(image, (width - drawWidth) / 2, -drift, drawWidth, drawHeight);
}

function drawFrameInCell(ctx, sheet, name, x, y, width, height, alpha = 1) {
  const frame = sheet.frames.get(name);
  if (!frame) return;
  const crop = frame.content || frame.source;
  const scale = Math.min(width / crop.w, height / crop.h);
  const drawWidth = crop.w * scale;
  const drawHeight = crop.h * scale;
  ctx.save();
  ctx.globalAlpha = alpha;
  ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, x + (width - drawWidth) / 2, y + (height - drawHeight) / 2, drawWidth, drawHeight);
  ctx.restore();
}

function drawAnimationInCell(ctx, sheet, name, index, x, y, width, height, alpha = 1) {
  const frames = sheet.animations.get(name);
  if (!frames?.length) return;
  const frame = frames[Math.max(0, Math.min(frames.length - 1, index))];
  const crop = frame.content || frame.source;
  const scale = Math.min(width / crop.w, height / crop.h);
  const drawWidth = crop.w * scale;
  const drawHeight = crop.h * scale;
  ctx.save();
  ctx.globalAlpha = alpha;
  ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, x + (width - drawWidth) / 2, y + (height - drawHeight) / 2, drawWidth, drawHeight);
  ctx.restore();
}

export function createRenderer(canvas, art) {
  const ctx = canvas.getContext("2d");
  let cssWidth = 1;
  let cssHeight = 1;
  let logicalHeight = 620;

  const resize = () => {
    const rect = canvas.getBoundingClientRect();
    if (!rect.width || !rect.height) return;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    canvas.width = Math.round(rect.width * dpr);
    canvas.height = Math.round(rect.height * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    cssWidth = rect.width;
    cssHeight = rect.height;
    logicalHeight = WORLD_WIDTH * (cssHeight / cssWidth);
  };
  const observer = new ResizeObserver(resize);
  observer.observe(canvas);
  resize();

  function screenY(state, worldY) {
    return logicalHeight - (worldY - state.cameraY);
  }

  function drawPlatform(state, platform) {
    const y = screenY(state, platform.y);
    if (y < -90 || y > logicalHeight + 120) return;
    const alpha = platform.fallTimer >= 0 && !platform.fallen ? 0.65 + Math.sin(state.time * 18) * 0.25 : 1;
    if (platform.kind === "mushroom") {
      const frame = [...art.mushroom.frames.values()][0];
      const crop = frame.content || frame.source;
      const scale = (platform.width * 1.05) / crop.w;
      ctx.save();
      ctx.globalAlpha = alpha;
      ctx.drawImage(art.mushroom.image, crop.x, crop.y, crop.w, crop.h, platform.x - platform.width * 0.025, y - (frame.surfaceY - crop.y) * scale, crop.w * scale, crop.h * scale);
      ctx.restore();
    } else {
      const isNewRealm = platform.area >= 10;
      const useVariant = platform.visualVariant > 0;
      const sheet = isNewRealm
        ? art.realmPlatforms[NEW_PLATFORM_SHEETS[platform.area - 10]]
        : platform.visualVariant > 2 ? art.platformVariants2 : useVariant ? art.platformVariants : art.platforms;
      const frameName = isNewRealm
        ? NEW_PLATFORM_VARIANTS[platform.area - 10][platform.visualVariant]
        : useVariant ? PLATFORM_VARIANTS[platform.area][platform.visualVariant - 1] : AREAS[platform.area].platform;
      const frame = sheet.frames.get(frameName);
      const crop = frame.content || frame.source;
      const scale = platform.width / crop.w;
      ctx.save();
      ctx.globalAlpha = alpha;
      ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, platform.x, y - (frame.surfaceY - crop.y) * scale, crop.w * scale, crop.h * scale);
      ctx.restore();
    }
    if (platform.thorn) drawFrameInCell(ctx, art.objects, "thorn_bush", platform.x + platform.width * 0.62, y - 25, platform.width * 0.38, 32);
    if (platform.kind === "portal") drawFrameInCell(ctx, art.objects, "portal", platform.x + platform.width * 0.25, y - 48, platform.width * 0.5, 48, 0.86);
    if (platform.kind === "portal") drawAnimationInCell(ctx, art.effects, "portal_pulse", Math.floor(state.time * 8) % 6, platform.x + platform.width * 0.18, y - 57, platform.width * 0.64, 58, 0.76);
    if (platform.checkpoint) drawFrameInCell(ctx, platform.area >= 10 ? art.realmLandmarks : art.landmarks, CHECKPOINTS[platform.area], platform.x + platform.width * 0.55, y - 58, 48, 60);
    if (platform.effectTime > 0) {
      const progress = 1 - platform.effectTime / (platform.effectKind === "mushroom_bounce" ? 0.7 : 0.9);
      drawAnimationInCell(ctx, art.effects, platform.effectKind, Math.floor(progress * 6), platform.x + platform.width / 2 - 44, y - 42, 88, 72);
    }
  }

  function drawPlayer(state) {
    const player = state.player;
    const sheet = art.rabbitSkins.get(player.skin.id);
    const frames = Array.from({ length: 12 }, (_, index) => sheet.frames.get(`${player.skin.animation}_${index + 1}`));
    let index = 0;
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
    const frame = frames[index];
    const crop = frame.content || frame.source;
    const largestHeight = Math.max(...frames.map((item) => (item.content || item.source).h));
    const scale = 64 / largestHeight;
    const x = player.x;
    const y = screenY(state, player.y);
    ctx.save();
    if (player.invulnerable > 0 && Math.floor(state.time * 14) % 2 === 0) ctx.globalAlpha = 0.42;
    if (player.facing < 0) {
      ctx.translate(x, y);
      ctx.scale(-1, 1);
      ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, -(frame.anchor.x - crop.x) * scale, -(frame.anchor.y - crop.y) * scale, crop.w * scale, crop.h * scale);
    } else {
      ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, x - (frame.anchor.x - crop.x) * scale, y - (frame.anchor.y - crop.y) * scale, crop.w * scale, crop.h * scale);
    }
    ctx.restore();

    if (player.shield > 0) {
      const glow = ctx.createRadialGradient(x, y - 28, 12, x, y - 28, 39);
      glow.addColorStop(0, "rgba(126,225,255,0.08)");
      glow.addColorStop(0.72, "rgba(126,225,255,0.2)");
      glow.addColorStop(1, "rgba(126,225,255,0)");
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(x, y - 28, 40, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = "rgba(182,244,255,.65)";
      ctx.lineWidth = 2;
      ctx.stroke();
    }
  }

  function drawGuardian(state, guardian) {
    const sheet = art.creatures[guardian.sheet];
    const cycle = sheet.animations.get(guardian.animation)
      || Array.from({ length: 8 }, (_, index) => sheet.frames.get(`${guardian.animation}_${index + 1}`));
    const index = Math.floor(state.time * 7 + guardian.phase * 2) % cycle.length;
    const frame = cycle[index];
    const crop = frame.content || frame.source;
    const boxWidth = guardian.area === 2 || guardian.area === 7 ? 88 : 76;
    const boxHeight = guardian.area === 2 ? 66 : 76;
    const scale = Math.min(boxWidth / crop.w, boxHeight / crop.h);
    const y = screenY(state, guardian.y);
    if (state.intensity > 0.55 && guardian.area >= 4) {
      drawAnimationInCell(ctx, art.crescendo, "guardian_rage_aura", Math.floor(state.time * (7 + state.intensity * 5)) % 8, guardian.x - 51, y - 51, 102, 102, 0.55 + state.intensity * 0.35);
    }
    ctx.save();
    ctx.translate(guardian.x, y);
    if (guardian.direction < 0) ctx.scale(-1, 1);
    ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, -crop.w * scale / 2, -crop.h * scale / 2, crop.w * scale, crop.h * scale);
    ctx.restore();
  }

  function drawFox(state) {
    if (state.intensity < 0.28) return;
    const frames = Array.from({ length: 8 }, (_, index) => art.fox.frames.get(`fox_chase_${index + 1}`));
    const frame = frames[Math.floor(state.time * (9 + state.intensity * 7)) % frames.length];
    const crop = frame.content || frame.source;
    const scale = 58 / Math.max(...frames.map((item) => (item.content || item.source).h));
    const wave = Math.sin(state.time * (1.1 + state.intensity));
    const x = 50 + (wave + 1) * 0.5 * (WORLD_WIDTH - 100);
    const y = logicalHeight - 5;
    ctx.save();
    ctx.globalAlpha = Math.min(1, (state.intensity - 0.22) * 2.2);
    ctx.translate(x, y);
    if (Math.cos(state.time * (1.1 + state.intensity)) < 0) ctx.scale(-1, 1);
    ctx.drawImage(art.fox.image, crop.x, crop.y, crop.w, crop.h, -(frame.anchor.x - crop.x) * scale, -(frame.anchor.y - crop.y) * scale, crop.w * scale, crop.h * scale);
    ctx.restore();
  }

  function drawWeather(state, weather) {
    const sheet = art.weather[weather.sheet];
    const cycle = sheet.animations.get(weather.animation)
      || Array.from({ length: 8 }, (_, index) => sheet.frames.get(`${weather.animation}_${index + 1}`));
    const frame = cycle[weather.frame];
    const crop = frame.content || frame.source;
    const width = [7, 9].includes(weather.area) ? 150 : 122;
    const height = weather.area === 9 ? 118 : 96;
    const scale = Math.min(width / crop.w, height / crop.h);
    const y = screenY(state, weather.y);
    ctx.save();
    ctx.globalAlpha = weather.frame < 3 ? 0.58 : 0.9;
    ctx.translate(weather.x, y);
    if (weather.direction < 0) ctx.scale(-1, 1);
    ctx.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, -crop.w * scale / 2, -crop.h * scale / 2, crop.w * scale, crop.h * scale);
    ctx.restore();
  }

  function render(state) {
    state.viewHeight = logicalHeight;
    ctx.setTransform(Math.min(window.devicePixelRatio || 1, 2), 0, 0, Math.min(window.devicePixelRatio || 1, 2), 0, 0);
    ctx.clearRect(0, 0, cssWidth, cssHeight);
    const areaProgress = (state.height % METERS_PER_AREA) / METERS_PER_AREA;
    drawCover(ctx, art.backgrounds[state.areaIndex], cssWidth, cssHeight, areaProgress);
    if (state.areaIndex < AREAS.length - 1 && areaProgress > 0.78) {
      ctx.save();
      ctx.globalAlpha = (areaProgress - 0.78) / 0.22;
      drawCover(ctx, art.backgrounds[state.areaIndex + 1], cssWidth, cssHeight, 0);
      ctx.restore();
    }
    const wash = ctx.createLinearGradient(0, 0, 0, cssHeight);
    wash.addColorStop(0, "rgba(20,16,40,.08)");
    wash.addColorStop(1, "rgba(14,18,24,.22)");
    ctx.fillStyle = wash;
    ctx.fillRect(0, 0, cssWidth, cssHeight);

    const scale = cssWidth / WORLD_WIDTH;
    ctx.save();
    ctx.scale(scale, scale);
    if (state.shake > 0) ctx.translate((Math.random() - 0.5) * 7, (Math.random() - 0.5) * 5);

    if (state.best > 0 && state.best < AREAS.length * METERS_PER_AREA) {
      const bestArea = Math.min(AREAS.length - 1, Math.floor(state.best / METERS_PER_AREA));
      const bestStart = state.platforms[bestArea * PLATFORMS_PER_AREA].y;
      const bestEnd = state.platforms[Math.min(state.platforms.length - 1, (bestArea + 1) * PLATFORMS_PER_AREA)].y;
      const bestY = bestStart + ((state.best % METERS_PER_AREA) / METERS_PER_AREA) * (bestEnd - bestStart);
      const y = screenY(state, bestY);
      if (y > 30 && y < logicalHeight - 20) {
        ctx.setLineDash([7, 7]);
        ctx.strokeStyle = "rgba(255,246,176,.72)";
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(WORLD_WIDTH, y);
        ctx.stroke();
        ctx.setLineDash([]);
        ctx.fillStyle = "rgba(45,28,55,.86)";
        ctx.fillRect(8, y - 22, 80, 20);
        ctx.fillStyle = "#fff3bd";
        ctx.font = "700 12px Nunito";
        ctx.fillText(`REKOR ${state.best}m`, 14, y - 8);
      }
    }

    for (const landmark of state.landmarks) {
      const y = screenY(state, landmark.y);
      if (y < -150 || y > logicalHeight + 150) continue;
      drawFrameInCell(ctx, landmark.sheet ? art.realmLandmarks : art.landmarks, landmark.name, landmark.x, y - 115, landmark.width, 140, 0.92);
    }

    for (const platform of state.platforms) drawPlatform(state, platform);
    const finalPlatform = state.platforms[state.platforms.length - 1];
    const finishY = screenY(state, finalPlatform.y);
    if (finishY > -140 && finishY < logicalHeight + 100) drawFrameInCell(ctx, art.landmarks, "finish_beacon", finalPlatform.x + finalPlatform.width / 2 - 52, finishY - 114, 104, 116);
    for (const pickup of state.pickups) {
      if (pickup.collected) continue;
      const y = screenY(state, pickup.y + Math.sin(state.time * 3 + pickup.bob) * 5);
      if (y < -50 || y > logicalHeight + 40) continue;
      drawFrameInCell(ctx, art.objects, pickup.type, pickup.x - 16, y - 18, 32, 36);
    }
    for (const weather of state.weather) {
      const y = screenY(state, weather.y);
      if (y < -100 || y > logicalHeight + 100) continue;
      drawWeather(state, weather);
    }
    for (const guardian of state.guardians) {
      if (!guardian.active) continue;
      const y = screenY(state, guardian.y);
      if (y < -80 || y > logicalHeight + 80) continue;
      if (!guardian.reward) {
        ctx.save();
        ctx.setLineDash([3, 8]);
        ctx.strokeStyle = "rgba(255,235,173,.38)";
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(20, y);
        ctx.lineTo(WORLD_WIDTH - 20, y);
        ctx.stroke();
        ctx.restore();
      }
      drawGuardian(state, guardian);
    }
    for (const enemy of state.enemies) {
      if (!enemy.active) continue;
      const y = screenY(state, enemy.y);
      if (y < -60 || y > logicalHeight + 60) continue;
      drawFrameInCell(ctx, art.objects, enemy.type, enemy.x - 25, y - 24, 50, 48);
    }
    if (state.areaIndex === 6) {
      const phase = state.time % 4;
      if (phase > 1.25 && phase < 2.72) {
        const frameIndex = Math.min(5, Math.floor(((phase - 1.25) / 1.47) * 6));
        const alpha = phase > 2.35 ? 1 : 0.55;
        for (let y = 40; y < logicalHeight; y += 92) drawAnimationInCell(ctx, art.effects, "storm_warning", frameIndex, state.storm.x - 34, y - 42, 68, 84, alpha);
      }
    }
    for (const particle of state.particles) {
      const y = screenY(state, particle.y);
      ctx.globalAlpha = Math.max(0, particle.life / 0.55);
      ctx.fillStyle = particle.color;
      ctx.beginPath();
      ctx.arc(particle.x, y, 2.4, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
    if (state.comboFx.time > 0) {
      const progress = 1 - state.comboFx.time / 0.8;
      drawAnimationInCell(ctx, art.crescendo, "carrot_combo_burst", Math.min(7, Math.floor(progress * 8)), state.comboFx.x - 55, screenY(state, state.comboFx.y) - 55, 110, 110);
    }
    if (state.skillFx.time > 0) {
      const progress = 1 - state.skillFx.time / 0.78;
      drawAnimationInCell(ctx, art.skillEffects[state.skillFx.sheet], state.skillFx.effect, Math.min(5, Math.floor(progress * 6)), state.skillFx.x - 59, screenY(state, state.skillFx.y) - 59, 118, 118, 0.96);
    }
    if (state.areaIndex === AREAS.length - 1 && state.stageIndex >= 4) {
      const starFrame = Math.floor(state.time * 8) % 8;
      drawAnimationInCell(ctx, art.crescendo, "summit_star_explosion", starFrame, 18, 55, 120, 120, 0.85);
      drawAnimationInCell(ctx, art.crescendo, "summit_star_explosion", (starFrame + 4) % 8, WORLD_WIDTH - 138, logicalHeight * 0.35, 120, 120, 0.8);
    }
    drawPlayer(state);

    const dangerY = logicalHeight - 26;
    const danger = ctx.createLinearGradient(0, dangerY - 55, 0, logicalHeight);
    danger.addColorStop(0, "rgba(98,42,48,0)");
    danger.addColorStop(1, state.areaIndex < 6 ? `rgba(173,92,46,${0.35 + state.intensity * 0.55})` : `rgba(92,28,112,${0.45 + state.intensity * 0.5})`);
    ctx.fillStyle = danger;
    ctx.fillRect(0, dangerY - 55, WORLD_WIDTH, 82);
    drawFox(state);
    ctx.restore();

    if (state.flash > 0) {
      ctx.fillStyle = `rgba(226,242,255,${state.flash})`;
      ctx.fillRect(0, 0, cssWidth, cssHeight);
    }
  }

  function drawSkinPreview(previewCanvas, skin) {
    const preview = previewCanvas.getContext("2d");
    const rect = previewCanvas.getBoundingClientRect();
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    previewCanvas.width = Math.max(1, Math.round(rect.width * dpr));
    previewCanvas.height = Math.max(1, Math.round(rect.height * dpr));
    preview.setTransform(dpr, 0, 0, dpr, 0, 0);
    preview.clearRect(0, 0, rect.width, rect.height);
    const sheet = art.rabbitSkins.get(skin.id);
    const frame = sheet.frames.get(`${skin.animation}_1`);
    const crop = frame.content || frame.source;
    const scale = Math.min(rect.width / crop.w, rect.height / crop.h) * 0.95;
    preview.drawImage(sheet.image, crop.x, crop.y, crop.w, crop.h, (rect.width - crop.w * scale) / 2, rect.height - crop.h * scale, crop.w * scale, crop.h * scale);
  }

  return { render, drawSkinPreview, destroy: () => observer.disconnect() };
}
