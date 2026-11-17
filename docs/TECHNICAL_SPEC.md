# After the Rain — Technical Specification

Version 1.0 · 17 November 2026 · Implementation brief for Codex

This is the specification for the future game. Proposed values below are tuning seeds and budgets, not measured performance or completed implementation. Follow `GAME_DESIGN.md` for the experience and `MILESTONES_AND_ACCEPTANCE.md` for delivery gates.

## 1. Platform and project decisions

- Primary release: a public desktop-browser game with keyboard and gamepad controls, landscape layout. Document any physical gamepad that could not be tested.
- Engine: a suitable stable Godot 4 release with single-threaded web export; use GDScript and the Compatibility renderer from the first scene. Record the exact editor version and use its matching official export templates. Reuse a suitable installed version; do not change unrelated projects.
- Godot currently exports to WebGL 2.0; Forward+ and Mobile do not export to web. Godot 4 C# web export is also currently unavailable. See [Web export documentation][web].
- One self-contained scene, one courtyard, one water height, one controller. No backend is required for the experience.
- Keep the selected Codex model and user settings. These documents do not request a model switch.
- Use the current user-assigned project directory. The game will place `project.godot` at its root; this kit does not yet contain that file.

## 2. Project layout and responsibilities

Create only the files needed by the active milestone. The following is a proposed organization, not a claim that these game files exist.

| Path | Responsibility |
| --- | --- |
| `project.godot`, `export_presets.cfg` | Main scene, Compatibility settings, input map, Web export preset |
| `scenes/main.tscn` | Entire playable courtyard and session composition |
| `scenes/boat.tscn` | Player collision body, visual pivot, effects, interaction area |
| `scenes/current_field.tscn` | Editable current region with debug visualization |
| `scenes/ui.tscn` | Start, pause, settings, completion and retry controls |
| `scripts/boat_controller.gd` | Input, velocity, current sampling, collisions and recovery |
| `scripts/boat_visuals.gd` | Boat yaw, restrained roll/bob, paper flutter and wake emission |
| `scripts/current_field.gd` | World-space current velocity at a point, smooth edge falloff |
| `scripts/camera_rig.gd` | Follow, look-ahead, limited look input and framing zones |
| `scripts/game_flow.gd` | Session states, one-time chapter events, arrival and restart |
| `scripts/audio_director.gd` | Ambience/music layers and motion-linked samples |
| `scripts/ui_controller.gd` | UI focus, mute, reduced motion, pause and restart |
| `assets/models/`, `assets/materials/`, `assets/audio/` | Runtime assets with recorded provenance |
| `art-source/` | Editable Blender masters; add `.gdignore` and exclude from the web pack |
| `web/` | Versioned HTML shell and host configuration if needed |
| `builds/web/` | Generated export; exclude from ordinary source commits |
| `docs/` | Design, asset register guidance, release evidence and instructions |

Keep references to scene nodes explicit and easy to inspect. A small project does not need an entity framework, plugin collection or service locator. Prefer signals for chapter/arrival events and exported resources for tuning data.

### Main scene composition

| Node or branch | Type and role |
| --- | --- |
| `Main` | `Node3D`, owns the session |
| `Courtyard/Visuals` | Static scenery and foliage |
| `Courtyard/Collision` | Simple `StaticBody3D` banks and obstacles |
| `Water` | `MeshInstance3D`, one water surface at the fixed logical water height |
| `Currents` | Authored current regions |
| `Boat` | `CharacterBody3D`, physical movement and contact |
| `Boat/VisualPivot` | `Node3D`, mesh orientation and cosmetic motion only |
| `CameraRig/Camera3D` | Follow camera with explicit collision queries or a suitable spring arm |
| `RouteTriggers` | Chapter, shelter and camera framing areas |
| `WaitingBoat` | Second boat visual and controlled arrival interaction |
| `Audio` | Ambience, music and sound players |
| `UI` | `CanvasLayer`, accessible control and feedback |

## 3. Coordinates, scale and movement

Use metres, +Y up, XZ as the travel plane, and logical boat forward along -Z. Set the waterline to `y = 0`. The boat's physical root stays at its fixed configured height relative to that plane; `VisualPivot` supplies bobbing. Correct an imported mesh's forward direction at the visual pivot without changing controller conventions.

