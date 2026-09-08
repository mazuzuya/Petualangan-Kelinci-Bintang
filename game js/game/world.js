import { AREA_ENCOUNTERS, AREAS, LANDMARKS, METERS_PER_AREA, PLATFORM_COUNT, PLATFORMS_PER_AREA, SKINS, SUB_AREAS, WEATHER_EVENTS, WORLD_WIDTH } from "./config.js";

const START_Y = 64;
const GRAVITY = 1180;

function seeded(index) {
  const value = Math.sin(index * 91.73 + 17.2) * 43758.5453;
  return value - Math.floor(value);
}

function makePlatforms() {
  const platforms = [];
  let y = START_Y;
  let center = WORLD_WIDTH / 2;
  for (let i = 0; i < PLATFORM_COUNT; i += 1) {
    const area = Math.min(AREAS.length - 1, Math.floor(i / PLATFORMS_PER_AREA));
    const local = i % PLATFORMS_PER_AREA;
    const stage = Math.min(4, Math.floor(local / 10));
    const width = i === 0 ? 170 : Math.max(72, 132 - area * 3.2 - stage * 5 - seeded(i + 4) * 18);
    if (i > 0) {
      y += 76 + Math.min(area, 8) * 1.8 + seeded(i) * 16;
      const direction = seeded(i + 2) > 0.5 ? 1 : -1;
      center += direction * (42 + seeded(i + 8) * 44);
      center = Math.max(width / 2 + 14, Math.min(WORLD_WIDTH - width / 2 - 14, center));
    }
    let kind = "normal";
    if (i > 2 && [10, 30].includes(local)) kind = "mushroom";
    else if (stage > 0 && area === 1 && local % 3 === 1) kind = "falling";
    else if (stage > 0 && area === 6 && local % 3 === 0) kind = "falling";
    else if (stage > 0 && area === 7 && local % 4 === 2) kind = "portal";
    else if (stage > 0 && area === 9 && local % 2 === 1) kind = "falling";
    else if (stage > 0 && [12, 13, 16, 19].includes(area) && local % 3 === 1) kind = "falling";
    else if (stage > 0 && area === 18 && local % 4 === 2) kind = "portal";
    const moving = stage > 0 && ((area >= 1 && local % 4 === 2) || (area >= 7 && local % 3 === 0) || (area === 11 && local % 2 === 0));
    platforms.push({
      id: i,
      area,
      x: center - width / 2,
      baseX: center - width / 2,
      y,
      width,
      kind,
      visualVariant: local % 5,
      stage,
      moving,
      moveRange: 28 + Math.min(area, 10) * 3,
      moveSpeed: 0.7 + seeded(i + 5) * 0.8,
      phase: seeded(i + 7) * Math.PI * 2,
      fallTimer: -1,
      fallen: false,
      thorn: stage > 1 && area > 0 && local % 6 === 5,
      checkpoint: i > 0 && local % 10 === 9,
      checkpointClaimed: false,
      effectTime: 0,
      effectKind: "",
    });
  }
  return platforms;
}

function makePickups(platforms) {
  return platforms.flatMap((platform, index) => {
    if (index === 0 || index % 2 === 0) return [];
    const special = index % 17 === 0 ? "balloon" : index % 13 === 0 ? "flower_shield" : index % 19 === 0 ? "flying_carrot" : "carrot";
    const pickups = [{
      id: `pickup-${index}`,
      type: special,
      x: platform.baseX + platform.width * (0.3 + seeded(index + 12) * 0.4),
      y: platform.y + 40,
      collected: false,
      bob: seeded(index + 20) * Math.PI * 2,
    }];
    if (platform.stage === 2 && index % 4 === 1) pickups.push({ id: `bonus-${index}`, type: "carrot", x: platform.baseX + platform.width * 0.84, y: platform.y + 68, collected: false, bob: seeded(index + 70) * Math.PI * 2 });
    return pickups;
  });
}

function makeEnemies(platforms) {
  return platforms.flatMap((platform, index) => {
    const area = platform.area;
    if (index < 20 || platform.stage === 0 || index % 4 !== 3 || ![1, 4, 5, 7, 9].includes(area)) return [];
    const type = area === 1 ? "owl" : area === 4 ? "bee_swarm" : area === 5 ? "icicle" : area === 7 ? "ancient_orb" : "satellite";
    return [{
      id: `enemy-${index}`,
      type,
      x: seeded(index + 30) * WORLD_WIDTH,
      baseY: platform.y + 78,
      y: platform.y + 78,
      direction: seeded(index + 31) > 0.5 ? 1 : -1,
      speed: type === "icicle" ? 0 : 45 + area * 6,
      active: true,
      phase: seeded(index + 32) * Math.PI * 2,
    }];
  });
}

