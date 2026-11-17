# Environment and original mesh production

Implemented 17 November 2026. These are actual produced assets, rather than the kit's initial planned entries. Renderer review and playability evidence belong in BUILD_STATUS and release validation.

The source is `art-source/build_assets.py`, executed using Blender **5.2.3 LTS** (hash `e13b728c6880`). It writes editable individual `.blend` masters and nine runtime GLBs. No third-party mesh, material, texture or concept-image pixels are used in runtime scenery. The kit concept image remains an excluded visual reference.

Runtime assets:

| Asset | Content | Source |
| --- | --- | --- |
| `assets/models/paper_boat.glb` | Pinched diamond paper hull, double-sided interior trough, central folded ridge, three original blue pencil stars per side | `art-source/paper_boat.blend` and script |
| `assets/models/clay_pot_1.glb` | Standard thrown planter, rolled lip, inset earth | `art-source/clay_pot_1.blend` and script |
| `assets/models/clay_pot_2.glb` | Tall bulging planter | `art-source/clay_pot_2.blend` and script |
| `assets/models/clay_pot_3.glb` | Low broad planter | `art-source/clay_pot_3.blend` and script |
| `assets/models/fern.glb` | Thirteen curved fronds, paired tapered leaflets | `art-source/fern.blend` and script |
| `assets/models/pothos.glb` | Folded heart-shaped tropical leaves with visible veins | `art-source/pothos.blend` and script |
| `assets/models/rattan_chair.glb` | Open-legged chair with curved arms and woven cane back/seat | `art-source/rattan_chair.blend` and script |
| `assets/models/rain_chain.glb` | Sixteen copper cups on a central chain | `art-source/rain_chain.blend` and script |
| `assets/models/hibiscus.glb` | Branches, leaves and five-petal flowers | `art-source/hibiscus.blend` and script |

All were originally authored for this project by Codex. There are no external attribution obligations for these generated assets; user ownership follows the applicable service terms. This note does not grant a blanket licence for engine code, fonts or any future third-party materials.

`scripts/courtyard.gd` assembles the scenery. The floor is one 8×12 m surface at y=-.041, beneath the root-owned y=0 water. Original GLSL-compatible Godot shaders in `assets/materials/` create broad eight-petal floral tiles at .333m scale, with borders, worn teal/terracotta checker variation, clay patina and throwing bands, plaster wear and timber grain. These materials are analytic authoring sources, not textures derived from the supplied concept art.

The Blender +Y boat bow exports to Godot -Z, with +Y up in Godot. The logical origin is at waterline. The .18m boat has a .088m hull beam and .078m central ridge; a tiny submerged keel is cosmetic. Both boats reuse this source family. All glTF material surfaces are double-sided. Mesh triangle counts: boat876; pottery1600 each; fern6552; pothos1350; chair2652; chain1856; hibiscus474.

Route obstacle plan: main pots at (-.10,4.65), (.10,2.65), (-.30,1.05), (-.55,-1.35), (-2.95,-.45), (1.15,-3.05), (-2,-4.6). Colliders are smooth cylinders, independent of leaves and cosmetic detail. The chair at (3.02,2.88) has only four leg colliders, leaving its underpass open. The front boundary is a low parapet to preserve follow-camera visibility; side and rear plaster walls imply the shophouse. Timber steps near the beginning are raised above the boat.

The first browser render reported by integration exposed excessive foliage brightness, busy tile detail and step occlusion. The subsequent production pass darkened foliage to muted jade/moss, broadened tile motifs, removed fine floor sparkle and opened a central step recess through z5.07 so the starting boat is visible from the raised follow camera. GDScript check-only parsing passed in Godot4.6.3 after these changes; the revised appearance still requires browser observation by integration.

Rebuild from the project root:

```powershell
& 'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe' --background --python art-source/build_assets.py
```

Blender is needed only to regenerate models, not to import the project or export the game: the committed runtime assets are GLBs. Blender source masters and documentation have `.gdignore` exclusions and must remain out of the game pack.

## Submission-cost optimization

An integration browser observation on Intel HD620 reported approximately44FPS at the opening and31FPS at the chair (990×560). These numbers precede this optimization and are not evidence for the revised performance.

The original GLBs already merged all rods and leaflets sharing a material: the chair had2 runtime mesh nodes and the fern3, rather than one node per rod or leaflet. The revised exporter additionally applies modifiers and combines all surfaces into **one mesh node per reusable GLB**, preserving their material surfaces and the boat's paper thickness. Editable `.blend` sources retain the material-group structure. Material-surface counts remain boat3, pots3 each, fern3, pothos3, chair2, chain1, hibiscus4.

The main submission reduction is in `courtyard.gd`: **159 immutable box instances become8 MultiMesh material groups**, retaining all independent smooth gameplay colliders. This removes151 base-pass environment submissions, with corresponding shadow-pass savings when visible. At the snapshot before reimporting the one-node GLBs, a focused headless runtime instantiation reported8 groups,159 box instances and97 remaining ordinary mesh nodes, with no errors. GDScript checks also passed in Godot4.6.3. Neither check establishes improved browser FPS or unchanged rendered appearance; integration must observe the revised export.
