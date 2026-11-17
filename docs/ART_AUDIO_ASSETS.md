# After the Rain — Art, audio and asset brief

**Status:** production instructions and sourcing plan. The supplied image is concept art; production models, textures, shaders and audio still need to be created or acquired. The inventory in `docs/asset_register.csv` records that distinction explicitly. Design targets below are starting points, not measured performance results.

## 1. Visual north star

Use `reference/after-the-rain-concept.png` to establish composition, colour, materials and the feeling of a small world after tropical rain. Build an original, playable interpretation. The image is neither a game screenshot nor a 3D asset, texture atlas, reflection map or source of usable geometry.

The setting is one intimate Malaysian shophouse courtyard. Its identity comes from patterned tiles, weathered timber, clay pots, trailing plants, a rattan chair and the sound of water falling from a rain chain. Keep the treatment warm and lived-in. A few metres of ordinary surroundings should feel enormous to the boat.

| Element | Direction |
| --- | --- |
| Palette | Faded teal, terracotta, muted leaf greens, warm ivory paper and amber light. Keep the boat distinguishable in both sunlight and shade. |
| Shape language | Believable proportions with clean silhouettes. Gentle asymmetry, worn edges and a few handmade details. |
| Lighting | One coherent late-afternoon setup: warm direct light, cooler sheltered areas, readable soft fill. Preserve this base through the ending. |
| Composition | A visible sunny destination; sheltered passages between planters; a clear water route below the foliage. |
| Material hierarchy | Highest attention on boat, water, nearby tile and pot surfaces. Distant walls support the composition with simpler detail. |
| Motion | Slow leaves, individual drops, restrained paper flutter and wakes responding to steering. The world should remain calm enough to read. |

Resolve the polished 30-second bend around one planter first. Make that boat, water, light and sound treatment the standard for the complete scene.

## 2. Production assets and priorities

**P0** supports the first polished playable section. **P1** completes the intended journey. **P2** is optional refinement after the complete arc works. Reuse meshes with controlled scale, colour and placement variation.

| Priority | Asset family | Planned scope and use |
| --- | --- | --- |
| P0 | Hero paper boat | One original folded mesh, legible blue pencil stars, subtle fold shading and an imperfect corner. |
| P0 | Courtyard shell | Modular floor, short boundary walls, one timber step and one window; simple collision separate from detail. |
| P0 | Patterned tile material | One coherent repeating design with restrained wear; normal and roughness detail should remain subtle at boat height. |
| P0 | Clay planters | Three silhouettes using one shared material family. Their placement defines the first sweeping turn. |
| P0 | Foliage | Two or three fern/leaf clusters; reuse for scale and framing while preserving route visibility. |
| P0 | Water and wake | One water material, readable moving surface detail, boat wake and occasional small impact ripples. |
| P0 | Floating petals/leaves | Two or three lightweight shapes that reveal current direction and respond to nearby boat movement. |
| P0 | Lighting/reflection setup | Authored scene lighting and a modest environment reflection appropriate to Compatibility. |
| P1 | Second boat | Reuse the hero mesh with a different arrangement of matching pencil stars. |
| P1 | Rattan chair | One recognisable silhouette; the passage below it remains clear and comfortably navigable. |
| P1 | Rain chain and downpipe | Simple repeated links/cups, a small water effect and sound; decorative detail avoids collision traps. |
| P1 | Audio set | Three music stems and ten sound families specified below. |
| P1 | Minimal UI | Readable title, control hints and settings, using a small set of original shapes or verified CC0 icons. |
| P2 | Extra surface detail | A few moss patches, seams, worn corners and selected foreground details within the established style. |

### Scale and modelling conventions

Use metres in authoring scenes. The hero boat starts at approximately **0.18 m long, 0.09 m wide and 0.08 m high**; adjust it with camera and route testing. The courtyard remains approximately 8 × 12 m. Tile modules around 0.20–0.30 m and ordinary furniture proportions make the scale readable.

Godot's world uses +Y up and the logical boat bow points toward **-Z**. Place the boat's logical origin at its waterline. Correct any imported orientation through the visual child transform, preserving the controller's coordinate convention. Movement remains on the fixed water plane; visible draft, bob and roll belong to the visual model.