function makeGuardians(platforms) {
  return AREAS.flatMap((_, area) => [17, 38].map((local, encounterIndex) => {
    const platform = platforms[area * PLATFORMS_PER_AREA + local];
    const encounter = AREA_ENCOUNTERS[area];
    return {
      id: `guardian-${area}-${encounterIndex}`,
      area,
      animation: encounter.animation,
      sheet: encounter.sheet,
      reward: Boolean(encounter.reward),
      x: encounterIndex === 0 ? 72 : WORLD_WIDTH - 72,
      baseY: platform.y + 76,
      y: platform.y + 76,
      direction: encounterIndex === 0 ? 1 : -1,
      speed: 32 + area * 4,
      phase: encounterIndex * Math.PI + area * 0.7,
      active: true,
      hitCooldown: 0,
    };
  }));
}

function makeWeather(platforms) {
  return AREAS.flatMap((_, area) => [9, 29, 46].map((local, eventIndex) => {
    const platform = platforms[area * PLATFORMS_PER_AREA + local];
    const event = WEATHER_EVENTS[area];
    return {
      id: `weather-${area}-${eventIndex}`,
      area,
      animation: event.animation,
      sheet: event.sheet,
      harmful: Boolean(event.harmful),
      force: event.force || "",
      direction: event.force === "alternate" && eventIndex % 2 ? -1 : 1,
      x: 62 + seeded(area * 30 + eventIndex + 900) * (WORLD_WIDTH - 124),
      y: platform.y + 70,
      phase: eventIndex * 1.5 + area * 0.37,
      eventIndex,
      frame: 0,
      hitCycle: -1,
    };
  }));
}

function areaForY(platforms, y) {
  let area = 0;
  for (let index = 1; index < AREAS.length; index += 1) {
    if (y >= platforms[index * PLATFORMS_PER_AREA].y) area = index;
  }
  return area;
}

function metersForY(platforms, y) {
  const area = areaForY(platforms, y);
  const start = platforms[area * PLATFORMS_PER_AREA].y;
  const nextIndex = Math.min(platforms.length - 1, (area + 1) * PLATFORMS_PER_AREA);
  const end = platforms[nextIndex].y;
  const progress = Math.max(0, Math.min(1, (y - start) / Math.max(1, end - start)));
  return Math.round(area * METERS_PER_AREA + progress * METERS_PER_AREA);
}

function overlap(a, b) {
  return a.x + a.w > b.x && a.x < b.x + b.w && a.y + a.h > b.y && a.y < b.y + b.h;
}

function skinById(id) {
  return SKINS.find((skin) => skin.id === id) || SKINS[0];
}

