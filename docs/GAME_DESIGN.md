# After the Rain — game design

Version: 1.0 · 17 November 2026

This is the original design specification for a compact game. Dimensions, timings and tuning ranges below are starting targets for implementation, not measured performance or promised completion times. Implement the intent, tune in the actual game, and record material departures.

## 1. Player promise

Guide a handmade paper boat across a rain-soaked Malaysian shophouse courtyard to reach another boat carrying the same blue pencil stars. At the boat's scale, everyday objects become a landscape: a planter is a tower, a fern is a forest, and a rattan chair is a sheltered passage. The final camera rise reveals the small physical extent of the journey.

The expected first exploratory playthrough is about five minutes. A direct replay may be shorter, and a curious player may stay longer. Completion follows the player's arrival and gentle nudge of the companion boat. There is no countdown, compulsory waiting period, or five-minute automatic ending.

### Three design pillars

1. **Pleasurable motion.** Steering, gusting, coasting and curving around a current feel satisfying even in an undecorated basin.
2. **Intimate discovery.** A small, coherent environment rewards looking closely and taking a brief side passage.
3. **An arrival the player causes.** The player reaches and nudges the second boat, then keeps control as the two drift together and the view opens.

## 2. Locked first-release scope

| Element | Required scope |
| --- | --- |
| Engine and primary platform | Godot 4, GDScript, Compatibility renderer; public desktop-browser play |
| World | One authored courtyard, approximately 8 × 12 metres |
| Water | One continuous, fixed water surface at world `y = 0` |
| Player character | One handmade paper boat with a clear white silhouette and blue pencil stars |
| Core actions | Guide direction, hold a gust, release to coast |
| Water behaviours | Calm water, a broad curved current, and one readable crossing current |
| Exploration | Two short optional passages that return to the main route |
| Environmental responses | Wake, boat lean/bob, displaced petals, a small floating leaf interaction |
| Goal | A second paper boat with matching pencil stars in the sunny destination pool |
| Finish | Gentle contact, shared drift, camera rise, musical resolution |
| Replay | Restart the experience and linger after finishing |

Treat every new mechanic, location or controllable character as a scope decision. The detailed art can expand within this scene, but the first release should retain this small interaction vocabulary.

## 3. Opening and destination readability

The browser landing screen offers **Begin**, controls and mute. Use a valid browser user gesture for audio activation. If controller input does not unlock audio, show a small click/key-to-enable-audio fallback while keeping the game usable. Loading feedback is truthful; start when essential resources are ready.

After Begin, briefly connect the sheltered player boat to the sunny destination through camera composition. Establish a brighter opening, a glimpse of the companion boat and a recognisable timber window behind it.

Movement input skips the establishing look immediately. Reduced camera motion starts in the normal gameplay view.

Teach the controls in one quiet line, for example: **Move: WASD / left stick · Hold Space / south face button for a breeze**. After the first successful movement and gust, fade the line. The controls remain available in Pause.

Show the destination again from natural openings along the route. Landmarks and changing shelter should establish progress. If observation reveals confusion, improve route composition before adding an optional **Show destination** cue that respects reduced-camera settings.

## 4. Controls and movement feel

### Player inputs

| Action | Keyboard / mouse | Gamepad | Behaviour |
| --- | --- | --- | --- |
| Guide direction | WASD; arrows as an alternative | Left stick | Desired travel direction relative to the gameplay camera's horizontal orientation |
| Gust | Hold Space | Hold south face button | Stronger guiding breeze while held; release returns to ordinary acceleration and coasting |
| Look | Optional mouse look while deliberately engaged | Optional right stick | Limited orbit; movement remains usable with the automatic camera alone |
| Pause | Escape or visible Pause control | Start/Menu | Stops game progression and opens readable controls, sound and restart options |
| Restart | Pause menu action | Pause menu action | Resets the complete experience, including the companion boat, petals and music state |

Use the controller's reported mapping when available. Do not require the player to memorise a brand-specific button name. Keyboard-only play must be complete.

### Steering specification

- Resolve desired direction on the `XZ` plane. The boat controller remains on the one water plane; visual bob and roll do not alter the navigation surface.
- Make the first response immediate enough to recognise. Smooth acceleration, direction changes and visual rotation preserve the sensation of a light object on water.
- Permit movement in any planar direction. The player can recover from overshooting without needing a turn-in-place manoeuvre.
- Rotate the visible boat toward its travel direction with a short, controlled lag. Use a small visual lean when turning and a quiet paper flutter during a gust.
- Currents influence velocity gently enough that a held gust can cross them. Current direction must be visible in drifting petals or surface motion before the player commits.
- Let go of input to coast and gradually slow or move with the local current. Avoid perpetual drift that prevents a player from examining a small detail.
- Introduce the gust within the first several seconds of movement. Use wake length and sound to communicate the extra push, without a fuel meter or resource system.

