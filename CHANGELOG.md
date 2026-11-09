# Changelog

<!-- Generated from docs/help.md by qsys-dev docgen. Do not edit. -->

## 1.0.0.0

- First release under the White Label AV brand: the plugin now appears under
  **White Label AV** in the Schematic Elements tree, and carries the shared
  WLAV brand header on its control panel.
- Added the **Debug Print** property. All automatic debug output is now gated
  behind it and silent by default; previously it printed unconditionally on
  every switch and every combine.
- Fixed a runtime error raised when a room was left with no valid inputs —
  **Allow** mode with an empty list, or **Restrict** mode excluding everything.
  The room now deselects cleanly instead. Present since 0.98.
- Fixed **Restrict Mode** and **Restrict Inputs** having no layout entry when
  **Input Restriction** was off, which left those controls unplaced.
- Removed the **Use Custom Colours** and **Custom Colours CSV** properties.
  The room LEDs now always use the built-in palette. A design that set custom
  colours keeps working, but its LEDs revert to the defaults; use the separate
  Custom LEDs plugin to recolour them.
- Removed a hidden 1×1 development control that was never read. This removes a
  user pin; a design that wired it will show a missing pin.
- The plugin's internal identifier lost a `-compare` development suffix. A
  design placed with such a build must have the component re-placed.
- Source restructured into per-responsibility files and documented to the
  Q-SYS Library standard. Switching, combining and input-restriction behaviour
  is otherwise unchanged from 0.98.

## 0.98

- Per-room input restriction with Bypass, Allow and Restrict modes, with
  combined rooms pooling their allowed inputs.
- User-definable room LED colours via a comma-separated property (removed
  in 1.0.0.0; see the Custom LEDs plugin).
- **Allow Toggle Off**, letting an active input be toggled back off and
  enabling single-input toggle-combiner use.
- Auto switch, following the most recently activated input per group.
- Select-by-name combo boxes alongside the numeric selectors.
- Button disable, sync option and auto switch additions by James Martin, QSC.
