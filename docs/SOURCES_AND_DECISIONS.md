# Sources and decisions

Version 1.0 · 17 November 2026

## Evidence and interpretation

The game concept, layout, pace, control feel, asset priorities and proposed budgets are original production decisions. Numerical values are starting points to tune in the running game; none is a measured result.

Platform and asset-source facts were checked against the official resources below on 17 November 2026. Implementation should use documentation matching the exact engine version selected at setup. A source catalogue policy does not replace checking the individual asset that will actually ship.

## Official implementation references

| Resource | Consult for |
| --- | --- |
| [Godot: Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) | Browser export, startup, audio and serving requirements |
| [Godot: Overview of renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html) | Compatibility feature support and renderer differences |
| [Godot: CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html) | Scripted movement, velocity and collision methods |
| [Godot: Available 3D formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html) | GLB and Blender import workflow |
| [Godot: Lightmap global illumination](https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination/using_lightmap_gi.html) | Lighting bake workflow |
| [Godot: Command line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) | Reproducible import and export commands |

The core architecture uses Compatibility, GDScript and single-threaded web export. This is a project choice based on the public-browser target, not a general recommendation for every Godot game.

## Candidate asset sources

| Source | Official policy / catalogue |
| --- | --- |
| Poly Haven | [Asset licence](https://polyhaven.com/license), [textures](https://polyhaven.com/textures), [environment maps](https://polyhaven.com/hdris), [Vault access](https://polyhaven.com/vaults) |
| ambientCG | [Licence](https://docs.ambientcg.com/license/), [catalogue](https://ambientcg.com/) |
| Kenney | [Asset policy](https://kenney.nl/support), [Impact Sounds](https://kenney.nl/assets/impact-sounds), [assets](https://kenney.nl/assets) |
| Freesound | [Licence FAQ](https://freesound.org/help/faq/), [sound catalogue](https://freesound.org/) |

The asset register begins with planned work. Its external rows require exact item selection, download, licence review and an integration check. Its original-work rows require actual creation. No third-party production asset is included in this handoff.

## Decisions resolved in this handoff

- One approximately 8 × 12 m courtyard; one water height at y = 0.
- Nominal 0.18 m boat; bow -Z; movement in the XZ plane.
- Keyboard and gamepad controls; desktop landscape presentation.
- Expected first play around five minutes; players may finish faster or linger.
- Two optional, reconnecting discoveries.
- The matching boat is the destination; a gentle nudge causes completion.
- Camera and steering remain comfortable during the final shared drift.
- Original assets and suitable free assets are the starting budget.
- The first visual milestone is a complete short section of real browser gameplay.
- Source repository visibility and unrelated infrastructure remain under the user's existing choices.

## Environment choices for Codex to resolve

The exact Godot patch, tool executable paths, availability of Blender MCP, physical controller access, measured reference hardware and publication provider depend on the actual Codex workspace.

Resolve these through inspection, record the result, and continue the build. Ask the user only when unavailable external access or a materially different product choice prevents the requested action. A missing deployment connection does not prevent finishing the source and export.

## Delivery boundaries

The handoff supplies written requirements, original concept art and a schematic map. It does not claim that the game, production assets, export or public deployment already exist.

A final public link must be the actual exported game and work without an owner account. Record publication and observed gameplay separately from local build success.
