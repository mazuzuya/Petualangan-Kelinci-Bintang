import { AREAS, SKINS } from "./config.js";

export function createUI(mount) {
  const shell = document.createElement("section");
  shell.className = "game-shell";
  shell.innerHTML = `
    <div class="playfield">
       <canvas class="game-surface" aria-label="Area permainan Petualangan Kelinci Bintang"></canvas>
      <div class="hud-row game-hud">
        <div class="badge height-badge"><span class="hud-icon">↟</span><strong data-height>0m</strong></div>
        <div class="badge area-badge"><span data-area>MEADOW</span><i><b></b></i></div>
        <div class="badge carrot-badge"><span class="carrot-mark"></span><strong data-carrots>0</strong></div>
        <button class="wardrobe-btn" type="button" aria-label="Pilih skin">◈</button>
      </div>
      <div class="status-pips" aria-label="Status"><span data-frenzy></span><span data-shield></span><span data-power></span></div>
      <div class="game-toast" data-toast>Tahan untuk lompat lebih tinggi</div>
      <div class="loading-panel"><div class="loader-ear"></div><strong>Menyiapkan jalur...</strong></div>
      <div class="skin-panel overlay" hidden>
        <div class="panel-head"><div><strong>Pilih Kelinci</strong><small>Setiap skin punya mekanik unik</small></div><button class="close-panel" type="button" aria-label="Tutup">×</button></div>
        <div class="skin-grid"></div>
      </div>
      <div class="result-panel overlay" hidden>
        <div class="result-card">
          <small data-result-kicker>PERJALANAN BERAKHIR</small>
          <strong data-result-title>0m</strong>
          <span data-result-detail></span>
          <button class="retry-btn control-btn" type="button"><span class="control-label">Lompat Lagi</span></button>
        </div>
      </div>
    </div>
    <div class="controls-row climb-controls">
      <button class="control-btn direction-btn" data-control="left" type="button" aria-label="Gerak kiri"><span>◀</span></button>
      <button class="control-btn jump-btn" data-control="jump" type="button"><span class="control-label">TAHAN<br>LOMPAT</span></button>
      <button class="control-btn direction-btn" data-control="right" type="button" aria-label="Gerak kanan"><span>▶</span></button>
    </div>`;
  mount.replaceChildren(shell);

  const refs = {
    shell,
    canvas: shell.querySelector("canvas"),
    loading: shell.querySelector(".loading-panel"),
    height: shell.querySelector("[data-height]"),
    carrots: shell.querySelector("[data-carrots]"),
    area: shell.querySelector("[data-area]"),
    areaDot: shell.querySelector(".area-badge i"),
    areaProgress: shell.querySelector(".area-badge i b"),
    shield: shell.querySelector("[data-shield]"),
    frenzy: shell.querySelector("[data-frenzy]"),
    power: shell.querySelector("[data-power]"),
    toast: shell.querySelector("[data-toast]"),
    skinPanel: shell.querySelector(".skin-panel"),
    skinGrid: shell.querySelector(".skin-grid"),
    resultPanel: shell.querySelector(".result-panel"),
    resultKicker: shell.querySelector("[data-result-kicker]"),
    resultTitle: shell.querySelector("[data-result-title]"),
    resultDetail: shell.querySelector("[data-result-detail]"),
  };

  let chooseSkin = () => {};
  let retry = () => {};
  for (const skin of SKINS) {
    const button = document.createElement("button");
    button.className = "skin-option";
    button.type = "button";
    button.dataset.skin = skin.id;
    button.innerHTML = `<canvas class="skin-preview"></canvas><span><strong>${skin.name}</strong><small>${skin.skill}</small></span>`;
    button.addEventListener("click", () => chooseSkin(skin));
    refs.skinGrid.append(button);
  }
  const openSkins = () => { refs.skinPanel.hidden = false; };
  const closeSkins = () => { refs.skinPanel.hidden = true; };
  shell.querySelector(".wardrobe-btn").addEventListener("click", openSkins);
  shell.querySelector(".close-panel").addEventListener("click", closeSkins);
  shell.querySelector(".retry-btn").addEventListener("click", () => retry());

  return {
    refs,
    ready() { refs.loading.hidden = true; },
    onChooseSkin(callback) { chooseSkin = callback; },
    onRetry(callback) { retry = callback; },
    closeSkins,
    selectedSkin(id) {
      refs.skinGrid.querySelectorAll(".skin-option").forEach((button) => button.classList.toggle("is-selected", button.dataset.skin === id));
    },
    update(state) {
      refs.height.textContent = `${state.height}m`;
      refs.carrots.textContent = state.carrots;
      refs.area.textContent = `${AREAS[state.areaIndex].short} · ${state.stageIndex + 1}/5`;
      refs.areaDot.style.borderColor = AREAS[state.areaIndex].tint;
      refs.areaDot.style.color = AREAS[state.areaIndex].tint;
      refs.areaProgress.style.width = `${state.height % 1000 / 10}%`;
      refs.shield.textContent = state.player.shield > 1 ? `PERISAI ×${state.player.shield}` : state.player.shield ? "PERISAI" : "";
      refs.frenzy.textContent = state.intensity < 0.2 ? "TENANG" : state.intensity < 0.45 ? "MULAI RAMAI" : state.intensity < 0.72 ? "HEBOH" : "KOSMIK!";
      refs.frenzy.style.setProperty("--frenzy", state.intensity);
      refs.frenzy.style.background = `rgba(${Math.round(38 + state.intensity * 110)}, ${Math.round(52 - state.intensity * 18)}, ${Math.round(72 + state.intensity * 15)}, .88)`;
      refs.power.textContent = state.player.balloon > 0 ? `BALON ${Math.ceil(state.player.balloon)}s` : state.player.magnet > 0 ? `MAGNET ${Math.ceil(state.player.magnet)}s` : state.player.rangerBoost ? "LOMPAT 1,5×" : "";
      refs.toast.textContent = state.message;
      refs.toast.classList.toggle("is-visible", state.messageTime > 0);
    },
    showResult(state) {
      refs.resultPanel.hidden = false;
      refs.resultKicker.textContent = state.phase === "won" ? "PUNCAK TERCAPAI" : "KETINGGIAN LOMPATAN";
      refs.resultTitle.textContent = `${state.height}m`;
      refs.resultDetail.textContent = `Rekor ${state.best}m · ${state.carrots} wortel`;
    },
    hideResult() { refs.resultPanel.hidden = true; },
    destroy() { mount.replaceChildren(); },
  };
}
