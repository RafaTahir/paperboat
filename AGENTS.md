# After the Rain — Project Instructions

## Purpose

Build a small, complete 3D game about guiding a paper boat across a tropical shophouse courtyard after rain. The intended first playthrough is approximately five minutes, and players may linger. The quality target is exceptional presentation and interaction within this small scope.

This file applies to the dedicated After the Rain project. Existing higher-priority instructions and explicit user directions take precedence. Preserve unrelated instructions and work when importing this kit into an existing folder.

## Authoritative project material

- README.md explains the kit and read order.
- docs/GAME_DESIGN.md owns the experience, route, interactions and ending.
- docs/TECHNICAL_SPEC.md owns technical contracts, coordinate conventions and runtime design.
- docs/ART_AUDIO_ASSETS.md owns visual treatment, asset planning and sound.
- docs/MILESTONES_AND_ACCEPTANCE.md owns milestones and observable acceptance.
- docs/DEPLOYMENT.md owns export, hosting and release evidence.
- docs/SOURCES_AND_DECISIONS.md distinguishes verified platform facts from design choices.
- docs/asset_register.csv records actual asset provenance as the game is built.
- reference/ contains concept and layout references, not production assets.

Resolve small inconsistencies against these ownership boundaries and document the decision. Make routine tuning choices through implementation and play. Escalate only a meaningful change to the approved experience, unavailable external access or a new purchase.

## Fixed product direction

Use Godot 4.x, GDScript and Compatibility rendering for a public desktop-browser release. Pin the stable engine patch selected during environment inspection and match the export templates. Target a single-threaded export first.

Use one continuous water surface and a controlled XZ movement controller. Keep all gameplay colliders and current calculations independent of cosmetic boat roll/bob. Use shared tuning resources rather than scattering conflicting constants.

Normal steering is camera-relative. Held gust increases wind authority, release coasts, and opposite input brakes gently. The player should immediately understand how to move. A mostly automatic raised camera preserves visibility; the low viewpoint is an authored accent.

Progression is spatial and event-based. Expected duration is a pacing target, not a countdown. Two brief optional detours reconnect with the route. The ending is caused by the player's approach and gentle nudge of the matching boat. Steering and replay remain available.

## Quality priorities, in order

1. Clear, pleasurable steering and comfortable camera behaviour.
2. A complete playable route and reliable ending.
3. A coherent visual standard proven in the actual export.
4. Immediate and consistent water, wake, petal and sound responses.
5. Smooth operation on the explicitly recorded reference machine/browser.
6. Reproducible builds, valid asset provenance and a usable public release.

Build a short beautiful playable segment before expanding decoration everywhere. Maintain the same visual treatment across the full journey. Keep production limited to the specified scene and mechanics.

## Assets and tools

Use Blender MCP when available, or reproducible Blender scripts / editor workflows when practical. Runtime assets use GLB and other suitable engine formats; keep original authoring files in art-source/ with the correct import/export exclusions.

Treat the generated concept PNG as a reference. It does not provide geometry, material maps, interactive lighting or evidence of completed gameplay.

Prefer original work and verified free assets. Read the exact source item's licence before use, retain its source URL and applicable terms, and complete the register. Catalog links are discovery sources rather than completed licence records. Keep third-party licensing notices accurate. Avoid a blanket project licence that accidentally asserts rights over third-party assets.

Use existing authorised tools and infrastructure. Routine development is authorised by the kickoff. Do not purchase assets, change unrelated infrastructure, expose private source code or create a paid service commitment without the relevant user decision.

## Repository and file organisation

The Godot project belongs at the repository root. Runtime assets live under assets/, scenes under scenes/, code under scripts/ and materials/shaders under their documented folders. Design material remains under docs/ and reference/. Use builds/web/ for generated export output.

Keep source asset files and provenance. Ignore generated import caches, temporary downloads, export output and credentials in Git. Do not delete unrelated files or build archives to reclaim space.

Use small, understandable modules and explicit ownership for shared state. Prefer concrete code for this game over speculative reusable frameworks. Do not add a backend, account system, combat, inventory or a broader world to the first release.

## Collaboration and progress

Keep the user informed with short, factual updates during active work. Continue across ordinary milestones once their acceptance criteria are met; milestones are not requests for user approval.

If multiple agents are available, separate controller/camera, environment/assets and audio/UI responsibilities. Agree shared interfaces before integration. Integrate dependent changes sequentially and avoid simultaneous edits to the same scene or tuning resource.

Create docs/BUILD_STATUS.md when implementation starts. Record the exact engine version, current milestone, files changed, what actually runs, relevant observed checks, remaining work and the next action. Use honest states such as planned, implemented, observed working and blocked.

## Verification and release

Use focused checks for the current concrete risk. Confirm import and export, then observe meaningful gameplay in the exported browser build. Once sufficient evidence exists, advance to the next milestone. Do not invent performance numbers or treat headless execution as visual/audio verification.

The release must support start, movement, gust, pause, audio controls, recovery, route completion, ending, replay and direct page refresh. The initial user gesture must enable audio without trapping the player in a silent failure.

Only claim a public release after observing the actual HTTPS game launch without an account. If credentials or hosting are unavailable, finish the export and identify the exact external blocker; do not fabricate a URL or stop unfinished local work solely because deployment is blocked.

End with a concise changelog, actual build/source identifiers, launch instructions, observed validation, remaining limitations and the public playable link when available.
