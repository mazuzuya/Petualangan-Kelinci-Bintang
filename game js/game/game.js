import { createAudio } from "./audio.js";
import { loadGameAssets } from "./assets.js";
import { createInput } from "./input.js";
import { createRenderer } from "./renderer.js";
import { SKINS } from "./config.js";
import { createUI } from "./ui.js";
import { createWorld } from "./world.js";

function validSave(value) {
  const skin = SKINS.some((entry) => entry.id === value?.skin) ? value.skin : "ranger";
  const best = Number.isFinite(value?.best) ? Math.max(0, Math.round(value.best)) : 0;
  return { version: 1, skin, best };
}

export function createGame({ mount, sdk, tweaks, assets }) {
  let cleanup = () => {};

  return {
    start() {
      const ui = createUI(mount);
      const audio = createAudio(sdk);
      let renderer;
      let input;
      let frame = 0;
      let stopped = false;
      let world;
      let selectedSkin = "ranger";
      let best = 0;
      let lastTime = performance.now();
      const balance = {
        moveSpeed: Number(tweaks.get("moveSpeed")),
        jumpVelocity: Number(tweaks.get("jumpVelocity")),
        coyoteTime: Number(tweaks.get("coyoteTime")),
        effectsIntensity: Number(tweaks.get("effectsIntensity")),
      };
      const unsubscribers = Object.keys(balance).map((key) => tweaks.subscribe(key, (value) => { balance[key] = Number(value); }));

      const save = () => {
        best = Math.max(best, world?.state.best || 0);
        void sdk.gameState.save({ version: 1, skin: selectedSkin, best }).catch(() => {});
      };

      const makeRun = () => {
        world = createWorld({ skinId: selectedSkin, balance, best });
        ui.selectedSkin(selectedSkin);
        ui.hideResult();
        ui.update(world.state);
      };

      const finishRun = (won = false) => {
        best = Math.max(best, world.state.height);
        world.state.best = best;
        ui.showResult(world.state);
        save();
        const score = Math.max(0, Math.min(Number.MAX_SAFE_INTEGER, world.state.height));
        void sdk.leaderboard.submit(score).catch(() => {});
        if (sdk.device.haptics.isSupported()) void sdk.device.haptics.vibrate(won ? [40, 45, 80] : 70).catch(() => {});
      };

      const handleEvents = (events) => {
        for (const event of events) {
          if (event === "jump" || event === "super") audio.jump();
          if (event === "land") audio.land();
          if (event === "pickup") audio.pickup(world.state.combo);
          if (event === "combo") audio.area();
          if (event === "skill") audio.area();
          if (event === "checkpoint") audio.area();
          if (event === "hit") audio.hit();
          if (event === "area") {
            audio.area();
            if (sdk.device.haptics.isSupported()) void sdk.device.haptics.vibrate(35).catch(() => {});
          }
          if (event === "gameover") finishRun(false);
          if (event === "won") finishRun(true);
        }
      };

      const tick = (now) => {
        if (stopped) return;
        const dt = Math.min(0.033, Math.max(0.001, (now - lastTime) / 1000));
        lastTime = now;
        if (world && input) {
          handleEvents(world.update(dt, input));
          ui.update(world.state);
          renderer.render(world.state);
        }
        frame = requestAnimationFrame(tick);
      };

      const boot = async () => {
        try {
          const [art, savedRaw] = await Promise.all([
            loadGameAssets(assets),
            sdk.gameState.load().catch(() => null),
          ]);
          if (stopped) return;
          const saved = validSave(savedRaw);
          selectedSkin = saved.skin;
          best = saved.best;
          renderer = createRenderer(ui.refs.canvas, art);
          input = createInput(ui.refs.shell);
          ui.onChooseSkin((skin) => {
            selectedSkin = skin.id;
            makeRun();
            ui.closeSkins();
            save();
          });
          ui.onRetry(() => makeRun());
          for (const button of ui.refs.skinGrid.querySelectorAll(".skin-option")) {
            const skin = SKINS.find((entry) => entry.id === button.dataset.skin);
            renderer.drawSkinPreview(button.querySelector("canvas"), skin);
          }
          const unlock = () => audio.unlock();
          ui.refs.shell.addEventListener("pointerdown", unlock, { once: true, capture: true });
          ui.refs.shell.addEventListener("keydown", unlock, { once: true, capture: true });
          makeRun();
          ui.ready();
          frame = requestAnimationFrame(tick);
        } catch (error) {
          ui.refs.loading.innerHTML = `<strong>Jalur belum siap</strong><span>${error instanceof Error ? error.message : "Coba muat ulang permainan."}</span>`;
        }
      };
      void boot();

      cleanup = () => {
        stopped = true;
        cancelAnimationFrame(frame);
        unsubscribers.forEach((unsubscribe) => unsubscribe());
        input?.destroy();
        renderer?.destroy();
        audio.destroy();
        ui.destroy();
      };
    },
    destroy() {
      cleanup();
      cleanup = () => {};
    },
  };
}
