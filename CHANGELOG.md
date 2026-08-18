# Changelog

All notable changes to the Room Combine Switcher plugin.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and
versions follow the Q-SYS `Major.Minor.Fix.Build` scheme rather than SemVer.

## [Unreleased]

### Known issues

- **Selecting "Allow" restriction mode before entering any inputs crashes the
  plugin.** The room is left with an empty valid-input set, `groupInputSync`
  takes `groupValidInputs[1]` (nil) and `roomSwitch` then dereferences
  `Controls["Input Name"][nil]`. Workaround: type the allowed inputs into
  **Restrict Inputs** *before* changing **Restrict Mode**. The same fault occurs
  in "Restrict" mode if every input is excluded. Present since 0.98.
- A wall/room range entirely above the room count (e.g. `9-99` with 8 rooms)
  echoes an inverted string such as `9-8`. The parsed selection is correctly
  empty; only the text shown back to the user is wrong. Present since 0.98.
- The room-combine algorithm can hit the script execution limit when the number
  of rooms, walls or room/wall associations gets large.

## [1.0.0.0] — 2026-08-18

First release under the White Label AV brand. No functional change to switching,
combining or input restriction — this release is a restructure, a rebrand and a
documentation pass over the 0.98 code.

### Added

- White Label AV brand header on the control panel, vendored as a git submodule
  from [wlav-plugin-brand](https://github.com/White-Label-AV/wlav-plugin-brand).
  All panel content now lays out from the offset the header returns.
- `PluginInfo` gains `Author`, `Manufacturer`, `Model`, `IsManaged` and `Type`,
  all required by the Q-SYS Library Verification Rubric.
- The plugin version is printed to the debug log at runtime start.
- `docs/pluginhelp.htm` — the help document required for Library submission.
  F1 on the plugin in Designer opens it.
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

## [0.98] — earlier

Prior history is in the git log; this changelog starts at the 1.0.0 release.

- Input restriction per room with three modes (Restrict, Allow, Bypass), with
  combined rooms pooling their allowed inputs.
- User-definable LED colours via a comma-separated property.
- "Allow toggle off" property, letting an active input be toggled back off and
  enabling single-input toggle-combiner use.
- Auto switch, following the most recently activated input per group.
- Button disable, sync option and auto switch additions by James Martin, QSC.
