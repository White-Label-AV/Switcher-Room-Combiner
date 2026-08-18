# Room Combine Switcher

A Q-SYS plugin that mirrors the stock **Room Combiner** component — except that
instead of mixing audio, it synchronises *switchers*.

Rooms are joined and separated by walls exactly as they are in the Room Combiner.
When rooms are combined, their switcher selections follow each other; when they
are separated, each room goes back to running independently. On top of that it
adds **input restriction**, so each room can be limited to a subset of the
switcher's inputs, and combined rooms pool the inputs their members are allowed.

Authored by [White Label AV](https://whitelabelav.co.nz). Button disable, sync
option and auto switch additions by James Martin, QSC.

## Features

- **Room combining driven by walls**, using the same wall/room association model
  as the stock Room Combiner. Groups are named after their lowest room number,
  so group identity is stable regardless of the order walls were opened.
- **Input restriction, per room, in three modes** — `Bypass` (all inputs),
  `Allow` (only the listed inputs) and `Restrict` (all except the listed
  inputs). Combined rooms take the **union** of their members' allowed inputs,
  so combining grants each room access to the others'. Separating reverts each
  room to its own list.
- **Custom LED colours.** Match the room LEDs to your own palette with a
  comma-separated list. Accepts `#RGB`, `#RRGGBB`, CSS colour names and HSV in
  the form `!HHSSVV` — e.g. `Black,White,#FFFFFF`, no spaces or quotes. The last
  entry is the OFF colour; the rest cycle across combined groups.
- **Allow toggle off.** Lets an input that is currently on be toggled back off.
  With a single input this turns the plugin into a toggle-room-combiner,
  synchronising toggle states across rooms.
- **Auto switch.** Tracks which inputs have gone active (via the `Input Active`
  pins) and follows the most recent one per group.
- **Select by name.** Each room has a combo box listing the names of the inputs
  it is currently allowed, alongside the numeric selector.

<!-- qsys-dev:install start -->
## Installation

No public NuGet feed is configured for this plugin yet, so install it manually:
download the `.qplug` from
[Releases](https://github.com/jcerecke/Switcher-Room-Combiner/releases) and drop
it into

```
%USERPROFILE%\Documents\QSC\Q-Sys Designer\Plugins
```

Restart Q-SYS Designer. The plugin appears under **Schematic Elements → White
Label AV → Room Combine Switcher**.

Once a feed exists, `nupkg.py --push` rewrites this section in place with the
Q-SYS Library steps and the feed's registration URL.
<!-- qsys-dev:install end -->

## Configuration

Set these in the Properties pane before wiring anything — `Rooms`, `Walls` and
`Inputs` size every control array on the component.

| Property | Type | Default | Range | Description |
| --- | --- | --- | --- | --- |
| Rooms | integer | 2 | 2–256 | Number of rooms to manage |
| Walls | integer | 1 | 1–256 | Number of walls that can join rooms |
| Inputs | integer | 2 | 1–128 | Number of switcher inputs |
| Input Restriction | boolean | false | — | Shows the per-room restriction panel |
| Use Custom Colours | boolean | false | — | Use the CSV below instead of the built-in LED colours |
| Custom Colours CSV | string | *(empty)* | — | Comma-separated colours, last one is the OFF colour |
| Allow Toggle Off | boolean | false | — | Lets an active input be toggled back off |
| Debug Print | enum | None | None / Function Calls / All | Debug verbosity. `Function Calls` traces switching and grouping; `All` adds the resolved input lists |

Associate rooms with a wall by typing room numbers into that wall's **Rooms**
box — ranges and lists both work, e.g. `1-4, 7`. Opening the wall combines
everything associated with it.

Full control and pin tables are in [`docs/pluginhelp.htm`](docs/pluginhelp.htm),
which is also what F1 opens in Designer.

## Known issues

- A wall/room range entirely above the room count (e.g. `9-99` with 8 rooms)
  echoes an inverted string like `9-8`. The selection itself is correctly empty.
- A room left with **no** valid inputs — `Allow` mode with an empty list, or
  `Restrict` mode excluding everything — deselects and stays deselected. When
  inputs are made available again the buttons reappear but the room is not
  auto-selected; click an input to bring it back. This is deliberate: a nil
  current input is a legitimate "off" state that the plugin does not override,
  which is also what makes *Allow toggle off* work.
- The room-combine algorithm can hit the Q-SYS script execution limit when the
  number of rooms, walls or associations gets large.

## Development

The plugin is assembled from `src/` by the PLUGCC `#include` directives in
`src/plugin.lua`. Never edit a built `.qplug` — it is generated.

```
src/plugin.lua        PLUGCC entry point; every #include lives here
src/info.lua          PluginInfo — the single source of truth for the version
src/model.lua         GetPrettyName, GetColor, GetPins, GetComponents, GetWiring
src/properties.lua    GetProperties
src/controls.lua      GetControls
src/layout.lua        GetControlLayout — draws the brand header, then the panel
src/runtime/          the `if Controls then` block, split by responsibility
vendor/wlav-brand/    shared WLAV brand header (git submodule)
docs/pluginhelp.htm   help document; F1 in Designer opens it
```

`src/runtime/` is included in dependency order: `util` (array normalisation,
parsing) → `inputs` (valid-input resolution) → `switching` → `grouping` →
`user_actions` → `init` (state, runs after the functions it calls) →
`handlers` (registered last, once state exists).

Clone with the submodule, or the build will fail on a missing brand header:

```bash
git clone --recurse-submodules https://github.com/jcerecke/Switcher-Room-Combiner.git
```

Build, lint and deploy with the [`qsys-dev`](https://github.com/White-Label-AV/qsys-dev)
toolchain:

```bash
python3 scripts/build.py src/plugin.lua --watch --deploy
```

```bash
python3 scripts/qsys_lint.py src/plugin.lua
```

### Outstanding rubric gaps

The linter reports three warnings, none of which block use:

- **QP009 ×2** — the plugin sets `.Color` on the room LEDs at runtime. This is
  the custom-colour feature; the stock Room Combiner does the same. Rubric §8
  wants generic styling, so this needs a waiver or a rework before a Library
  submission.
- **QP035** — no `Status` indicator. Rubric §1 requires one of *device* plugins;
  this is a control plugin with no device to report on.

Both also block `release.py`, which lints `--strict` with no waiver flag.

## Roadmap

- Optimise `findRoomGroups()` so more rooms fit inside the execution limit.
- Algorithmically generate a distinct colour per room LED — `defaultH_Values` in
  `src/runtime/init.lua` already holds 256 evenly-spread HSV hues for this.
- "Uncombine action" — return to a default input, or to the previous value, when
  a room separates.
- Make the auto-switch delay a user-editable field, probably per room.

## Licence

See [LICENSE](LICENSE).
