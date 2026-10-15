-- Design-time configuration. Rooms, Walls and Inputs size every control array
-- and the whole layout, so changing one re-runs GetControls and
-- GetControlLayout with the new counts.

function GetProperties()
  local props = {
    {Name = "Rooms", Type = "integer", Min = 2, Max = 256, Value = 2},
    {Name = "Walls", Type = "integer", Min = 1, Max = 256, Value = 1},
    {Name = "Inputs", Type = "integer", Min = 1, Max = 128, Value = 2},
    {Name = "Input Restriction", Type = "boolean", Value = false},
    {Name = "Use Custom Colours", Type = "boolean", Value = false},
    {Name = "Custom Colours CSV", Type = "string"},
    {Name = "Allow Toggle Off", Type = "boolean", Value = false},
    -- The standard debug enum, minus the Tx/Rx choices: this plugin drives no
    -- device and has no wire traffic, so offering them would be a dead option.
    -- "Function Calls" traces entry into the switching and grouping functions;
    -- "All" adds the resolved room/group input lists.
    {
      Name = "Debug Print",
      Type = "enum",
      Choices = {"None", "Function Calls", "All"},
      Value = "None"
    }
  }
  return props
end