Use a nominal boat length of 0.18 m with its bow facing local `-Z`. Begin tuning ordinary travel near 0.10–0.14 m/s and a held gust near 0.20–0.24 m/s. These are scale-aware starting ranges. The steering response and route traversal should determine the final values; do not force the game to last five minutes by making controls sluggish.

### Collision and safe recovery

Use simple, smooth colliders around planters and boundaries. On contact, the boat slides along the edge with a small soft visual reaction. Decorative gaps too small for the boat should not trap it. Keep clear navigable passages comfortably wider than the boat; a starting minimum of about three boat widths gives room to steer.

Add a subtle shore-repulsion or recovery influence where necessary to carry the boat away from corners. If the boat leaves the valid navigation area or remains irrecoverably stuck, return it to the most recent safe position with a short, gentle transition. Recovery preserves progression and has no penalty. Log unexpected recoveries for development so obvious level defects can be fixed rather than hidden.

## 5. The physical world and continuous route

Use an approximate courtyard footprint of `x = -4..4`, `z = -6..6` metres. The entire traversable surface is connected at `y = 0`. Raised tiles, planters and steps define boundaries; puddles and pools are visual descriptions of parts of this same water surface.

The main path winds around a few planters and a chair. It must not need a waterfall, changing water level, loading transition, teleport or disconnected basin. Wall and floor geometry imply the rest of the building while keeping the playable area compact.

### Proposed route centre points

These coordinates are an editable blockout guide, not an invisible rail. Build open channels around them so players can choose their line. The polyline is about 21.5 metres long before local curves and optional exploration.

| Point | Approximate `(x, z)` | Landmark / purpose |
| --- | --- | --- |
| A | `(-2.8, 4.6)` | Sheltered start below the wooden step |
| B | `(-1.2, 4.0)` | First open turn and leaf encounter |
| C | `(1.1, 3.1)` | Planter passages; a glimpse of the goal |
| D | `(2.6, 1.7)` | Edge of the chair shelter; route rejoins here |
| E | `(1.2, 0.3)` | Entry to the broad curved current |
| F | `(-1.5, 0.1)` | Sweeping line around the central planter |
| G | `(-2.3, -1.7)` | Runoff / crossing-current encounter |
| H | `(-0.8, -2.7)` | Sheltered fern passage |
| I | `(0.8, -1.5)` | Open arc with another destination glimpse |
| J | `(2.5, -2.4)` | Last sheltered turn before the sunny opening |
| K | `(1.4, -3.5)` | The destination pool becomes fully visible |
| L | `(2.1, -4.6)` | Companion boat and final arrival |

At ordinary exploratory speeds this route allows a few minutes of travel, with learning, choosing a line and a short detour providing the rest of the intended experience. Sustained gusting will shorten it, which is acceptable. Use one uninterrupted first-play observation to tune pacing rather than adding artificial gates.

### Two optional detours

**Chair shelter:** branch from the first planter area, pass beneath the rattan chair, then reconnect near D. Water is calmer, sounds feel sheltered, and a reflected window appears in the surface. The reward is a change of atmosphere. A starting length of 2–3 metres is enough.

**Hibiscus pocket:** branch from the fern section into a small open pocket behind a pot, then rejoin before J. A cluster of petals separates around the bow and slowly settles. Use the same petal response as the main path. A starting length of 1–2 metres keeps the detour brief.

Both branches must be readable as navigable water and return naturally to the route. They are optional discoveries, with no collectible checklist or completion requirement.

## 6. Five-minute pacing target

| First-play target | Beat | Player agency | Presentation |
| --- | --- | --- | --- |
| 0:00–0:40 | First movement | Leave shelter, steer around a leaf, feel the gust | Close detail, sparse sound, clear water and boat silhouette |
| 0:40–1:40 | Discovery | Weave between planters and optionally choose the chair passage | Larger objects establish scale; goal briefly reappears |
| 1:40–2:50 | Flow | Ride the curved current or cut across it with a gust | Wake and drifting petals show the chosen line; music develops |
| 2:50–4:10 | Anticipation | Cross the readable runoff, navigate the fern passage, optionally discover the hibiscus pocket | Shelter and sound change; warm destination becomes clearer |
| 4:10–5:00 | Arrival | Approach and gently nudge the companion boat | Shared drift, musical resolution and a restrained camera rise |