Start with a boat approximately 0.18 m long, 0.09 m wide and 0.08 m high. This slightly enlarged readable prop still makes the courtyard feel large. Keep visual shape, contact shape, wake and camera distances consistent with the chosen scale.

Use `CharacterBody3D` in floating motion mode with a simple smooth collision shape. Godot documents `velocity` in metres per second; `move_and_slide()` uses the physics timestep and may change velocity after contact. Call it from `_physics_process()` and do not multiply the body's velocity by delta before calling it. [CharacterBody3D reference][body]

### Control algorithm

1. Read a deadzoned, length-clamped two-dimensional input vector. Keyboard diagonals must not be faster than cardinal input.
2. Project camera forward and camera right onto XZ and normalize them. Combine them with the input so pressing forward means travelling into the current view. Account explicitly for `Input.get_vector()` producing negative Y for the forward action. Retain the last valid horizontal camera basis if a view becomes nearly vertical.
3. Convert that direction into a desired drive velocity. Holding gust raises its speed and acceleration. Opposing input should provide useful braking before reversal.
4. Sample authored current velocity at the boat position. Blend overlapping fields with smooth weights, then cap their combined magnitude. Store currents in metres per second; they are desired flow velocities, not per-frame impulses.
5. Ease actual planar velocity toward drive plus flow using timestep-independent smoothing or acceleration. Releasing input gradually removes the drive contribution and leaves the current. This creates coasting without accumulating unbounded velocity.
6. Call `move_and_slide()`. Use the resulting collision-adjusted velocity as the next state so the controller does not continually restore a blocked velocity component.
7. Update visual yaw toward travel direction above a small speed threshold. At rest, retain the previous heading. Use visual roll and very slight pitch to communicate changes; the collision shape remains stable.

| Initial tuning parameter | Starting range |
| --- | --- |
| Calm cruising speed | 0.10–0.14 m/s |
| Gust speed | 0.20–0.24 m/s |
| Typical authored flow | 0.02–0.06 m/s |
| Input-to-target smoothing time | 0.20–0.45 s |
| Cosmetic vertical bob | Approximately 1–3 mm |
| Route plus local curves and brief detours | Approximately 25–30 m of winding travel |

These are starting hypotheses. Tune with an unfamiliar first-play route, including turns and discovery pauses, to approach the five-minute experience. A practiced player may finish faster. Keep the ability to overcome every current with intentional control; do not extend duration with artificial speed locks or waiting gates.

### Input actions

| Action | Default binding |
| --- | --- |
| `move_left`, `move_right` | A/D or Left/Right; left stick X |
| `move_forward`, `move_back` | W/S or Up/Down; left stick Y |
| `gust` | Hold Space or gamepad south face button |
| `pause` | Escape or P; gamepad menu/start |
| Look | Optional right-drag mouse or right stick, with limited angles |
| Restart, mute, reduced motion | Clearly labelled UI controls, keyboard/gamepad reachable |

Consume the Start activation before enabling movement. Gameplay input must not run while a menu owns focus. Pointer lock is optional; the game must be usable with the automatic camera alone.

## 4. Current fields and recovery

Implement three reusable field shapes: a weak directional flow, a curved/tangential flow around a planter, and a local crossing flow at the runoff. Combine them with quiet water. Visible petals indicate the same field the player experiences.

All navigable passages remain connected at one water height. Route boundaries use simple, continuous contact surfaces with rounded corners; decorative roots, individual tile seams and tiny stones should not create traps. Add modest bank avoidance only near edges, and stop applying a force into the same blocking wall.

Track a recent safe pose at comfortably traversable route points. If the boat leaves the navigable area or a movement command remains blocked for an unreasonable interval, use a gentle recovery to the safe pose. Ordinary resting and intentional contact with a prop must not trigger recovery. Provide a labelled “Return to open water” option in the pause menu. Clear accumulated velocity on recovery.

The waiting boat can use a small scripted nudge response rather than a general physics system. Arrival requires the player's deliberate close approach/contact. Emit the completion event once; subsequent touching and drifting remain safe. Keep both boats separated during the final shared drift.

