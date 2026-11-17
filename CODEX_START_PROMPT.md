# Build After the Rain

You are the lead gameplay engineer, technical artist, art director and release owner for AFTER THE RAIN. Implement the game described in this handoff. Work through to a complete playable release; use the milestones as an execution sequence and continue between them without routine approval pauses.

## Read and establish the project

Read AGENTS.md, all six documents in docs/, docs/asset_register.csv, and reference/README.md. Inspect reference/after-the-rain-concept.png and the courtyard layout. If using the consolidated handoff instead, read all its sections. Inspect existing workspace instructions and preserve unrelated work.

This is a new dedicated Godot project. Use a stable Godot 4.x version, GDScript, Compatibility rendering, and a single-threaded web export. Record the exact engine patch and match its export templates. Use the existing configured model; this brief requests no model changes.

Inspect the available Godot, Blender / Blender MCP, repository and hosting tools. Make reasonable reversible decisions autonomously. Missing Blender MCP should lead to a practical fallback; missing hosting credentials should be reported precisely while local implementation and export continue.

## The game

Build a beautiful 3D experience lasting about five minutes on a first visit, with optional lingering. The player guides a handmade paper boat through shallow rainwater in one small Malaysian shophouse courtyard.

Use faded teal and terracotta patterned tiles, weathered timber, clay pots, ferns, a rattan chair, a rain chain, damp cool shade, and warm sunlight. The boat has subtle blue pencil stars. Its matching companion waits in the sunny final pool.

The player starts beneath a wooden step, sees the destination, explores two short reconnecting detours, rides and crosses gentle currents, and reaches the other boat. A gentle player-initiated nudge begins shared drifting and a slow camera rise revealing the courtyard's tiny scale. Keep steering available and allow continued play or replay.

## Controls and feel

WASD / left stick requests camera-relative movement on the XZ plane. A held gust button adds a stronger breeze. Releasing input allows coasting; opposing input provides gentle braking and directional authority.

Use a controlled kinematic body on a fixed water surface with authored current fields. Cosmetic bobbing, leaning, paper flutter, wake and sound sell lightness. Maintain a readable boat silhouette. Smooth collision slides around edges; recover safely from exceptional stuck states.

Use a raised follow camera with look-ahead during normal play. Low framing belongs in readable open sections, and the final view rises gently. Support keyboard, controller, pause, restart, audio controls, reduced camera motion and a way to re-display controls. First user interaction starts browser audio.

## Scope and implementation

Follow the supplied route and system responsibilities. One courtyard, one player, two brief detours and one ending are the production boundary. Implement the complete experience in actual 3D.

Create a polished thirty-second playable section early, then extend its proven art, camera and movement across the full route. Use original models and verified free assets first. The asset register lists work to do; its planned entries are not completed assets. Complete exact provenance as assets are acquired.

Treat the concept art as visual direction. Establish the actual achievable appearance in the browser renderer. Choose effects that work there. Keep water, foliage, reflections and audio within a measured runtime budget.

## Build sequence

1. Inspect tools, establish the repository/project and minimal web export.
2. Implement steering, gust, coasting, currents, edge sliding, camera and safe recovery.
3. Make one short section look, sound and play at the intended quality.
4. Build the complete route, optional discoveries, companion encounter and ending.
5. Integrate the remaining materials, environmental motion, soundtrack and sound effects.
6. Perform the focused checks in the acceptance document, fix material failures and produce the web release.
7. Publish to an available authorised static host with a public HTTPS URL and no sign-in requirement. Preserve repository visibility and unrelated infrastructure. If external access is unavailable, finish the export and state the exact missing publishing action.

Use parallel agents for independent work if available, with clear ownership of files and shared tuning values. Keep integrations sequential where systems depend on each other.

## Working standard and final delivery

Give concise progress updates: completed work, the next concrete result, and any real blocker. Maintain docs/BUILD_STATUS.md so a later session can resume accurately. Record important scope decisions instead of repeatedly asking me about routine details.

Verify meaningful risks without repeatedly running broad checks that add no evidence. A successful import or export does not establish that controls, sound and the ending work. Clearly distinguish automated checks, actual browser play, untested devices and remaining limitations.

At completion, provide the public playable URL when published; source branch and commit when available; build/run instructions; a short changelog; asset and licence records; and the actual validation results. State any deployment blocker or remaining quality limitation honestly.

Start by reading the handoff, inspect the environment, then implement the game.
