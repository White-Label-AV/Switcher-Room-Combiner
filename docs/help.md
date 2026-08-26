---
qds_version: "9.13.1 and above"
tested_hardware: "Host-side test harness (Lua 5.3) only — not yet verified in Q-SYS Designer or on a Core"
instance_limit: "No fixed limit, but see Important Notes on the script execution limit"
---

## Description

Room Combine Switcher mirrors the behaviour of the stock Q-SYS Room Combiner
component, but instead of mixing audio it synchronises *switchers*. Rooms are
joined and separated by walls using the same wall/room association model, so a
design that already describes its rooms and walls for audio can describe them
the same way here. When rooms are combined their switcher selections follow one
another; when they are separated, each room runs independently again.

On top of that it adds input restriction: each room can be limited to a subset
of the switcher's inputs. When rooms are combined, the group's allowed inputs
are the union of its members' — so combining grants each room access to the
others' sources, and separating returns each room to its own list.

The plugin drives no hardware itself. It exposes control pins that are wired to
whatever performs the actual switching — a video matrix plugin, a router
component, a Control Script, or logic elsewhere in the design.

## Prerequisites

None beyond the design itself. The plugin opens no network connection, needs no
credentials, and talks to nothing outside the Core.

Decide how many rooms, walls and switcher inputs the installation has before
placing the plugin: those three properties size every control array, and
changing them later breaks wiring to the pins that disappear.

## Configuration Overview

1. Drag the plugin into your schematic from **White Label AV → Room Combine
   Switcher**.
2. In the Properties pane set **Rooms**, **Walls** and **Inputs** to match the
   installation. Do this before wiring anything.
3. Turn on **Input Restriction** if rooms need to be limited to a subset of
   inputs. This reveals the per-room Mode and Inputs panel.
4. Press F5 to save the design to the Core and run it, or F6 to emulate.
5. Double-click the plugin to open its control panel.
6. Wire the **Room *r* Input** pins to whatever performs the switching. If you
   intend to use Auto switch, wire the switcher's active-source feedback back
   into **Input Active**.
7. For each wall, type the rooms it joins into that wall's **Wall Rooms** box.
   Lists and ranges both work — `1-4, 7`. Opening the wall combines everything
   associated with it.
8. Optionally populate **Input Name** so the per-room **Select Name** combo
   boxes read meaningfully.

## Important Notes

A component already placed in a design keeps its old code when the plugin is
updated. Delete it and re-add it, or reopen the design, to pick up a new
version.

Every plugin, Control Script and Block Controller in a design shares one thread
at 30 fps. The room-combine algorithm can exceed the Q-SYS script execution
limit when the number of rooms, walls or room/wall associations gets large.
Event-handler registration is already chunked across ticks — 32 rooms per tick
— to keep start-up inside the limit, but a very large design may still need the
room count kept down.

The plugin embeds no mixers, players or gain stages, so it consumes none of the
design's channel budget and multiple instances carry no shared resource cost.

Changing **Rooms**, **Walls** or **Inputs** resizes every control array and
breaks existing wiring to the pins that disappear. Set them before wiring.

Version 1.0.0.0 moved the plugin under **White Label AV** in the Schematic
Elements tree and removed a development suffix from its internal identifier. A
design that was built against the earlier `-compare` build will show the
component as missing and needs it re-placed.

## Known Issues

A room left with no valid inputs — **Allow** mode with an empty **Restrict
Inputs** list, or **Restrict** mode excluding every input — deselects and stays
deselected. Every one of its buttons is hidden and both of its text boxes
clear. When inputs are made available again the buttons reappear, but the room
is *not* re-selected automatically; click an input to bring it back. This is
deliberate: a room on no input is a legitimate state, and it is what makes
**Allow Toggle Off** work. Before 1.0.0.0 this combination raised a runtime
error instead.

A wall or restriction range entirely above the relevant count — `9-99` typed
into **Wall Rooms** on an eight-room design — echoes an inverted string such as
`9-8`. The parsed selection is correctly empty; only the text shown back is
wrong.

## Properties

### Rooms

How many rooms the plugin manages. Sizes the Room Select, Room LED, Select
Name, Restrict Mode and Restrict Inputs arrays, and creates one **Room *r*
Input** button array per room. Set it to the number of independently switchable
spaces in the installation, counting each divisible section separately.

### Walls

How many movable walls can join rooms. Each wall gets an open/closed button and
a box listing the rooms it joins. Count the physical partitions, not the rooms
— a single wall between two halls is one wall.

### Inputs

How many switcher inputs each room can select from. Sizes the Input Active and
Input Name arrays and every per-room button array. Set it to the number of
sources on the switcher this plugin drives.

### Input Restriction

Reveals the per-room restriction panel, letting each room be limited to a
subset of the inputs. Leave it off when every room may select every source —
the restriction logic is bypassed entirely and no buttons are hidden. The
Restrict Mode and Restrict Inputs controls keep their saved values while
hidden, so turning this off and on again does not lose the setup.

