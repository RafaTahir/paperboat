# After the Rain — Build and Public Delivery

Version 1.0 · 17 November 2026

This runbook is for Codex after it creates the game project. The handoff kit is a specification package, so the export commands below become usable only after `project.godot`, the scenes and a Web export preset exist.

## Delivery target

Deliver a public HTTPS URL where a desktop visitor can start the game without signing in. An unlisted link is acceptable if possession of the URL is sufficient to play. An owner-only preview, editor screenshot or local address is not the requested public delivery.

Use the user-assigned repository and an existing authorized hosting route when available. Inspect their configuration before changing it. Serve this game as static exported files; it does not need a backend, authentication database or paid service.

If no usable repository or hosting credentials are connected, still complete the local source, export and release package. State the exact missing access and provide the ready artifact and deployment instructions. Report publication as pending. Do not invent a deployed URL or describe a local export as live.

## 1. Prepare the exporter

1. Record the exact Godot editor version and selected Compatibility renderer in `docs/RELEASE_REPORT.md` when implementation begins.
2. Install or locate matching official Web export templates. Preserve other installed engine versions and projects.
3. Create an export preset named exactly `Web` in `export_presets.cfg`.
4. Use single-threaded export with extension support disabled. Enable only features the game actually needs. Leave PWA/service-worker behaviour out of the first release to keep update delivery simple.
5. Set `scenes/main.tscn` as the main scene, and ensure all runtime resources and audio are included. Exclude editable source art, this planning pack, raw unused downloads and generated build directories from the runtime pack.

Godot documents single-threaded web export as the preferred default; threaded exports require additional browser isolation configuration. Export the game directly as `index.html` and retain its generated companion filenames. [Official web guide][web]

## 2. Create a release export

The following Bash/WSL template assumes the project root is the working directory and the pinned Godot editor is available as `godot`. Substitute its actual executable path if needed. These are separate sequential commands; inspect failures before continuing.

```bash
godot --version
```

```bash
mkdir -p builds/web
```

```bash
godot --headless --path . --import
```

```bash
godot --headless --path . --export-release "Web" builds/web/index.html
```

Godot's command-line exporter requires an editor binary, a matching named preset and available export templates. The destination directory must already exist. [Command-line documentation][cli]

For subsequent releases, use a new empty output directory or deliberately remove only stale files within the known generated output directory. Avoid shipping a mixture of companion files from different builds.

A local development server can serve the single-threaded export:

```bash
python3 -m http.server 8080 --bind 127.0.0.1 --directory builds/web
```

On a Windows Python installation, `py -3 -m http.server` can be used in place of `python3 -m http.server`. Open `http://127.0.0.1:8080/` for the local smoke check. This address is a developer preview and must not be presented as the public result.

## 3. Hosting requirements

Upload the complete exported directory, including HTML, JavaScript, WASM, PCK and other generated companions. Keep relative paths intact if publishing under a subpath. Use a custom HTML shell in the source project for changes that must survive re-exporting.

Verify these delivery properties:

| Item | Required behaviour |
| --- | --- |
| URL | Public HTTPS with no account wall |
| `.wasm` | Serve as `application/wasm` |
| `.pck` | Serve as binary content, ordinarily `application/octet-stream` |
| Companion requests | Actual files returned successfully; no HTML fallback masquerading as JavaScript/WASM/PCK |
| Compression | Use the host's correctly configured gzip/Brotli support where available |
| Caching | HTML revalidates; release companions update together and cannot mix versions |
| Paths | Work at the final public path and after a normal refresh |
| Start action | Receives a genuine click/key interaction and enables audio |

Godot's web guide specifies the relevant MIME types, companion-file serving and user-gesture audio restrictions. [Official web guide][web]

Keep deployment atomic where the host supports it. If the provider has file-size limits, inspect them before choosing the upload format. Do not rename or precompress engine files without matching server configuration. Avoid blanket redirects that turn missing engine files into the landing page.

## 4. One focused public check

Open the final URL in a signed-out or private browser window and perform one complete run:

1. The start screen loads, the Start action works, and the paper boat responds.
2. Sound works after the activation gesture and can be muted.
3. Complete the main path, approach the other boat, observe the ending and restart.
4. Briefly check pause/resume, browser resize and the reduced-motion setting.
5. Check console and failed network requests for material runtime errors.

Use the milestone document for the movement and appearance criteria already checked during implementation. Re-run only the affected portions if a release defect is fixed. If a required browser or device cannot be accessed, state that limitation accurately.

## 5. Release record and files

Create `docs/RELEASE_REPORT.md` containing:

- Exact commit and engine version.
- Public playable URL and publication status.
- Browser, OS/GPU, viewport and relevant settings actually used.
- Whether a complete start-to-ending-to-restart run was observed.
- Measured payload and performance observations, clearly distinguished from targets.
- Known limitations and the smallest actionable remaining blocker, if any.
- Source and license completeness for every shipped asset.

Commit source, runtime assets, import settings, export presets, license records and reproducible build instructions. Keep secrets and bulky generated build history out of the repository. Respect the repository's established large-file handling; do not silently create Git LFS dependencies that the build environment cannot retrieve.

The user-facing delivery should lead with the playable URL, the few changes that matter, and any material limitation. Supply a downloadable web export archive and source access when available. The final claim must match the observed result: exported, uploaded and publicly playable are distinct milestones.

## Official references

Consulted 17 November 2026; use documentation matching the pinned editor when implementing.

[web]: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
[cli]: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
