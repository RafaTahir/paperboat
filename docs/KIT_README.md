# After the Rain — Codex Build Kit

Version 1.0 · 17 November 2026

## What this package is

A complete production handoff for a new, small 3D game: guide a paper boat through a Malaysian shophouse courtyard after a tropical shower, then reunite with a second boat. The intended first playthrough is approximately five minutes, with room to linger.

This package contains the brief, project instructions, technical design, art and sound direction, asset register, milestones, deployment plan, concept art, and a layout reference. It does not yet contain a playable Godot project, finished production models, licensed audio downloads, or a published game.

## Start in Codex

1. Create a dedicated project folder, such as `after-the-rain`, and extract the contents of this kit into it. Use the extracted folder containing this README as the project root. Keep it separate from existing games.
2. Open that folder in Codex. Keep the model and effort settings you have already chosen.
3. Paste the complete text from `CODEX_START_PROMPT.md` into a new Codex task. Ask it to execute the build, continuing through the milestones.
4. Let Codex inspect the available Godot installation, export templates, Blender or Blender MCP connection, and repository/deployment access. It should use existing tools and make routine implementation choices autonomously.
5. Provide a repository or hosting connection only if the final publication step needs access that is genuinely unavailable. Development should proceed while any external publishing blocker is reported clearly.

If you work through chat attachments, attach this ZIP and the kickoff prompt. If the client cannot open ZIPs, attach the companion `After-the-Rain-Codex-Handoff.md` and the concept PNG extracted from `reference/`. The consolidated handoff contains the same written requirements.

If a destination already contains `AGENTS.md`, retain it and have Codex reconcile the project-specific instructions instead of overwriting unrelated guidance.

## What is already decided

| Decision | Direction |
| --- | --- |
| Main platform | Public desktop-browser game, with keyboard and gamepad support |
| Engine | A stable Godot 4.x patch, recorded and pinned during setup |
| Language / renderer | GDScript / Compatibility |
| World | One courtyard, approximately 8 × 12 metres |
| Movement | Direct camera-relative planar steering, held gust, release to coast |
| Water | A controlled fixed-height surface with authored currents |
| Goal | Reach and gently nudge the waiting paper boat |
| Completion | Shared drift and an upward camera reveal; optional continued play |
| Scope | One scene, two brief detours, one ending |
| Asset budget | Original work and verified free assets first; additional purchases require a specific decision |
| Visual standard | Warm, tangible, coherent 3D materials and responsive movement, supported by carefully mixed sound |

The concept image is a mood and composition reference. Prove the achievable look in the actual browser renderer early.

## Read order

| File | Purpose |
| --- | --- |
| `CODEX_START_PROMPT.md` | Paste-ready instruction to start building |
| `AGENTS.md` | Ongoing project rules for Codex |
| `docs/GAME_DESIGN.md` | Player experience, route, controls, pacing and ending |
| `docs/TECHNICAL_SPEC.md` | Scene structure, systems, tuning and browser constraints |
| `docs/ART_AUDIO_ASSETS.md` | Art direction, asset creation and sourcing, music and effects |
| `docs/MILESTONES_AND_ACCEPTANCE.md` | Work sequence and observable completion criteria |
| `docs/DEPLOYMENT.md` | Build export, public hosting and release evidence |
| `docs/SOURCES_AND_DECISIONS.md` | Verified documentation and assumptions |
| `docs/asset_register.csv` | Planned assets and eventual provenance tracking |
| `reference/after-the-rain-concept.png` | Original concept image from the concept discussion |
| `reference/courtyard-layout.svg` and `.png` | Schematic layout for blockout, not a finished level |
| `reference/README.md` | How to interpret and exclude design references from exports |

The kit includes import exclusions for documentation, references, source art and generated builds, plus Git ignore rules for caches, exports and local credentials. The asset register stays in `docs/` so the engine does not treat planning data as a runtime CSV resource.

## What Codex should produce

The runnable Godot project, original source assets where created, runtime assets with recorded provenance, a usable web export, reproducible build instructions, concise validation evidence, and a public playable URL when authorised hosting access is available.

Do not count planned assets, placeholder models, successful headless import, or a local-only launch as a published finished game. The decisive evidence is the actual interactive exported game.

## Practical defaults

Use the existing stable Godot installation when suitable, record its exact patch, and use matching export templates. Use Blender MCP if it is available; background Blender scripts are a reasonable fallback. A Blender installation or a paid external generation service is not a prerequisite to starting movement and scene blockout.

Final production assets still need to be created or sourced. The register tells Codex what to build, where each asset will live, and which provenance fields to complete. The concept image is included as a reference rather than a substitute for meshes, materials or a real gameplay screenshot.

The first result to establish is thirty seconds of beautiful, controllable play: a sweeping turn around a planter, a readable current, a responsive wake, floating petals, and a clean sound mix.
