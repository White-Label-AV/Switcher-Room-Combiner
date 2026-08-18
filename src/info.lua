-- Plugin identity. build.py rewrites Version and BuildVersion in place on a
-- bump, so this file is the single source of truth for what shipped.
PluginInfo = {
  Name         = "White Label AV~Room Combine Switcher",
  Version      = "1.0.0.0",
  BuildVersion = "1.0.0.0",
  Id           = "d2702557-f548-48bb-858d-d7c43f0ce5ee",
  Author       = "Joshua Cerecke",
  Description  = "Multi-room switcher that mirrors the Q-SYS Room Combiner, synchronising switcher selection instead of mixing audio, with optional per-room input restriction.",
  Manufacturer = "White Label AV",
  Model        = "Room Combine Switcher",
  IsManaged    = false,
  Type         = "control",
  ShowDebug    = true,
}
