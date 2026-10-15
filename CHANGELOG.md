# Changelog

All notable changes to the Room Combine Switcher plugin.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and
versions follow the Q-SYS `Major.Minor.Fix.Build` scheme rather than SemVer.

## [Unreleased]

### Known issues

- A wall/room range entirely above the room count (e.g. `9-99` with 8 rooms)
  echoes an inverted string such as `9-8`. The parsed selection is correctly
  empty; only the text shown back to the user is wrong. Present since 0.98.
- A room left with no valid inputs deselects and stays deselected; when inputs
  become available again it is not auto-selected. Deliberate — see *Fixed* under
  1.0.0.0.
- The room-combine algorithm can hit the script execution limit when the number
  of rooms, walls or room/wall associations gets large.

## 1.0.0.0 — 2026-08-19

First release under the White Label AV brand: a restructure, a rebrand and a
documentation pass over the 0.98 code, plus one crash fix and the debug
property the Verification Rubric requires.

The switching, combining and input-restriction behaviour is otherwise unchanged
— design-time control and layout output was compared against 0.98 across six
property configurations and matches exactly, apart from the intended 90 px
brand-header offset and the one control noted below.

### Added

- White Label AV brand header on the control panel, vendored as a git submodule
  from [wlav-plugin-brand](https://github.com/White-Label-AV/wlav-plugin-brand).
  All panel content now lays out from the offset the header returns.
- `PluginInfo` gains `Author`, `Manufacturer`, `Model`, `IsManaged` and `Type`.
  The Verification Rubric requires the first four of every plugin; `Type` and
  `Manufacturer` matter to Reflect-enabled plugins and are set for completeness.
- The plugin version is printed to the debug log at runtime start.
- **`Debug Print` property** (`None` / `Function Calls` / `All`, default `None`),
  the standard debug enum minus the Tx/Rx choices — this plugin drives no device
  and has no wire traffic, so those would be dead options. Every automatic
  `print()` in the runtime is now gated behind it; previously they ran
  unconditionally on every switch and every combine, which floods the debug
  window and costs time on the shared 30 fps thread. The version print at
  start-up stays ungated, as the Debug Requirements standard expects.
  `printmap()` and `printwalls()` remain unconditional: they are manual console
  helpers, never called automatically.
- `docs/help.md` and the generated `docs/pluginhelp.htm` — the help document
  required for Library submission. Every factual table in it is read from the
  plugin source at generation time, so it cannot drift; only the prose is
  authored. F1 on the plugin in Designer opens it.
- `CHANGELOG.md`, and a `NuGet` package definition for distribution through the
  Q-SYS Library.

### Changed

- **Source split from one 1272-line `.qplug` into `src/`**, assembled by PLUGCC
  `#include` directives from `src/plugin.lua`. Design-time definitions are one
  file each; the runtime is split by responsibility into `src/runtime/`.
- Plugin now appears under **White Label AV** in the Schematic Elements tree
  rather than "Room Combiner Add-ons".
- `GetPrettyName` returns `Room Combine Switcher v<version>`; the stray `~` is
  gone, as it is a folder delimiter in `PluginInfo.Name` and read as a literal
  glyph in a component label.
- Control-array normalisation now detects a lone control by shape rather than by
  `type(v) == "userdata"`. Behaviour on a Core is unchanged, but the plugin can
  now be loaded by the host-side test harness and the linter, which the userdata
  sniff prevented.

### Fixed

- **A room left with no valid inputs no longer raises a runtime error.**
  Selecting `Allow` restriction mode before entering any inputs (or `Restrict`
  mode excluding everything) produced an empty valid-input set; `groupInputSync`
  then passed `groupValidInputs[1]` — nil — into `roomSwitch`, which
  dereferenced `Controls["Input Name"][nil]`. Present since 0.98.

  A nil input is now handled as the real state it represents: every button goes
  off and both text boxes clear. `roomSwitch` is the fix site because all four
  nil paths pass through it — including `userSwitch` reverting to a
  `currentInput` that is itself nil, which crashed the same way.
  `InputNameFromNumber` also tolerates nil and out-of-range indices, since
  `UpdateComboString` reaches it via `tonumber()` on a possibly-empty box.

  `Room Select` now clears to `""` rather than the literal string `"nil"`,
  which is what init already treats as "unset".

  **The room is not auto-selected when inputs become available again** — the
  buttons reappear and can be clicked, but nothing switches on its own. A nil
  current input stays a deliberate "off" state, which is what makes *Allow
  toggle off* work; overriding it here would fight the user.
- `Restrict Mode` and `Restrict Inputs` had no layout entry when the **Input
  Restriction** property was off, leaving the controls unplaced. They are now
  declared `Style = "None"`, which keeps the control and its saved value alive
  while drawing nothing.

### Removed

- The `code` control — a 1×1 px hidden text box its own comment marked "DEV ONLY
  REMOVE LATER". It was declared and laid out but never read or written.
  **This removes a user pin**; a design that wired it will show a missing pin.

### Fixed identity

- `PluginInfo.Id` loses its `-compare` suffix, which was a side-by-side
  development artefact. **Designs placed with a `-compare` build must have the
  component re-placed.**

## 0.98 — earlier

Prior history is in the git log; this changelog starts at the 1.0.0 release.

- Input restriction per room with three modes (Restrict, Allow, Bypass), with
  combined rooms pooling their allowed inputs.
- User-definable LED colours via a comma-separated property.
- "Allow toggle off" property, letting an active input be toggled back off and
  enabling single-input toggle-combiner use.
- Auto switch, following the most recently activated input per group.
- Button disable, sync option and auto switch additions by James Martin, QSC.