Use modest geometry first: a hero boat in the low thousands of triangles, simplified circular pots, leaf clusters with controlled overlap, and one chair whose silhouette carries most of its detail. These are starting budgets; measure the actual scene before increasing density. Keep simple, smooth gameplay collision independent of tiny decorative features.

## 3. Blender work package

Use the connected Blender MCP if available. The same work may be performed through Blender's supported scripting interface when necessary. Retain editable masters in `art-source/`; export runtime `.glb` assets to `assets/models/`. The authoring directory is excluded from Godot import through its `.gdignore` and from release export. Godot recommends glTF 2.0 and supports `.glb`; direct `.blend` import invokes an installed Blender, so exported runtime assets keep the game build simpler.[1]

Run these tasks in order:

1. **Boat:** create an original folded-paper silhouette with visible inner faces and carefully chosen creases. Give it a usable UV layout and a simple paper material. Author the blue pencil stars directly as original texture artwork. Preserve a readable silhouette at normal gameplay distance.
2. **First corner:** create a floor section, one planter and a small fern cluster at real scale. Export them separately so gameplay and placement remain editable in Godot.
3. **Reusable environment kit:** make the remaining pot silhouettes, courtyard wall/step/window pieces, chair and rain-chain kit. Share materials wherever sensible.
4. **Finishing assets:** derive the companion boat from the same master and add the petal/leaf variants. Keep source and runtime filenames predictable.

Apply transforms, inspect normals, establish deliberate origins and export only intended objects. Preview every imported asset in the actual Godot renderer. Blender node networks and viewport lighting are authoring tools; recreate unsupported effects with suitable Godot materials. Supply lightmap UVs where the technical lighting plan requires them.

**Focused boat task for Codex/Blender:**

> Create an original folded paper boat for After the Rain, nominally 0.18 m long. It should read as a delicate handmade object in a cinematic miniature courtyard. Use ivory paper, faint original blue pencil stars, crisp folds, visible interior surfaces and one subtly imperfect corner. Optimise the mesh for a close third-person browser game. Keep its logical waterline origin and Godot-facing bow convention documented, preserve the editable Blender master, and export a clean GLB. Judge its silhouette and material in Godot Compatibility under the project's light before adding more detail.

## 4. Materials, water and browser practicality

Use a small shared material set. Start with 1K maps for reused props and 2K only where the hero or close floor clearly needs it. Derive smaller runtime textures from retained originals. Avoid stacking unrelated texture packs with different scale, colour temperature and weathering.

Represent wetness through deliberate roughness, colour and highlight treatment. Do not bake a photograph's sunlight or reflections into base colour and then add a second contradictory lighting setup. A high-resolution wet-tile photo is not automatically a usable PBR material.

The browser target uses Compatibility. Build the look with supported materials, baked or otherwise economical lighting, and a controlled reflection strategy. The renderer has reflection probes and can render baked lightmaps; its feature table distinguishes these from Forward+ effects such as screen-space reflections and volumetric fog.[2] Reflections may suggest the courtyard without reproducing every moving object exactly.

Prefer a single, economical water surface with restrained surface detail and clear edges. If translucency causes sorting or depth problems, retain the art direction using a mostly opaque treatment with carefully painted depth colour. The gameplay route must stay readable. Keep foliage overlap controlled and use suitable cutout rendering where appropriate. Avoid making a convincing scene depend on multiple layers of transparent water, mist and leaves.

## 5. Sound and music brief

Audio should make the boat feel delicate and the courtyard feel inhabited. Quiet details need room in the mix. Keep rain as residual dripping and runoff; the main storm has passed.

### Three musical stems

Create a small original theme or obtain appropriately licensed music with genuinely separable stems. All stems share the same tempo, length and musical alignment. A starting direction is 70–80 BPM, a restrained pentatonic motif and soft acoustic or bell-like timbres. The composition should be original, without quoting the referenced games' melodies.

| Stem | Suggested loop | Behaviour |
| --- | --- | --- |
| `music_calm` | 48–64 seconds | Sparse warm harmonic bed, present quietly from the start. |
| `music_motion` | Same length | Soft pulses or light plucked notes, faded in during flowing travel. |
| `music_arrival` | Same length | Gentle melodic resolution, introduced near the sunny destination. |

Keep stems aligned and alter volume with slow fades. Original audio can be composed or synthesised offline and exported as files; a paid API is not a prerequisite. Preserve source composition/render settings. Browser audio starts after the user's initial interaction. Follow `TECHNICAL_SPEC.md` for playback mode; keep important ambience and reverb in the exported samples so the intended mix does not depend on unsupported runtime effects.[3]

