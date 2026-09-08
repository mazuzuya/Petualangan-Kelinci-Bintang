export function createInput(root) {
  const held = { left: false, right: false, jump: false };
  let jumpPressed = false;
  let jumpReleased = false;

  const setKey = (key, down) => {
    if (["ArrowLeft", "KeyA"].includes(key)) held.left = down;
    if (["ArrowRight", "KeyD"].includes(key)) held.right = down;
    if (["Space", "ArrowUp", "KeyW"].includes(key)) {
      if (down && !held.jump) jumpPressed = true;
      if (!down && held.jump) jumpReleased = true;
      held.jump = down;
    }
  };

  const onKeyDown = (event) => {
    if (["ArrowLeft", "ArrowRight", "ArrowUp", "Space"].includes(event.code)) event.preventDefault();
    setKey(event.code, true);
  };
  const onKeyUp = (event) => setKey(event.code, false);
  window.addEventListener("keydown", onKeyDown);
  window.addEventListener("keyup", onKeyUp);

  const bindings = [];
  for (const button of root.querySelectorAll("[data-control]")) {
    const control = button.dataset.control;
    const down = (event) => {
      event.preventDefault();
      button.setPointerCapture?.(event.pointerId);
      if (control === "jump" && !held.jump) jumpPressed = true;
      held[control] = true;
      button.classList.add("is-held");
    };
    const up = (event) => {
      event.preventDefault();
      if (control === "jump" && held.jump) jumpReleased = true;
      held[control] = false;
      button.classList.remove("is-held");
    };
    button.addEventListener("pointerdown", down);
    button.addEventListener("pointerup", up);
    button.addEventListener("pointercancel", up);
    bindings.push(() => {
      button.removeEventListener("pointerdown", down);
      button.removeEventListener("pointerup", up);
      button.removeEventListener("pointercancel", up);
    });
  }

  return {
    held,
    consumeJumpPressed() {
      const value = jumpPressed;
      jumpPressed = false;
      return value;
    },
    consumeJumpReleased() {
      const value = jumpReleased;
      jumpReleased = false;
      return value;
    },
    destroy() {
      window.removeEventListener("keydown", onKeyDown);
      window.removeEventListener("keyup", onKeyUp);
      bindings.forEach((unbind) => unbind());
    },
  };
}
