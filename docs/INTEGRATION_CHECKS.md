# Integration verification

Observed on 17 November 2026 using `Godot Engine v4.6.3.stable.official.7d41c59c4` on Windows. These are headless simulation checks of the real scene and scripts. They do not establish browser presentation, audible sound, physical gamepad operation, frame rate or first-time player comprehension.

## Reproduce

From the directory containing `project.godot`:

```powershell
& 'C:\Users\User\.cache\codex-runtimes\godot-4.6.3\Godot_v4.6.3-stable_win64_console.exe' --headless --fixed-fps 60 --path . --script art-source/check_game.gd
```

`--fixed-fps 60` removes real-time synchronization while preserving a 60 Hz simulation timestep. The script loads `scenes/main.tscn`, invokes the real Begin/restart/pause methods, and supplies movement with `Input.action_press()`. It does not bypass the boat controller or collisions. The source lives under the import-excluded `art-source/` directory and is not part of the public game.

For a focused arrival/restart/pause check that skips the already-observed full route:

```powershell
& 'C:\Users\User\.cache\codex-runtimes\godot-4.6.3\Godot_v4.6.3-stable_win64_console.exe' --headless --fixed-fps 60 --path . --script art-source/check_game.gd -- --arrival-only
```

## Observed results

The full integration run completed **39 checks, zero failures**, with process exit code 0.

| Risk | Observed result |
| --- | --- |
| Loaded scene accidentally moves before Begin | START state and disabled controller confirmed; Begin enables EXPLORE. |
| Main route or detours are disconnected | Input-only navigation reached all 17 targets, including the chair's south opening, center and north opening, the curved sweep, runoff, fern passage and hibiscus pocket before rejoining. No position changes or teleports occurred during this traversal. |
| Recovery hides a route defect | Full traversal required zero recoveries. |
| Discoveries cannot be reached | `chair`, `current`, `runoff`, `hibiscus` and `sunny` all triggered. |
| Contact ending cannot be reached through ordinary play | The final input approach triggered TOGETHER. |
| Arrival removes control | Input moved the player more than 0.13 m during the camera rise; LINGER retained an enabled controller. |
| Repeated contact restarts the ending | Arrival time continued advancing after LINGER rather than resetting. |
| Replay retains old state | Restart cleared chapters and arrival state, restored both boats and player velocity, reset camera reveal and ending UI, and returned floating details to their origins. |
| Proximity alone completes the game | A stationary setup 0.12 m from the companion remained EXPLORE for 120 ticks with no movement input. |
| Arrival works from only one direction or speed | After explicit arrival-only setup, a slow south approach and a gusting west approach each completed within five seconds. Both retained steering. These setups repositioned the player and are separate from the full route evidence. |
| Pause only changes the panel | Player position and game time remained unchanged for 60 paused ticks; Resume unpaused and closed the panel. |

The practiced route, with gust held for navigation, covered **24.3 m in 100.3 simulated seconds**. Completion triggered at approximately 100.1 seconds. This is a deliberately efficient automated route and does **not** measure the approximately five-minute exploratory first-visit target.

The initial full test finished with Godot resource-in-use messages because the test exited while its scene was still alive. Test teardown now explicitly frees the scene. The subsequent focused run completed **15 checks, zero failures**, exit code 0, without cleanup warnings. Gameplay source did not need to change for that correction.

## Earlier isolated controller check

Before integration, the same engine ran an isolated controller scene at 60 Hz. Ordinary movement covered 0.2392 m in two seconds; diagonal movement covered 0.2396 m; gust movement covered 0.4276 m. Release retained coasting and subsequently settled below 0.016 m/s. The physical root remained on the water plane. A wall prevented penetration while diagonal movement slid along it. Leaving the bounds returned the boat to its saved open-water pose. A grid of 9,801 current samples was finite, planar and at or below the 0.052 m/s cap. All isolated assertions passed.

## Remaining observation requirements

Browser play must still establish visual route readability, comfortable camera framing, perceived steering quality, loading/failure feedback and first-interaction sound. A physical controller must establish its mapping and menu usability. An uninterrupted unfamiliar-player visit must establish exploratory pacing. Those claims should be recorded separately from this headless evidence.
