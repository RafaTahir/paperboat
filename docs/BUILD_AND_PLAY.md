# Build and play

The production project is at the directory containing `project.godot`.
Godot **4.6.3.stable.official.7d41c59c4**, GDScript, Compatibility renderer.
Use the matching **4.6.3.stable** export templates. No runtime plugins or Blender import are required.

## Play and export

Open `project.godot` in Godot 4.6.3 and press F6 on `scenes/main.tscn`, or F5.
For browser export, from the project directory:

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . --export-release Web builds/web/index.html
node web/package.mjs
python -m http.server 8080 --bind 127.0.0.1 --directory dist
```

Create `builds/web` before exporting on a fresh checkout. Substitute your Godot/Python executable paths.
Open `http://127.0.0.1:8080/`. Opening the HTML directly as a local file is unsupported.

`builds/web` is the standard single-threaded Godot export, including `index.wasm`.
`dist` is the static hosting package. Its two engine parts reconstruct the exact official WASM bytes as an `application/wasm` Response in the versioned HTML shell; this keeps each hosted file below 25 MiB without modifying the engine. No service worker or isolation headers are required.
Publish the entire `dist` directory atomically, with HTTPS, no authentication gate and no HTML fallback for missing binary files.

## Controls

WASD/arrows or gamepad left stick guides relative to the camera.
Hold Space or the south face button for a breeze; release to coast.
Esc/P or gamepad Menu pauses. Pause includes music/effects levels, mute,
reduced camera motion, a lower render setting, open-water recovery and restart.
Begin or the explicit sound button unlocks browser audio. Keyboard play is complete.
F3 writes a compact developer state/frame-rate snapshot to the browser console.

## Rebuild original assets

All runtime GLBs and OGG files are committed. Rebuilding them is optional.

- Blender **5.2.3 LTS**: `blender --background --python art-source/build_assets.py`.
- Python 3, NumPy and soundfile: `python art-source/render_audio.py`.
- Details and source provenance: `ENVIRONMENT_NOTES.md`, `AUDIO_NOTES.md`, `asset_register.csv`, `LICENSES.md`.

## Focused checks

```powershell
godot --headless --fixed-fps 60 --path . --script art-source/check_game.gd
```

This is a simulation check. Actual web launch, browser controls, visuals and audio activation require the exported browser build. See `INTEGRATION_CHECKS.md` and `RELEASE_REPORT.md` for observed evidence and limits.