These times describe a desired experience, not time triggers. Entering a place or causing an interaction advances the presentation. If the player pauses, explores backward or moves quickly, the world remains coherent.

## 7. Moment-to-moment environmental response

Give each response a clear cause and keep it consistent:

- **Wake:** follows the actual boat path, bends during a turn and lengthens during a gust.
- **Petals:** drift with the local authored current, separate near the bow and settle gradually. Use a bounded population.
- **Leaf:** one light floating leaf near the start responds to contact or a close pass. Its movement should make the first interaction readable without stopping the boat.
- **Boat motion:** gentle bob and small turn lean communicate lightness; effects remain subtle enough for comfortable play.
- **Paper sound and wind:** grow during a gust and soften on release.
- **Shelter:** camera framing and premixed ambience change near the chair and ferns, using simple blends compatible with the chosen browser audio path.

An interaction should remain enjoyable after discovery. A passage may be revisited; petals and ambience should continue responding after the story beat is complete.

## 8. Camera direction

Use an elevated three-quarter follow camera with forward look-ahead. Show at least the next route choice; tune distance in the finished scene.

Use a small number of authored camera zones to adjust height and framing gradually. Low views belong in open spaces where they preserve visibility. Keep the normal camera corridor free of dense foliage and furniture; use collision handling or selective foreground fading only where necessary.

Avoid camera shake. Provide **Reduced camera motion**, which reduces bob, disables optional dramatic framing, and makes the final reveal a modest, slow adjustment or a user-triggered view. Any optional orbit should settle back gently when useful, without fighting the player's active input.

## 9. Goal, completion and linger state

The second boat uses the same asset family with a slightly different paper fold or drawing placement. It waits beside the sunny edge of the destination pool. It should be visible as the goal and accessible from more than one approach angle.

Use a simple state progression:

1. **Ready:** resources loaded; waiting for Begin.
2. **Exploring:** normal movement, optional detours and location-based presentation.
3. **Arrival available:** player enters the destination area; the companion is highlighted through composition and a small natural motion.
4. **Together:** gentle contact with the companion is detected once, using a forgiving proximity/contact threshold. The companion begins a controlled drift near the player.
5. **Linger:** the musical resolution and camera reveal finish; the player remains free to move, pause and restart.

Gentle contact is the positive completion action. Accept a slow approach from several directions. The player should not need to hit a tiny invisible target. If contact occurs at gust speed, soften the response and still allow completion.

Retain player steering during Together and Linger. A forgiving follow/drift rule keeps the companion nearby without rigid attachment or blocking. If the player accelerates away, the companion follows calmly or returns to a safe drift position.

A small **Journey complete** treatment may appear after the reveal, alongside **Keep drifting** and **Begin again**, without covering the boats. Pause and mute remain available. Completion must happen once per run; a restart returns every story, camera, audio and interaction state to the beginning.

## 10. Accessibility and comfort

- Full keyboard-only play and full gamepad play; automatic camera sufficient for both.
- Readable controls and pause UI at the smallest supported desktop browser size chosen during implementation.
- Separate music and effects volume, plus a simple master mute.
- Reduced camera motion available before Begin and in Pause.
- Clear shape and motion cues for currents; colour alone does not encode required information.
- Visible Pause, Restart and Mute actions for users who do not discover keyboard shortcuts.
- Pause on focus loss so leaving the tab does not carry the boat into an unexpected situation; resume deliberately with controls visible.
- No rapid flashing, compulsory precision timing, punishing collision, or mandatory mouse capture.

## 11. Art and narrative boundaries

Keep the mood warm, curious and quietly playful. The courtyard is inhabited through objects and distant ambience; it does not require animated people or animals. Use the sunny destination already present in the lighting composition. The ending can add petal motion, audio and a camera reveal without demanding a full dynamic time-of-day transition.

The matching star drawings establish the emotional link between the boats. Additional lore is optional production documentation and should not become opening exposition.

## 12. Design acceptance

The design succeeds when a new player can infer where to go, enjoys steering before reaching the goal, notices at least one small environmental response, and completes the final nudge without explanation. The final reveal should make the scale of the whole journey legible.

Use `MILESTONES_AND_ACCEPTANCE.md` to implement and evaluate the game in small, complete increments. Fix the observed source of confusion or discomfort before expanding the scene.