### Ten sound families

Durations below are production suggestions. Variants in a family share an asset-register entry until individual source provenance requires separate rows.

| Family | Suggested duration | Purpose |
| --- | --- | --- |
| Courtyard ambience | 45–90 s loop | Air, distant indistinct household activity and calm outdoor space. |
| Water lap | 10–20 s loop | Very quiet near-boat water texture, modulated by movement. |
| Gust | 0.5–1.5 s | Immediate but soft response to the gust input. |
| Leaf drip | 0.1–0.5 s, 3 variants | Sparse positional detail and small visual ripples. |
| Paper flutter | 0.3–1 s | Short, delicate movement response. |
| Hull bump | 0.1–0.4 s, 2 variants | Soft contact with a pot or the companion boat. |
| Leaf/petal brush | 0.1–0.5 s | Subtle feedback from nearby floating objects. |
| Rain chain | 1–3 s | Localised trickle and occasional metallic contact. |
| Wind chime | 2–5 s | A rare courtyard accent, also suitable for a restrained menu cue. |
| Arrival accent | 3–6 s | A small original resolving chord compatible with the music. |

Use loop crossfades, clean starts, consistent gain and conservative peaks. Listen to the final mix in the target browser with ordinary speakers and headphones. Provisional synthetic sounds may unblock implementation; keep them marked provisional until they pass the listening review. The mute controls must cover every audio layer.

## 6. Asset acquisition and provenance

The default plan uses original project meshes and free assets whose permitted use is clear. These are **candidate sources**, not files already downloaded or individually approved:

| Source | Appropriate use | Verified source policy and acquisition note |
| --- | --- | --- |
| [Poly Haven](https://polyhaven.com/) | Selected materials, environment maps and suitable prop bases | Its asset licence is CC0.[4] Choose currently free public downloads; some Vault assets have early-access restrictions even though their asset licence is CC0.[5] |
| [ambientCG](https://ambientcg.com/) | Material maps for timber, plaster, clay and related surfaces | Its documentation identifies its downloadable assets as CC0.[6] Select a coherent set at modest resolution. |
| [Kenney](https://kenney.nl/assets) | Small UI assets and selected sound bases | Its asset pages use CC0; the source policy asks users to consult the pack's included licence.[7] Its [Impact Sounds](https://kenney.nl/assets/impact-sounds) pack is a candidate for soft contact source material, not a guaranteed final match. |
| [Freesound](https://freesound.org/) | Individually selected natural drips, water, paper and wind | Licences vary by sound.[8] Prefer CC0; use CC BY only with complete attribution. Record the actual item, creator and licence. |

Do not treat a catalogue URL as exact asset provenance. When selecting an item, record its exact page, author, licence version, downloaded file and any attribution. Retain the included licence or evidence in the project, record modifications, and update the register status. Copy third-party attribution requirements into the game's credits and distribution notices. Respect download access requirements; use another permitted source or an original substitute if access blocks progress.

Registry statuses:

- `PLANNED_NOT_CREATED`: original project asset still to be authored.
- `PLANNED_NOT_DOWNLOADED`: external candidate still to be selected/acquired; its register licence is pending item review.
- `PROVISIONAL`: present and usable for implementation, pending final visual/audio judgment.
- `READY`: actual runtime asset exists, provenance is complete, and it has been checked in the game.

## 7. Finish standard

The art/audio pass is complete when the boat is readable throughout the route; the water and wake agree with its movement; scale and materials remain consistent; foreground foliage preserves navigation; the complete mix plays correctly after the start gesture; and the final scene contains no asset falsely marked acquired or ready. Review the opening bend, sheltered passage and final reveal at the actual gameplay resolution.

## Sources checked 17 November 2026

1. Godot, [Available 3D formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html).
2. Godot, [Overview of renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).
3. Godot, [Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
4. Poly Haven, [Asset licence](https://polyhaven.com/license).
5. Poly Haven, [Vaults](https://polyhaven.com/vaults).
6. ambientCG, [Licence information](https://docs.ambientcg.com/license/).
7. Kenney, [Support and asset licence policy](https://kenney.nl/support).
8. Freesound, [FAQ: licences](https://freesound.org/help/faq/).
