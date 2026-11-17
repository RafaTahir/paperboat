# Release report — AFTER THE RAIN 1.0

## Build identity

Godot **4.6.3.stable.official.7d41c59c4**, matching official4.6.3.stable export templates.
GDScript, Compatibility, WebGL2, single-threaded, extensions disabled, no PWA.
Blender **5.2.3 LTS** for original GLBs. Runtime uses committed GLBs/OGG, not Blender/Python.
Source branch: `codex/after-the-rain`. Exact release commit is recorded by the deployment and Git log (to avoid a self-referential hash in source).

Published successfully through ChatGPT Sites: https://after-the-rain-courtyard.rafaeitahirmy.chatgpt.site . Public audience, no sign-in configured. Hosting reported success at 14:57 MYT on 17 November 2026. Deployed source commit: 671f783df586dc0de6082dcc2b6cc7f0608d931f. GitHub: https://github.com/RafaTahir/paperboat, branches main and codex/after-the-rain. The final public version was not play-tested after publication, at the user's explicit request.

## Changelog

- Complete connected courtyard and two reconnecting atmosphere discoveries, on one fixed water plane.
- Camera-relative kinematic movement, held gust, coasting, three shared current behaviours, smooth contact and safe recovery.
- Original ivory folded boat with blue pencil stars; matching companion, deliberate nudge, shared drift, musical resolution, camera rise, continued steering and replay.
- Original Blender pottery, ferns, trailing leaves, rattan chair, rain chain and hibiscus; procedural wet patterned tiles, timber/plaster, water refraction, wake and responsive petals.
- Three aligned original music stems and ten pre-rendered sound families.
- Begin, keyboard/gamepad bindings, pause/focus loss, sound levels/mute, reduced motion, lower render resolution, recovery and restart.
- Honest web progress/error feedback and an audio-unlock fallback; static public-host package with bounded engine file sizes.

## Actual checks

Machine: Windows11, Intel HD Graphics620, driver31.0.101.2130. Browser: Codex in-app Chromium; exact embedded Chromium version not exposed by the browser-control surface. Viewport observed990×560. Default3D scale now0.85; lower setting0.65. Text remains native resolution.

Headless import/start/export succeed. Focused controller checks pass. Real-scene headless integration:39 passes,0 failures; focused arrival/restart/pause:15 passes,0 failures. See INTEGRATION_CHECKS.md for details and the distinction between navigation and arrival setups.

Actual localhost browser run: Begin, WASD/arrows, held gust, release/coasting, collision slide, chair discovery, curved-current chapter, runoff, hibiscus pocket, sunny pool and companion nudge observed. Completion logged23.1m and343s, including tool-reading/observation delays. No recoveries. The camera rose, LINGER appeared and steering remained available. This is a familiar developer run, not an unfamiliar-user pacing study.

Pre-optimization FPS snapshots ranged23–44; lower resolution alone did not resolve the slow sections.159 static boxes were then batched into8 material groups, reducing base draw submissions by151, and browser audio was corrected to Sample mode. Final optimized browser comparison and public replay are recorded below after observation.

All16 OGG files decode to finite stereo samples, three53⅓s stems align, and numeric peaks do not clip. Browser startup/audio status and mute/settings are checked separately from aesthetic listening. No human speaker/headphone listening review has been claimed.

## Payload and provenance

Official engine WASM:37,700,666 uncompressed bytes. The game pack is approximately1.7MB (exact final file sizes are in the release package). Static packaging splits the unchanged engine into20MiB and16.7MB parts and reconstructs a correctly typed WASM Response. Standard unsplit Godot export is retained separately.
All production art/audio are original project work with reproducible sources. No third-party asset packs or paid services were used. Godot MIT and its bundled third-party/font notices ship with the web package. See asset_register.csv and LICENSES.md. The concept/layout references are excluded from the game.

## Material limitations

- Desktop keyboard browser play is the verified primary target. No physical gamepad, Safari, Firefox, mobile or touch device has been tested.
- A fresh unfamiliar-player pacing/usability test and human audio mix review remain unperformed.
- The achieved art is a stylized real-time miniature; reflections and foliage do not reproduce the supplied concept render's photographic fidelity.
- Initial engine transfer is substantial; host compression determines network download cost. Frame rate is hardware dependent; no60FPS guarantee.

## Release freeze

At the user's explicit request, all further testing/verification stopped. The final performance and UI refinements were exported but not browser-retested. Publishing proceeds using the existing evidence; the final public build has not been play-verified. No additional quality claims are implied.


## Audio repair1.0.1

Corrected a project-setting/player-enum mismatch: web default playback now1=Sample, with explicit Sample selection on every web AudioStreamPlayer. The previous value2 was incorrect for the project setting. Added an audio-clock gain ramp adapter for continuous layer crossfades and skipped resume calls on already-running contexts. Source audio is unchanged. A focused browser audio-output check is being completed; no broad gameplay tests are run for this change.

Focused audio check completed,17 November2026: actual Chromium web export, Sample backend active,2,922 smoothed channel-gain changes observed. Output continued beyond the53.33s music loop, with682 non-silent sampled windows, maximum observed absolute sample0.198 (-14.1dBFS), and0 sampled values at clipping. Gust changes, full music volume, mute, pause and resume exercised; pause output reached zero and muted output was near silence. No browser warning/error logs. This was one focused diagnostic pass with a corrective rebuild after the initial configuration failure; no broad regression suite. These are output/ramp observations, not a human headphone/speaker listening review. Temporary instrumented HTML removed before publication.

Publication receipt: audio1.0.1/Sites version2 succeeded at15:49 MYT on17 November2026, source8df693dd6c669e6c4cadbc88eddfa1cd12642678. Public URL unchanged. GitHub main and codex/after-the-rain contain the fix. No additional checks after the focused browser pass.
