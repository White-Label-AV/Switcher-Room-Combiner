-- Schematic-block identity: what the component looks like and what it wires to.

function GetPrettyName(props)
  -- Convention is "Model Version", with no newlines and no `~` — the tilde is
  -- a folder delimiter in PluginInfo.Name, and reads as a stray glyph here.
  return "Room Combine Switcher v" .. PluginInfo.Version
end

function GetColor(props)
  return {191, 226, 249} -- Same colour as the stock Room Combiner component
end

-- No audio or serial pins: everything this plugin exposes is a control pin,
-- and those are declared by GetControls.
function GetPins(props) return {} end

function GetComponents(props) return {} end

function GetWiring(props) return {} end