## 5. Camera and state

Use a raised three-quarter follow view with modest look-ahead. Author camera clearance as part of each passage. Short low-angle framing belongs in open water where it preserves visibility. Blend position and framing smoothly; do not change the input basis abruptly when crossing a zone.

Suggested states: `START`, `EXPLORE`, `ARRIVAL`, `COMPLETE`. Pause is a reversible overlay that preserves the active state. Chapter triggers change ambience and framing, not movement capabilities. Restart resets triggers, both boats, effects, audio layers and camera together.

During arrival, retain steering while raising the camera at a fixed yaw. Reduced motion keeps the normal camera or uses a very modest framing change. At completion, offer replay and continued drifting. The five-minute design target is not a countdown or timeout.

## 6. Water, lighting and assets

Build the first water treatment from a single surface, restrained animated normals, highlights, authored colour/depth cues and affordable reflections. If transparency or depth sampling causes sorting problems, use an opaque water treatment with visible shallow-water detail authored into its material. The wake can be pooled meshes or simple particles placed just above the surface; avoid z-fighting and excessive overlapping alpha layers.

Use a static reflection probe or sky contribution, coherent materials and one deliberate key light. Compatibility supports reflection probes and baked-lightmap rendering; screen-space reflections and volumetric fog are Forward+ features. Do not make either a requirement for this web target. [Renderer comparison][renderers]

If a suitable GPU baking environment exists, bake stable courtyard lighting once the layout settles. Lightmaps are static, and web can display lightmaps baked elsewhere; compose the ending through local motion, colour, music and framing over that stable base. A full rebake for every small iteration is unnecessary. [Lightmap guide][lightmap]

Godot recommends glTF 2.0 and supports `.glb`; direct `.blend` import invokes Blender. Prefer committed runtime GLBs so game imports and export automation do not require Blender. Keep editable masters and license records separately. [Asset import guide][assets]

Bake procedural Blender materials to suitable textures or recreate them as simple Godot materials. Verify scale, normals, UVs, thin-paper faces and mesh orientation in the actual browser renderer. Concept art is a mood/composition reference; it is not a runtime asset or proof of achievable rendering.

## 7. Audio and web startup

Use authored audio files and ordinary volume crossfades for the first release. Godot's low-latency web Sample mode has limitations around effects, procedural audio and some positional behaviour. Avoid depending on runtime reverb, Doppler or generated audio; pre-render the necessary character into the files. [Web audio notes][web]

Use zone-based ambience and simple distance-driven volumes where reliable. Music layers must start in sync and change gently. Provide a single mute control, stable loudness and restrained peaks. First playback begins from an explicit Start interaction. Loss of focus should pause the experience; returning should show a clear Resume action.

The web shell needs readable loading progress and a real error state when engine loading, asset fetching or initialization fails. Keep technical diagnostics in the console and give the visitor a useful retry message. A decorative loading screen must not conceal a failed runtime.

## 8. Performance and evidence

Before reporting performance, record the actual test machine, GPU, browser/version, resolution and quality setting. The following are project targets, not promises:

- Aim for stable 60 FPS at 1280×720 on the chosen reference desktop or laptop. Provide a lower render-scale option if needed.
- Begin with a compressed initial transfer goal below roughly 30 MB; measure engine and game payload separately. Adjust asset budgets to the actual exporter and host.
- Prefer 1K environment textures, selective 2K hero surfaces, reused materials and modest foliage density.
- Use pooled wake/petal effects and cap their population. Stop updating distant cosmetic details when it is safe to do so.
- Test the real web export before enriching the whole environment. A native editor run or headless import does not prove browser appearance, sound or playability.

Use the focused checks in `MILESTONES_AND_ACCEPTANCE.md`; repeat checks only after a relevant change or unresolved defect. Record observed results and remaining limitations in release evidence.

## Official references

Consulted 17 November 2026. Recheck against the pinned engine version when implementing.

[web]: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
[body]: https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
[renderers]: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
[assets]: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html
[lightmap]: https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination/using_lightmap_gi.html