### Use Custom Colours

Uses the palette in **Custom Colours CSV** instead of the built-in room LED
colours. Turn it on to match the combine indicators to a house palette or to an
existing Room Combiner elsewhere in the design.

### Custom Colours CSV

The palette used for the room LEDs, as a comma-separated list with no spaces or
quotes — for example `Red,LimeGreen,Cyan,#7C0000`. Accepts `#RGB`, `#RRGGBB`,
CSS colour names, and HSV in the form `!HHSSVV`. The **last** entry is the
colour shown when a room is not combined; the entries before it are handed out
to combined groups in turn, so supply at least as many as the largest number of
simultaneous groups you expect. Only read when **Use Custom Colours** is on.

### Allow Toggle Off

Lets an input that is currently on be toggled back off, leaving the room on no
input at all. With **Inputs** set to 1 this turns the plugin into a
toggle-room-combiner, synchronising a single on/off state across combined rooms
instead of a source selection.

### Debug Print

How much the plugin writes to its debug window. **Function Calls** traces entry
into the switching and grouping functions; **All** additionally dumps each
room's and group's resolved valid-input list. The plugin version is printed at
start-up whatever this is set to. Leave it at **None** in production — these
functions run on every switch and every combine, and the output is costly on a
large design.

## Controls

### Link

When on, a switch request moves the whole group the room belongs to. When off,
only the room that was touched switches, even while it is combined with others.
This is the control that makes combining mean anything, so it is normally left
on and exposed to a UCI only where an operator genuinely needs to break a room
out temporarily.

### Auto

Enables auto switching. The group follows the most recently activated input
reported on **Input Active**, after a half-second delay, and falls back to the
previous live source when the current one drops. Requires **Input Active** to
be wired to real source-presence detection to be of any use.

### Wall Rooms

Which rooms this wall joins, as a list or range — `1-4, 7`. The entry is
sanitised and written back, so anything unparseable is discarded and the tidied
form appears in the box. A wall with no rooms listed joins nothing and has no
effect when opened.

### Wall Opens

Opens (on) or closes (off) the wall, combining or separating the rooms
associated with it. This is normally driven from a wall-position sensor or a
room-configuration UCI rather than touched directly.

### Room Select

The room's current input, by number. Writable — setting it requests a switch,
subject to the same validity checks as pressing the button. Reads back empty
when the room is on no input.

### Select Name

The room's current input, by name. The choices are repopulated from **Input
Name** whenever the group's valid inputs change, so the list only ever offers
sources the room may actually reach.

### Room LED

Lit when the room is combined with at least one other, and coloured to identify
which group it belongs to. Unlit when the room is standing alone. Panel
indicator only — it carries no pin, since the same information is available
from the room's group membership.

### Room 1 Input

Radio-style input selection for room 1. One of these arrays exists per room,
named for that room, each with one button per input. Buttons for inputs the
room may not currently reach are hidden rather than disabled, so an operator is
never offered a source that will be refused.

### Room 2 Input

Radio-style input selection for room 2, and so on for every room the **Rooms**
property creates. See **Room 1 Input**.

### Input Active

An input *to* the plugin: drive each of these from the corresponding source's
own presence or active detection. It feeds the Auto switch history and is what
lets a group follow a source that has just come alive. Leave unwired if Auto
switching is not used.

### Input Name

The display name for each input. Populates the **Select Name** combo boxes and
is otherwise cosmetic. Worth setting even when Select Name is unused, since the
names surface anywhere the plugin reports a source.

### Restrict Mode

How the room's input restriction is interpreted. **Bypass** allows every input.
**Allow** permits only those listed in **Restrict Inputs**. **Restrict** permits
everything *except* those listed. Enter the input list before changing the mode
— setting Allow against an empty list leaves the room with nothing it can
select. Hidden unless **Input Restriction** is on.

### Restrict Inputs

The input list that **Restrict Mode** acts on, as a list or range — `1-3, 6`.
Sanitised and written back on entry. Hidden unless **Input Restriction** is on.

## Release Notes

### 1.0.0.0

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
- Removed a hidden 1×1 development control that was never read. This removes a
  user pin; a design that wired it will show a missing pin.
- The plugin's internal identifier lost a `-compare` development suffix. A
  design placed with such a build must have the component re-placed.
- Source restructured into per-responsibility files and documented to the
  Q-SYS Library standard. Switching, combining and input-restriction behaviour
  is otherwise unchanged from 0.98.

### 0.98

- Per-room input restriction with Bypass, Allow and Restrict modes, with
  combined rooms pooling their allowed inputs.
- User-definable room LED colours via a comma-separated property.
- **Allow Toggle Off**, letting an active input be toggled back off and
  enabling single-input toggle-combiner use.
- Auto switch, following the most recently activated input per group.
- Select-by-name combo boxes alongside the numeric selectors.
- Button disable, sync option and auto switch additions by James Martin, QSC.
