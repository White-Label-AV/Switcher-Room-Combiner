-- Room Combine Switcher — PLUGCC entry point.
--
-- By Joshua Cerecke, White Label AV — joshua@whitelabelav.co.nz
-- Button disable, sync option and auto switch additions by James Martin, QSC.
--
-- Every #include lives in this file. build.py resolves them recursively but
-- QSC's PLUGCC.exe does not, so an include nested inside an included file is
-- silently left as a comment there.
--
-- Order matters: design-time definitions must precede the runtime block.

--[[ #include "info.lua" ]]

-- Shared White Label AV brand band. Both files are needed, at file scope,
-- before anything calls WLAVHeader.Draw.
--[[ #include "../vendor/wlav-brand/brand.lua" ]]
--[[ #include "../vendor/wlav-brand/header.lua" ]]

--[[ #include "model.lua" ]]
--[[ #include "properties.lua" ]]
--[[ #include "controls.lua" ]]
--[[ #include "layout.lua" ]]

-- Runtime. Controls is nil at design time, so nothing below runs in QDS until
-- the design is emulated or deployed. The runtime is split by responsibility;
-- definition order does not matter to Lua, but init must follow the functions
-- it calls and the handlers must follow init.
if Controls then
--[[ #include "runtime/util.lua" ]]
--[[ #include "runtime/inputs.lua" ]]
--[[ #include "runtime/switching.lua" ]]
--[[ #include "runtime/grouping.lua" ]]
--[[ #include "runtime/user_actions.lua" ]]
--[[ #include "runtime/init.lua" ]]
--[[ #include "runtime/handlers.lua" ]]
end
