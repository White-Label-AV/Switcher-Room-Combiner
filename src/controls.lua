-- Runtime control surface. Every array is sized from a property, so the shape
-- of Controls changes with the design-time configuration.
--
-- GOTCHA: an array declared Count = N is named "Name 1".."Name N" for pins and
-- layout keys, but the runtime reaches it as a table under the BASE name —
-- Controls["Room Select"][3], never Controls["Room Select 3"]. When Count == 1
-- Q-SYS hands back the bare control instead of a table; runtime/util.lua
-- normalises that away once, up front.

function GetControls(props)
  local ctrl = {}

  -- Reserved control name. There is no device to report on, so this carries
  -- plugin health instead: COMPROMISED when a restriction has left a room with
  -- nothing it may select, otherwise OK with the current combine summary.
  table.insert(ctrl, {
    Name = "Status",
    ControlType = "Indicator",
    IndicatorType = "Status",
    Count = 1,
    UserPin = true,
    PinStyle = "Output"
  })

  table.insert(ctrl, {
    Name = "Link",
    ControlType = "Button",
    ButtonType = "Toggle",
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })

  table.insert(ctrl, {
    Name = "Wall Rooms",
    ControlType = "Text",
    Count = props["Walls"].Value,
    UserPin = true,
    PinStyle = "Both"
  })
  table.insert(ctrl, {
    Name = "Wall Opens",
    ControlType = "Button",
    ButtonType = "Toggle",
    Count = props["Walls"].Value,
    UserPin = true,
    PinStyle = "Both"
  })
  table.insert(ctrl, {
    Name = "Room Select",
    ControlType = "Text",
    Count = props["Rooms"].Value,
    UserPin = true,
    PinStyle = "Both"
  })
  table.insert(ctrl, {
    Name = "Room LED",
    ControlType = "Indicator",
    IndicatorType = "Led",
    Count = props["Rooms"].Value,
    UserPin = false
  })
  table.insert(ctrl, {
    Name = "Select Name",
    ControlType = "Text",
    Count = props["Rooms"].Value,
    UserPin = true,
    PinStyle = "Both"
  })

  -- One toggle bank per room: "Room 1 Input 1".."Room R Input I".
  for r = 1, props["Rooms"].Value, 1 do
    table.insert(ctrl, {
      Name = "Room " .. r .. " Input",
      ControlType = "Button",
      ButtonType = "Toggle",
      Count = props["Inputs"].Value,
      UserPin = true,
      PinStyle = "Both"
    })
  end

  table.insert(ctrl, {
    Name = "Input Active",
    ControlType = "Indicator",
    IndicatorType = 'Led',
    Count = props["Inputs"].Value,
    UserPin = true,
    PinStyle = "Both"
  })

  table.insert(ctrl, {
    Name = "Input Name",
    ControlType = "Text",
    Count = props["Inputs"].Value,
    UserPin = true,
    PinStyle = "Both"
  })

  table.insert(ctrl, {
    Name = "Auto",
    ControlType = "Button",
    ButtonType = 'Toggle',
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })

  -- Declared unconditionally even when Input Restriction is off: the runtime
  -- reads their saved strings during init regardless, and dropping them when
  -- the property is false would strip a design's stored restriction setup the
  -- moment someone toggled it.
  table.insert(ctrl, {
    Name = "Restrict Mode",
    ControlType = "Text",
    Count = props["Rooms"].Value
  })
  table.insert(ctrl, {
    Name = "Restrict Inputs",
    ControlType = "Text",
    Count = props["Rooms"].Value
  })

  return ctrl
end
