# After the Rain — milestones and acceptance

Version: 1.0 · 17 November 2026

Build a finished, publicly playable miniature through the following milestones. Each leaves a runnable game. Validation addresses concrete risks; advance once those risks are resolved and revisit only behaviour affected by later changes. Playthrough timings are design targets, not development deadlines.

## Working practice

- Preserve unrelated work and keep this game in its own project.
- Maintain a short status file: active milestone, completed work, material defects and next action. Record actual evidence.
- Split parallel work by ownership—controller/camera, environment, audio/UI—and assign one integration owner.
- Keep changes runnable, make coherent commits where a repository exists, and replace visible placeholders before calling the showcase complete.
- Validate the browser export early. Editor success alone does not establish browser success.
- Use focused checks below. Add a small automated check only when it protects an actual implementation risk; avoid a generic test suite or repeated benchmark collection.

## M0 — Runnable browser foundation

**Deliver:** Godot 4 GDScript project using Compatibility, a plain water-plane blockout, a visible boat, Begin/controls/mute UI and browser export configuration.

**Accept when:**

- The project imports and runs in the recorded engine version.
- A real browser loads the HTTP(S)-served export, reaches Begin and enters the scene after deliberate input.
- Essential content is visible, audio activation works, and loading/resource failures are legible.
- The renderer and dependencies support the primary browser target.

**Evidence:** record engine, browser/version, known device, export route and launch result. A localhost address is development evidence, not a public release.

## M1 — Movement worth playing

**Deliver:** planar kinematic movement, automatic camera, ordinary breeze, held gust, calm/curved/crossing currents, smooth bank collision and safe recovery.

**Accept when:**

- A new user can move immediately with keyboard; gamepad works when a device is available. Direction is camera-relative on the horizontal plane.
- Gusting responds clearly, release coasts, and the boat can turn broadly, cross currents and recover from overshooting.
- Current direction is visible before entry, and the camera shows the next route choice.
- Bank contact slides smoothly without routine traps, jitter or uncontrolled rotation.
- An intentional invalid-position check recovers safely without losing progression.
- Pause and focus loss stop progression and offer deliberate resumption.

**Focused check:** traverse curved turn → gust → coast → crossing current → bank contact → return. Investigate uneven-frame behaviour only if it exposes a specific movement risk. Resolve unpleasant steering before decorative expansion.

## M2 — Thirty seconds at the visual standard

**Deliver:** one playable bend around a planter with the finished boat treatment, representative water/materials, wake, bounded petals, camera and sound mix. The concept image guides atmosphere; the running scene establishes fidelity.

**Accept when:**

- The boat stays readable, its wake follows the travelled curve, and petals separate visibly near the bow.
- Lean, bob and camera framing support comfortable navigation.
- Material scale, palette and lighting feel coherent.
- Water and reflections work from allowed camera angles in the target browser.
- Gust and coast sound different; music/effects volume and mute work after audio activation.
- Frame pacing is acceptable on the recorded device. A 60 fps presentation is a target; report observations rather than guaranteed performance.
- The primary camera corridor contains no distracting placeholder.

**Focused check:** play the bend slowly and with gusting; inspect the allowed view range and runtime errors. Investigate performance only enough to identify and fix an observed bottleneck.

## M3 — Complete connected courtyard

**Deliver:** the full route, two optional detours, three current behaviours, sunny destination and waiting companion, all connected on the fixed `y = 0` water plane.

**Accept when:**

- A fresh player can infer the destination and recover direction from landmarks.
- Both detours are navigable, rewarding and reconnect naturally.
- Riding versus crossing the broad current is a real choice; the runoff is manageable with the established gust.
- Main-route geometry contains no misleading dead end, decorative trap or unintended solid-object shortcut.
- The camera remains readable beneath the chair and ferns.
- An exploratory first play is reasonably near five minutes without forced waiting. Faster and longer runs remain valid.

**Focused check:** complete the main path once and a route including both detours once. Combine environment, camera and pacing observations; revisit only failures. Label a familiar developer run accurately if no new tester is available. Never invent user-test evidence.

## M4 — Ending and reliable replay

**Deliver:** arrival, gentle nudge, companion drift, musical resolution, camera reveal, linger, restart and complete pause/settings UI.

**Accept when:**

- Entering the destination alone does not finish; nudging the companion completes once per run.
- Slow approaches from two directions work without precision aiming. Gust-speed contact is softened and still permits completion.
- The companion stays nearby without trapping the player; steering remains available during the reveal and afterward.
- Reduced camera motion applies throughout. The ending is legible with music muted, and navigation does not rely on colour alone.
- Restart resets boats, interaction state, petals, progress, camera and audio; a second run completes again.

**Focused check:** finish → linger → restart → finish. Add only the contact approaches or state checks needed to resolve a concrete defect.

## M5 — Public release and handover

**Deliver:** production browser export, complete source, asset/licence records, reproducible export instructions, known issues and actual public play URL.

Use authorised repository/hosting access when available. If missing access blocks publication, finish the export and report the smallest exact action needed. A local or access-controlled preview must not be described as public.

**Accept when:**

- A fresh unauthenticated browser opens the production URL without an owner account or application sign-in.
- Begin, steering, gust, pause, sound, final nudge and restart work in that deployed build.
- Required export resources load; refresh and first-load feedback are usable.
- Provenance and required attribution are included, with planned assets clearly distinguished from acquired/integrated assets.
- Source and export instructions record the engine version and any actual dependency.
- The final report includes the public URL, release commit when available, changes, tested browser/device and specific remaining limitations.

**Release check:** one unauthenticated full playthrough and restart, while inspecting runtime errors and essential failed requests. Confirm the deployed build's identity through the release mechanism. Broaden coverage for an observed issue or an explicit release requirement.

## Definition of done

A new visitor opens the public link, understands the controls, enjoys the short journey, nudges the second boat, sees the scale reveal and can replay. Source, assets, licences and export instructions support future work. Specific remaining issues are disclosed.

A concept render, local export, attractive opening without an ending, or owner-only link does not establish this outcome.

## Progress update format

```text
Milestone: [current milestone]
Completed: [specific integrated behaviour/content]
Evidence: [actual observed result and location]
Remaining issue: [material problem, if any]
Next action: [concrete implementation step]
Public build: [actual URL when available; otherwise its status]
```

Resolve ordinary reversible choices within the brief and continue implementation. Report genuine blockers with evidence; repeated planning is not progress.
