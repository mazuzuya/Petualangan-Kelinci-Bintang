import json
import os
import re

BASE_DIR = os.path.dirname(__file__)

with open(os.path.join(BASE_DIR, "link.json")) as f:
    link = json.load(f)

with open(os.path.join(BASE_DIR, "..", "game js", "assets.json")) as f:
    assets = json.load(f)

# These are the assets passed to loadSheet() in game/assets.js.
sheet_keys = {
    key for key in assets
    if key.startswith(("SKIN_", "MINION_", "BOSS_"))
}
sheet_keys.update({
    "OBJECT_ATLAS",
    "EFFECT_SHEET",
    "NEW_SKIN_PROJECTILES",
    "NEW_SKIN_ULTI_FORMS",
    "NEW_ULTI_EFFECTS_A",
    "NEW_ULTI_EFFECTS_B",
})

result = {}
for key in sorted(sheet_keys):
    if key not in link:
        print(f"WARNING: {key} tidak ada di link.json")
        continue
    webp_url = link[key]
    frames_url = re.sub(r"\.[^.]+$", ".frames.json", webp_url)
    result[key] = frames_url

with open(os.path.join(BASE_DIR, "link-json.json"), "w") as f:
    json.dump(result, f, indent=2)
    f.write("\n")

print(f"Total sheet keys: {len(sheet_keys)}")
print(f"Ditulis ke link-json.json: {len(result)} entri")