export function createWorld({ skinId, balance, best = 0 }) {
  const platforms = makePlatforms();
  const start = platforms[0];
  const skin = skinById(skinId);
  const state = {
    phase: "ready",
    time: 0,
    cameraY: 0,
    viewHeight: 620,
    areaIndex: 0,
    stageIndex: 0,
    previousArea: 0,
    height: 0,
    best,
    carrots: 0,
    combo: 0,
    message: "Tahan untuk lompat lebih tinggi",
    messageTime: 4,
    shake: 0,
    flash: 0,
    intensity: 0,
    comboFx: { time: 0, x: 0, y: 0 },
    skillFx: { time: 0, x: 0, y: 0, effect: "", sheet: 0 },
    platforms,
    pickups: makePickups(platforms),
    enemies: makeEnemies(platforms),
    guardians: makeGuardians(platforms),
    weather: makeWeather(platforms),
    landmarks: AREAS.map((_, area) => {
      const platform = platforms[area * PLATFORMS_PER_AREA + 25];
      return { name: LANDMARKS[area], sheet: area >= 10 ? 1 : 0, area, x: area % 2 === 0 ? -18 : WORLD_WIDTH - 100, y: platform.y + 42, width: 118 };
    }),
    storm: { x: 90, cycle: -1, struck: false },
    particles: [],
    player: {
      x: start.x + start.width / 2,
      y: start.y,
      previousY: start.y,
      vx: 0,
      vy: 0,
      w: 34,
      h: 53,
      facing: 1,
      grounded: true,
      coyote: balance.coyoteTime,
      jumpHold: 0,
      airTime: 0,
      wallCooldown: 0,
      skin,
      lastPlatform: start,
      shield: skin.id === "knight" ? 1 : 0,
      magnet: 0,
      balloon: 0,
      invulnerable: 0,
      cyberCooldown: 0,
      dragonCooldown: 0,
      skinCounter: 0,
      rangerSteps: 0,
      rangerBoost: false,
      revived: false,
      checkpointPlatform: start,
      checkpointRescues: 0,
    },
  };

  function burst(x, y, color, count = 8) {
    const amount = Math.round(count * balance.effectsIntensity);
    for (let i = 0; i < amount; i += 1) {
      const angle = (Math.PI * 2 * i) / Math.max(1, amount) + seeded(i + state.time) * 0.4;
      state.particles.push({ x, y, vx: Math.cos(angle) * (30 + seeded(i) * 70), vy: Math.sin(angle) * 55 + 35, life: 0.55, color });
    }
  }

  function announce(text, duration = 1.6) {
    state.message = text;
    state.messageTime = duration;
  }

  function activateSkill(text, events, x = state.player.x, y = state.player.y + 24) {
    const { skin } = state.player;
    if (skin.effect) state.skillFx = { time: 0.78, x, y, effect: skin.effect, sheet: skin.effectSheet };
    announce(text, 1.4);
    events.push("skill");
  }

  function jump(multiplier = 1, horizontal = 0) {
    const player = state.player;
    if (player.skin.id === "moon" && state.areaIndex >= 8) multiplier *= 1.18;
    player.vy = balance.jumpVelocity * multiplier;
    if (horizontal) player.vx = horizontal;
    player.grounded = false;
    player.coyote = 0;
    player.jumpHold = 0;
    player.airTime = 0;
    burst(player.x, player.y + 2, "#d7f49d", 7);
    return "jump";
  }

  function takeHit(events) {
    const player = state.player;
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
      announce("Awas! Terus naik!");
      events.push("hit");
    }
  }

  function fail(events) {
    const player = state.player;
    if (player.skin.id === "pajama" && !player.revived) {
      player.revived = true;
      player.x = player.lastPlatform.x + player.lastPlatform.width / 2;
      player.y = player.lastPlatform.y + 8;
      player.vx = 0;
      player.vy = 270;
      state.cameraY = Math.max(0, player.y - state.viewHeight * 0.35);
      announce("Dream Catcher! Bangkit lagi", 2.2);
      burst(player.x, player.y, "#d6b4ff", 24);
      events.push("revive");
      return;
    }
    if (player.checkpointRescues > 0) {
      player.checkpointRescues -= 1;
      player.x = player.checkpointPlatform.x + player.checkpointPlatform.width / 2;
      player.y = player.checkpointPlatform.y + 8;
      player.vx = 0;
      player.vy = 250;
      state.cameraY = Math.max(0, player.y - state.viewHeight * 0.35);
      announce("Checkpoint menyelamatkanmu", 2);
      burst(player.x, player.y, "#ffe181", 20);
      events.push("revive");
      return;
    }
    state.phase = "gameover";
    state.best = Math.max(state.best, state.height);
    events.push("gameover");
  }

  function collectPickup(pickup, events) {
    const player = state.player;
    pickup.collected = true;
    if (pickup.type === "carrot") {
      const value = player.skin.id === "farmer" ? 2 : 1;
      state.carrots += value;
      state.combo = Math.min(12, state.combo + 1);
      player.skinCounter += 1;
      if (player.skin.id === "alchemist" && player.skinCounter % 8 === 0) {
        player.shield += 1;
        activateSkill("Ramuan bunga: +1 perisai", events, pickup.x, pickup.y);
      }
      if (player.skin.id === "pirate" && player.skinCounter % 5 === 0) {
        state.carrots += 2;
        activateSkill("Harta kompas: +2 wortel", events, pickup.x, pickup.y);
      }
      if (player.skin.id === "rainbow" && player.skinCounter % 3 === 0) {
        for (const enemy of state.enemies) if (enemy.active && Math.abs(enemy.y - pickup.y) < 230) enemy.active = false;
        for (const guardian of state.guardians) if (guardian.active && !guardian.reward && Math.abs(guardian.y - pickup.y) < 180) guardian.hitCooldown = 3;
        activateSkill("PRISM BURST!", events, pickup.x, pickup.y);
      }
      if (state.combo % 5 === 0) {
        state.comboFx = { time: 0.8, x: pickup.x, y: pickup.y };
        events.push("combo");
      }
      announce(value === 2 ? "+2 panen emas" : "+1 wortel", 0.7);
    } else if (pickup.type === "flower_shield") {
      player.shield = 1;
      announce("Perisai bunga siap", 1.3);
    } else if (pickup.type === "flying_carrot") {
      player.magnet = player.skin.id === "chef" ? 8 : 6;
      announce("Magnet wortel!", 1.3);
    } else if (pickup.type === "balloon") {
      player.balloon = player.skin.id === "chef" ? 7 : 5;
      announce("Balon naik!", 1.3);
    }
    burst(pickup.x, pickup.y, "#ffc64f", 13);
    events.push("pickup");
  }

  function landOn(platform, events) {
    const player = state.player;
    player.y = platform.y;
    player.vy = 0;
    player.grounded = true;
    player.airTime = 0;
    player.coyote = balance.coyoteTime;
    player.lastPlatform = platform;
    state.combo = Math.min(12, state.combo + 1);
    if (platform.kind === "falling" && platform.fallTimer < 0) platform.fallTimer = [9, 19].includes(platform.area) ? 0.42 : Math.max(0.48, 1.2 - state.intensity * 0.65);
    if (platform.kind === "falling") {
      platform.effectTime = 0.9;
      platform.effectKind = "leaf_crumble";
    }

    const centered = Math.abs(player.x - (platform.x + platform.width / 2)) < platform.width * 0.2;
    if (player.skin.id === "dj" && centered) {
      let cleared = 0;
      for (const enemy of state.enemies) {
        if (enemy.active && Math.abs(enemy.y - platform.y) < 190) {
          enemy.active = false;
          cleared += 1;
          burst(enemy.x, enemy.y, "#ee7ee7", 12);
        }
      }
      if (cleared) announce(`Beat Drop! ${cleared} musuh pergi`, 1.4);
    }
    if (player.skin.id === "ranger") {
      player.rangerSteps += 1;
      if (player.rangerSteps >= 5) {
        player.rangerSteps = 0;
        player.rangerBoost = true;
        announce("Sinyal Morse: lompat 1,5×", 1.6);
      }
    }
    burst(player.x, platform.y + 2, AREAS[platform.area].tint, 9);
    events.push("land");

    if (platform.checkpoint && !platform.checkpointClaimed) {
      platform.checkpointClaimed = true;
      player.shield = Math.max(player.shield, player.skin.id === "miner" ? 2 : 1);
      player.checkpointPlatform = platform;
      player.checkpointRescues = 1;
      state.carrots += 2;
      const checkpointPart = Math.floor((platform.id % PLATFORMS_PER_AREA) / 10) + 1;
      announce(`Pos ${platform.area + 1}.${checkpointPart} · perisai pulih`, 2.1);
      events.push("checkpoint");
      if (["miner", "monk", "timekeeper"].includes(player.skin.id)) activateSkill(player.skin.id === "miner" ? "Benteng kristal: 2 perisai" : player.skin.id === "monk" ? "Mandala awan aktif" : "Waktu melambat", events);
    }

    if (platform.kind === "mushroom" && events.jumpHeld) {
      player.vy = balance.jumpVelocity * 1.45;
      player.grounded = false;
      announce("SUPER JUMP!", 1.1);
      platform.effectTime = 0.7;
      platform.effectKind = "mushroom_bounce";
      events.push("super");
    }

    if (platform.kind === "portal") {
      player.x = WORLD_WIDTH - player.x;
      player.vy = 120;
      player.grounded = false;
      announce("Portal memindahkanmu!", 1.2);
    }
  }

  function update(dt, input) {
    const events = [];
    events.jumpHeld = input.held.jump;
    const player = state.player;
    state.time += dt;
    state.messageTime = Math.max(0, state.messageTime - dt);
    state.shake = Math.max(0, state.shake - dt);
    state.flash = Math.max(0, state.flash - dt);
    state.comboFx.time = Math.max(0, state.comboFx.time - dt);
    state.skillFx.time = Math.max(0, state.skillFx.time - dt);
    player.invulnerable = Math.max(0, player.invulnerable - dt);
    player.wallCooldown = Math.max(0, player.wallCooldown - dt);
    player.cyberCooldown = Math.max(0, player.cyberCooldown - dt);
    player.dragonCooldown = Math.max(0, player.dragonCooldown - dt);
    player.magnet = Math.max(0, player.magnet - dt);
    player.balloon = Math.max(0, player.balloon - dt);

    for (const particle of state.particles) {
      particle.life -= dt;
      particle.x += particle.vx * dt;
      particle.y += particle.vy * dt;
      particle.vy -= 300 * dt;
    }
    state.particles = state.particles.filter((particle) => particle.life > 0);

    const skinTempo = player.skin.id === "timekeeper" ? 0.78 : 1;
    for (const platform of platforms) {
      if (platform.moving) platform.x = platform.baseX + Math.sin(state.time * skinTempo * platform.moveSpeed * (0.82 + state.intensity * 0.9) + platform.phase) * platform.moveRange * (0.86 + state.intensity * 0.28);
      if (platform.fallTimer >= 0) {
        platform.fallTimer -= dt;
        if (platform.fallTimer <= 0) platform.fallen = true;
      }
      if (platform.fallen) platform.y -= 190 * dt;
      platform.effectTime = Math.max(0, platform.effectTime - dt);
    }

    for (const enemy of state.enemies) {
      if (!enemy.active) continue;
      if (enemy.type === "icicle") {
        if (Math.abs(player.x - enemy.x) < 40 && player.y < enemy.y) enemy.y -= 250 * dt;
      } else {
        enemy.x += enemy.direction * enemy.speed * (0.82 + state.intensity * 0.75) * skinTempo * dt;
        if (enemy.x < -30) enemy.x = WORLD_WIDTH + 30;
        if (enemy.x > WORLD_WIDTH + 30) enemy.x = -30;
        enemy.y = enemy.baseY + Math.sin(state.time * 2 + enemy.phase) * 14;
      }
    }

    for (const guardian of state.guardians) {
      if (!guardian.active) continue;
      guardian.hitCooldown = Math.max(0, guardian.hitCooldown - dt);
      const tempo = (0.8 + state.intensity * 0.8) * skinTempo;
      if (guardian.area === 2) {
        guardian.x += guardian.direction * guardian.speed * tempo * dt;
        guardian.y = guardian.baseY + Math.abs(Math.sin(state.time * 1.8 + guardian.phase)) * 38;
      } else if (guardian.area === 5) {
        guardian.x += guardian.direction * guardian.speed * 1.45 * tempo * dt;
        guardian.y = guardian.baseY;
      } else if (guardian.area === 7) {
        guardian.x += guardian.direction * guardian.speed * 0.55 * tempo * dt;
        guardian.y = guardian.baseY + Math.sin(state.time * 1.2 + guardian.phase) * 9;
      } else {
        guardian.x += guardian.direction * guardian.speed * tempo * dt;
        guardian.y = guardian.baseY + Math.sin(state.time * 1.7 + guardian.phase) * 28;
      }
      if (guardian.x < 36) guardian.direction = 1;
      if (guardian.x > WORLD_WIDTH - 36) guardian.direction = -1;
    }
    for (const weather of state.weather) {
      const period = 6.2 - state.intensity * 2.5 - weather.eventIndex * 0.22;
      const weatherTime = state.time * skinTempo + weather.phase;
      weather.frame = Math.floor((weatherTime % period) / period * 8);
      weather.cycle = Math.floor(weatherTime / period);
    }

    if (state.phase === "ready") {
      if (input.consumeJumpPressed()) {
        state.phase = "playing";
        events.push(jump());
      }
      return events;
    }
    if (state.phase !== "playing") return events;

    const direction = (input.held.right ? 1 : 0) - (input.held.left ? 1 : 0);
    if (direction) player.facing = direction;
    const area = state.areaIndex;
    const acceleration = player.grounded ? 1150 : 760;
    const target = direction * balance.moveSpeed * (player.skin.id === "lava" ? 1.16 : 1);
    const grip = [2, 5, 12].includes(area) ? 3.2 : 8.5;
    player.vx += Math.max(-acceleration * dt, Math.min(acceleration * dt, target - player.vx));
    if (!direction && player.grounded) player.vx *= Math.max(0, 1 - grip * dt);

    const touchingLeft = player.x <= player.w / 2 + 1;
    const touchingRight = player.x >= WORLD_WIDTH - player.w / 2 - 1;
    const touchingWall = touchingLeft || touchingRight;
    const pressed = input.consumeJumpPressed();
    if (pressed) {
      if (player.grounded || player.coyote > 0) {
        const boost = player.rangerBoost ? 1.5 : 1;
        player.rangerBoost = false;
        events.push(jump(boost));
      } else if (touchingWall && player.wallCooldown <= 0) {
        player.wallCooldown = player.skin.id === "ninja" ? 0.05 : 0.24;
        events.push(jump(0.98, touchingLeft ? balance.moveSpeed : -balance.moveSpeed));
        announce("WALL JUMP", 0.65);
      } else if (player.skin.id === "cyber" && player.cyberCooldown <= 0) {
        player.cyberCooldown = 3;
        events.push(jump(0.9));
        announce("DOUBLE JUMP", 0.8);
      } else if (player.skin.id === "dragon" && player.dragonCooldown <= 0) {
        player.dragonCooldown = 3.5;
        events.push(jump(0.78, player.facing * balance.moveSpeed * 1.25));
        activateSkill("WING DASH!", events);
      }
    }

    if (input.consumeJumpReleased() && player.vy > 0) player.vy *= 0.55;
    if (input.held.jump && player.vy > 0 && player.jumpHold < 0.19) {
      player.vy += 760 * dt;
      player.jumpHold += dt;
    }

    let gravityScale = player.skin.id === "astro" || [8, 10, 15].includes(area) ? 0.8 : 1;
    if (player.skin.id === "moon" && area >= 8) gravityScale *= 0.72;
    if (player.skin.id === "wizard" && input.held.jump && player.vy < 0) gravityScale *= 0.28;
    if (player.balloon > 0) {
      gravityScale = 0.12;
      player.vy = Math.max(player.vy, 82);
    }
    if (area === 3) player.vx += Math.sin(state.time * 1.6) * 210 * dt;
    if (area === 17) player.vx += Math.sin(state.time * 2.2) * 125 * dt;
    for (const weather of state.weather) {
      if (weather.area !== area || weather.frame < 3 || weather.frame > 5) continue;
      if (Math.abs(player.y - weather.y) > 70 || Math.abs(player.x - weather.x) > 85) continue;
      if (weather.force === "up") player.vy += 210 * dt;
      else if (weather.force) player.vx += (weather.force === "left" ? -1 : weather.direction) * 180 * dt * (player.skin.id === "monk" ? 0.35 : 1);
    }
    if (player.skin.id === "ninja" && touchingWall && direction && player.vy < -40) player.vy = -40;

    player.previousY = player.y;
    if (!player.grounded) player.airTime += dt;
    player.vy -= GRAVITY * gravityScale * dt;
    player.x += player.vx * dt;
    player.y += player.vy * dt;
    player.x = Math.max(player.w / 2, Math.min(WORLD_WIDTH - player.w / 2, player.x));

    const wasGrounded = player.grounded;
    player.grounded = false;
    if (player.vy <= 0 && player.balloon <= 0) {
      for (const platform of platforms) {
        if (platform.fallen && platform.y < state.cameraY - 100) continue;
        const crossed = player.previousY >= platform.y && player.y <= platform.y;
        const horizontal = player.x + player.w * 0.34 > platform.x && player.x - player.w * 0.34 < platform.x + platform.width;
        if (crossed && horizontal) {
          if (platform.thorn && player.x > platform.x + platform.width * 0.62) {
            if (player.skin.id === "lava") activateSkill("Sepatu lava membakar duri", events);
            else takeHit(events);
          }
          landOn(platform, events);
          break;
        }
      }
    }
    if (!player.grounded) player.coyote = wasGrounded ? balance.coyoteTime : Math.max(0, player.coyote - dt);

    for (const pickup of state.pickups) {
      if (pickup.collected) continue;
      const distance = Math.hypot(player.x - pickup.x, player.y + 24 - pickup.y);
      if (player.magnet > 0 && pickup.type === "carrot" && distance < 125) {
        pickup.x += (player.x - pickup.x) * Math.min(1, dt * 7);
        pickup.y += (player.y + 24 - pickup.y) * Math.min(1, dt * 7);
      }
      if (distance < (player.skin.id === "pirate" ? 46 : 28)) collectPickup(pickup, events);
    }

    const playerBox = { x: player.x - 14, y: player.y + 5, w: 28, h: 44 };
    for (const enemy of state.enemies) {
      if (!enemy.active) continue;
      if (player.skin.id === "beekeeper" && enemy.type === "bee_swarm") continue;
      const size = enemy.type === "bee_swarm" ? 36 : 42;
      if (overlap(playerBox, { x: enemy.x - size / 2, y: enemy.y - size / 2, w: size, h: size })) takeHit(events);
    }

    for (const guardian of state.guardians) {
      if (!guardian.active || guardian.hitCooldown > 0) continue;
      if (!overlap(playerBox, { x: guardian.x - 30, y: guardian.y - 28, w: 60, h: 56 })) continue;
      if (player.skin.id === "beekeeper" && guardian.area === 4) {
        guardian.hitCooldown = 2;
        activateSkill("Lebah mengenali penjaganya", events);
        continue;
      }
      if (guardian.reward) {
        guardian.active = false;
        const reward = player.skin.id === "farmer" ? 6 : 3;
        state.carrots += reward;
        announce(`Tarian kupu-kupu · +${reward} wortel`, 1.5);
        burst(guardian.x, guardian.y, "#ffe77b", 22);
        events.push("pickup");
      } else {
        guardian.hitCooldown = 1.3;
        guardian.direction *= -1;
        takeHit(events);
      }
    }
    for (const weather of state.weather) {
      if (!weather.harmful || weather.frame < 3 || weather.frame > 5 || weather.hitCycle === weather.cycle) continue;
      if (!overlap(playerBox, { x: weather.x - 48, y: weather.y - 44, w: 96, h: 88 })) continue;
      if (player.skin.id === "beekeeper" && weather.area === 4) {
        weather.hitCycle = weather.cycle;
        activateSkill("Jubah madu menahan serbuk sari", events);
        continue;
      }
      weather.hitCycle = weather.cycle;
      takeHit(events);
    }

    if (state.areaIndex === 6) {
      const cycle = Math.floor(state.time / 4);
      const phase = state.time % 4;
      if (cycle !== state.storm.cycle) {
        state.storm.cycle = cycle;
        state.storm.x = 55 + seeded(cycle + 600) * (WORLD_WIDTH - 110);
        state.storm.struck = false;
      }
      if (phase > 2.35 && phase < 2.62 && !state.storm.struck && Math.abs(player.x - state.storm.x) < 34) {
        state.storm.struck = true;
        takeHit(events);
      }
    }

    state.height = Math.max(state.height, metersForY(platforms, player.y));
    const nextArea = Math.min(AREAS.length - 1, Math.floor(state.height / METERS_PER_AREA));
    const nextStage = Math.min(4, Math.floor(((state.height % METERS_PER_AREA) / METERS_PER_AREA) * 5));
    if (nextArea !== state.areaIndex) {
      state.previousArea = state.areaIndex;
      state.areaIndex = nextArea;
      state.stageIndex = 0;
      announce(`${AREAS[nextArea].name} · ${SUB_AREAS[nextArea][0]}`, 2.2);
      events.push("area");
      state.flash = nextArea === 6 ? 0.35 : 0;
      if (player.skin.id === "moon" && nextArea >= 8) activateSkill("Cahaya bulan memperkuat lompatan", events);
    } else if (nextStage !== state.stageIndex) {
      state.stageIndex = nextStage;
      announce(`${SUB_AREAS[state.areaIndex][nextStage]} · bagian ${nextStage + 1}/5`, 1.8);
      events.push("area");
    }
    state.intensity = Math.max(0, Math.min(1, state.height / (AREAS.length * METERS_PER_AREA) * 0.78 + state.stageIndex * 0.055));
    const targetCamera = Math.max(0, player.y - state.viewHeight * 0.5);
    if (targetCamera > state.cameraY) state.cameraY += (targetCamera - state.cameraY) * Math.min(1, dt * 4.5);
    if (player.y < state.cameraY - 45 + state.intensity * 50) fail(events);

    const finalPlatform = platforms[platforms.length - 1];
    if (player.y >= finalPlatform.y - 12) {
      state.height = AREAS.length * METERS_PER_AREA;
      state.best = Math.max(state.best, state.height);
      state.phase = "won";
      announce("PANDAI BINTANG TERCAPAI!", 99);
      events.push("won");
    }
    return events;
  }

  return { state, update, announce };
}
