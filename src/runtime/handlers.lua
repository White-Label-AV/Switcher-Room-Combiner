  ----------------------------------------------------------------------------
  -- Event handlers. Registered last, once state exists for them to act on.
  --
  -- Every plugin, Control Script and Block Controller in a design shares one
  -- 30 fps thread, so a design with hundreds of rooms can blow the script
  -- execution limit just binding handlers. The small O(inputs) and O(walls)
  -- loops run inline; the O(rooms × inputs) one is chunked across ticks.
  ----------------------------------------------------------------------------

  for i, ctrl in pairs(Controls['Input Name']) do
    ctrl.EventHandler = function()
      for i, _ in pairs(groups) do UpdateComboChoices(i) end
    end
  end

  for w = 1, Properties["Walls"].Value do
    Controls["Wall Opens"][w].EventHandler = function(ctl)
      userWallOpenChange(w, ctl.Boolean)
    end
    Controls["Wall Rooms"][w].EventHandler = function(ctl)
      userWallRoomsChange(w, ctl.String)
    end
  end

  -- Input Active is driven from outside the plugin — it reflects whether a
  -- source is live — so it feeds the Auto switch history rather than switching
  -- anything directly.
  for i, Active in pairs(Controls["Input Active"]) do
    Active.EventHandler = function()
      if Active.Boolean then HistoryAdd(i) else HistoryRemove(i) end
    end
  end

  for room, ctrl in pairs(Controls['Select Name']) do
    ctrl.EventHandler = function()
      userSwitch(InputNumberfromName(ctrl.String), room, true)
    end
  end

  -- Room handlers are O(rooms × inputs) — chunked across ticks to stay within
  -- exec limits. Timer.CallAfter(fn, 0) yields to the next tick.
  ROOM_CHUNK = 32
  function registerRoomHandlers(startRoom)
    local totalRooms = Properties["Rooms"].Value
    local endRoom = math.min(startRoom + ROOM_CHUNK - 1, totalRooms)
    for r = startRoom, endRoom do
      Controls["Room Select"][r].EventHandler = function(ctl)
        userSwitch(ctl.String, r, true)
      end
      local roomInputCtrl = Controls["Room " .. r .. " Input"]
      for i = 1, Properties["Inputs"].Value do
        roomInputCtrl[i].EventHandler = function(ctl)
          userSwitch(i, r, ctl.Boolean)
        end
      end
      if Properties["Input Restriction"].Value then
        Controls["Restrict Mode"][r].EventHandler = function(ctl)
          userRestrictModeChange(r, ctl.String)
        end
        Controls["Restrict Inputs"][r].EventHandler = function(ctl)
          userRestrictInputsChange(r, ctl.String)
        end
      end
    end
    if endRoom < totalRooms then
      Timer.CallAfter(function() registerRoomHandlers(endRoom + 1) end, 0)
    end
  end
  registerRoomHandlers(1)
