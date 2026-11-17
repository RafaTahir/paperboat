# AFTER THE RAIN — provenance and third-party notices

Verified against **Godot 4.6.3-stable**, 17 November 2026.

## Project work

The production meshes, material artwork, shaders, UI composition, music and sound
files were authored specifically for this project through the retained scripts
and project code. No purchased assets, downloaded material packs, field recordings
or third-party musical compositions were incorporated. See `asset_register.csv`,
`ENVIRONMENT_NOTES.md` and `AUDIO_NOTES.md` for exact production paths and status.

The supplied concept and layout remain user-provided design references. They are
excluded from the playable web pack and are not presented as production geometry
or a screenshot of the game.

This notice does **not** grant a blanket licence over the repository, user-provided
references or original project work. The project owner determines the release
licence for that work. Third-party components below retain their own licences.

## Godot Engine runtime

This game uses Godot Engine 4.6.3, distributed under the MIT/Expat licence.

Version1.0.1 adapts the web JavaScript SampleNodeBus.setVolume method through
`web/patch_web_audio.mjs` to smooth gain changes on the audio clock. The WASM
binary is unchanged. The adapter is based on the exact4.6.3-stable
`platform/web/js/libs/library_godot_audio.js` source; upstream copyright and full
MIT/third-party notices are preserved in the distributed notice files.

Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

The authoritative permission and warranty notice is the
[4.6.3 engine licence](https://raw.githubusercontent.com/godotengine/godot/4.6.3-stable/LICENSE.txt).
The engine's licence applies to the engine, not automatically to the game's
original code or assets. Godot's
[licence compliance documentation](https://docs.godotengine.org/en/4.6/about/complying_with_licenses.html)
accepts a visible link to [Godot's licence](https://godotengine.org/license) in
game documentation or credits as an inclusion method.

Godot bundles additional libraries with their own notices, including the audio
decoders, font rasterisation/shaping and compression libraries used by the export.
The web release should accompany the engine with an unmodified copy of the
[exact 4.6.3 COPYRIGHT.txt](https://raw.githubusercontent.com/godotengine/godot/4.6.3-stable/COPYRIGHT.txt),
named `GODOT_COPYRIGHT.txt` to distinguish it from project authorship. Retain its
full copyright entries and licence texts and expose it through the web credits.
This is deliberately a complete upstream notice rather than an incomplete manual
selection of engine dependencies.

## Built-in UI font

The UI uses Godot's built-in **Open Sans SemiBold**, supplied as
`thirdparty/fonts/OpenSans_SemiBold.woff2`. This exact runtime default is selected
by the engine's
[4.6.3 theme build source](https://raw.githubusercontent.com/godotengine/godot/4.6.3-stable/scene/theme/SCsub).
No separate font file was downloaded or added by the game.

Copyright 2020 The Open Sans Project Authors.

The font is under the **SIL Open Font License 1.1**. Its complete upstream
[copyright and licence](https://raw.githubusercontent.com/godotengine/godot/4.6.3-stable/thirdparty/fonts/LICENSE.OpenSans.txt)
must remain available with redistribution. The same font copyright and full
OFL-1.1 text are included in Godot's `COPYRIGHT.txt` above. The font was not
modified or renamed. OFL coverage of the font does not place the game's original
artwork, documents or code under the OFL.

## Authoring tools

Blender, Python, NumPy and soundfile/libsndfile are authoring tools; their program
binaries and Python packages are not part of the playable web distribution. The
retained render scripts describe how to reproduce the original generated assets.
Tool licences do not substitute for the runtime notices above. The original
audio's generated OGG files contain original sample data; Godot's decoder notices
remain covered by the engine distribution notices.

## Release inclusion

Retain the engine licence link, `GODOT_COPYRIGHT.txt` and the Open Sans attribution
in the public web distribution's accessible credits. Keep the source documents
and asset register with the source delivery. Recheck against the exact runtime
if the engine patch or font changes; do not infer coverage from a generic CC0 or
MIT label placed on the whole project.
