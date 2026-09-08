export function createAudio(sdk) {
  let handle;
  let context;

  const unlock = async () => {
    if (!handle) handle = await sdk.audio.getContext();
    await handle.unlock();
    context = handle.context;
  };

  const tone = (frequency, duration = 0.07, type = "sine", volume = 0.08) => {
    if (!context || context.state !== "running") return;
    const oscillator = context.createOscillator();
    const gain = context.createGain();
    oscillator.type = type;
    oscillator.frequency.setValueAtTime(frequency, context.currentTime);
    gain.gain.setValueAtTime(volume, context.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, context.currentTime + duration);
    oscillator.connect(gain).connect(context.destination);
    oscillator.start();
    oscillator.stop(context.currentTime + duration);
  };

  return {
    unlock: () => void unlock().catch(() => {}),
    jump: () => tone(310, 0.1, "triangle", 0.1),
    land: () => tone(120, 0.06, "sine", 0.08),
    pickup: (streak = 0) => tone(650 * 1.04 ** streak, 0.09, "square", 0.055),
    hit: () => tone(85, 0.18, "sawtooth", 0.1),
    area: () => {
      tone(520, 0.14, "triangle", 0.06);
      setTimeout(() => tone(780, 0.18, "triangle", 0.05), 90);
    },
    destroy: () => void handle?.dispose().catch(() => {}),
  };
}
