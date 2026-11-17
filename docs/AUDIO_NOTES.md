# Original audio production

All shipped audio is original work created for AFTER THE RAIN. No third-party
recordings, sample packs, music quotations or paid services were used. Authorship:
Codex for this project, 17 November 2026. There are no third-party attribution
obligations for these files. Project ownership/licensing remains with the project
owner; this document does not impose a blanket licence on other material.

## Reproduction and assets

`art-source/render_audio.py` is the complete deterministic composition and sound
design source (NumPy random seed 171126). It renders 24 kHz stereo Vorbis OGG.
Install Python packages `numpy` and `soundfile`, then run that script from any
directory. A task-local optional encoder installation in
`art-source/.audio-tools/` is ignored by Git and excluded from Godot import.
No such tooling is needed to import or play the committed OGG files.

`art-source/audio_render_report.json` records the source duration, gain and size.
The 16 files total 1,006,145 bytes at the first render. Each musical stem has
exactly 1,280,000 frames / 53⅓ seconds: sixteen bars at 72 BPM. The shared original
D-pentatonic miniature uses warm additive pads, soft plucks and restrained bell
tones. Tapped stereo room tails are baked into the samples; playback requires no
runtime reverb, generated audio or positional web-audio effects.

| Family | Runtime files in `assets/audio/` | Treatment |
| --- | --- | --- |
| Calm stem | `music_calm.ogg` | Four spacious harmonies and soft low support |
| Motion stem | `music_motion.ogg` | Light, alternating plucked figures |
| Arrival stem | `music_arrival.ogg` | Original sparse resolving pentatonic melody |
| Courtyard ambience | `courtyard_ambience.ogg` | 48 s filtered air, distant drips, stereo detail |
| Water lap | `water_lap.ogg` | 12 s soft modulated filtered water texture |
| Gust | `gust.ogg` | 1.2 s gentle rounded wind envelope |
| Leaf drip | `leaf_drip_1.ogg`–`leaf_drip_3.ogg` | Three downward resonant drops with baked room tails |
| Paper flutter | `paper_flutter.ogg` | 0.7 s soft, irregular filtered rustles |
| Hull bump | `hull_bump_1.ogg`, `hull_bump_2.ogg` | Two short muted low contacts |
| Petal brush | `petal_brush.ogg` | 0.36 s light surface rustle |
| Rain chain | `rain_chain.ogg` | 2.8 s trickling drops and faint metal resonance |
| Wind chime | `wind_chime.ogg` | 4.8 s sparse high bell cluster |
| Arrival accent | `arrival_accent.ogg` | 6 s slowly resolving chord |

## Integration

`scripts/audio_director.gd` creates three aligned music players, three environmental
loop players and a bounded eight-voice detail pool. Nothing plays before `begin()`.
Call `begin()` directly from a valid browser click/key Begin gesture. `update_mix`
crossfades files from boat motion, shelter and spatial progress. `arrive()` is
idempotent. `reset_audio()` resets all layers, timers and the completion state.
`set_levels(music,effects,muted)` applies to every loop and currently playing detail.
Tree pause notifications explicitly pause and resume every audio player.

API: `begin()`, `reset_audio()`, `update_mix(speed,gust,progress,position,delta)`,
`arrive()`, `play_bump()`, `play_brush()`, `set_levels(music,effects,muted)`.

## Web gain smoothing — 1.0.1

User-reported distorted music prompted source inspection. The game's gradual
layer targets were sent every frame into Godot 4.6.3's SampleNodeBus.setVolume,
which assigns AudioParam.value immediately. Those frame-rate steps are a
plausible source of audible zipper/crackling during crossfades; the exact cause
was not established by subjective listening.

The focused browser check then exposed the primary configuration mistake:
`default_playback_type.web` was set to2 (the player enum's Sample value), but
the project setting uses0=Stream,1=Sample. It is now1, and each web player also
explicitly uses `AudioServer.PLAYBACK_TYPE_SAMPLE` to prevent that ambiguity.
The initial diagnostic pass produced audio but zero Sample gain ramps,
consistent with the wrong backend being selected.

`web/patch_web_audio.mjs`, applied by `web/package.mjs`, replaces that one
version-pinned JavaScript method with audio-clock gain automation. Initial gains
are set before playback; later changes use a 25ms exponential time constant,
hold the current interpolated gain when retargeting, and skip unchanged targets.
Both standard downloadable and hosted exports receive the adapter. Official
WASM remains unchanged and Sample playback stays enabled. No higher-latency
single-thread stream mixing or runtime effects were introduced. Browser unlock
now calls resume only on suspended contexts.

This is an adaptation of the MIT-licensed Godot JavaScript runtime, whose
upstream copyright/licence notices remain included. See LICENSES.md.
One focused browser audio-output/ramp check is recorded in RELEASE_REPORT.md.

## Observed verification and limits

The offline renderer ran successfully. All sixteen OGG files decoded as finite
stereo samples at 24 kHz; all three stems have identical frame counts; decoded
peaks stay below clipping. Their loop composition wraps all musical room tails
across the loop boundary. Encoding uses small writes to avoid a Windows Vorbis
stack limitation encountered with a full long buffer.

The environmental textures are synthetic authored sounds, not field recordings.
At this handoff they remain **PROVISIONAL** for final subjective listening review.
File generation and numeric checks do not establish browser playback, autoplay
unlock, perceived naturalness, mix comfort or headphones/speaker quality. The
release owner must record the actual browser listening result, mute/pause result
and any remaining audio limitation in BUILD_STATUS and the asset register.

The targeted web check observed actual Sample playback and2,922 audio-clock gain ramps through a full music loop. Sampled output peak0.198,0 clipping values; mute/pause/resume behaved as expected and browser logs had no errors. This is objective signal/control evidence, not a subjective listening review. See RELEASE_REPORT.md.
