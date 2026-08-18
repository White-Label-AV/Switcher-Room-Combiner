  ----------------------------------------------------------------------------
  -- Switching: the act of putting a room, or a whole group, on an input.
  --
  -- Inputs are switched by GROUP, not by room — roomSwitch is the primitive,
  -- groupSwitch fans it out across the group's members. The Auto feature keeps
  -- a per-group history of which inputs went active so a group can fall back to
  -- the previous live source when the current one drops.
  ----------------------------------------------------------------------------

  local SwitchDelay = 0.5

  function switchNames(room, input)
    Controls['Select Name'][room].String = Controls['Input Name'][input].String
  end

  function roomSwitch(input, room, state) -- Create radio buttons.  Thanks to Callum Brieske.
    -- print("function start", "roomSwitch", input, room, state)

    input, room = tonumber(input), tonumber(room)

    if state then
      -- for each input button for the room
      for i, v in ipairs(Controls["Room " .. room .. " Input"]) do
        v.Value = i == input and 1 or 0
      end
    else
      Controls["Room " .. room .. " Input"][input].Value = state
    end
    -- update global variable and text
    rooms[room]["currentInput"] = state and input or nil
    Controls["Room Select"][room].String = tostring(state and input or nil)
    Controls["Select Name"][room].String = InputNameFromNumber(input)
  end

  function groupSwitch(input, group, state)
    print("function start", "groupSwitch", input, group, state)
    -- switch all rooms in this group to the input

    for _, room in ipairs(groups[group]["members"]) do
      roomSwitch(input, room, state)
    end

  end

  ----------------------------------------------------------------------------
  -- Auto switch history
  ----------------------------------------------------------------------------

  function HistoryAdd(input)
    for i, group in pairs(groups) do
      if tablefind(group.validInputs, input) then
        if not group.History then groups[i].History = {} end
        table.insert(groups[i].History, 1, input)
        SwitchToLatest(i)
      end
    end

  end

  function HistoryRemove(input)
    print('function start HistoryRemove', input)
    local pos = nil
    for i, group in pairs(groups) do
      if tablefind(group.validInputs, input) then

        if not group.History then groups[i].History = {} end

        pos = IndexLookup(groups[i].History, input)
        table.remove(groups[i].History, pos)

        if pos == 1 then
          if #groups[i].History > 0 then
            SwitchToLatest(i)
          end
        end

      end
    end

  end

  function SwitchToLatest(groupNum)
    print('function start SwitchToLatest')
    local input = groups[groupNum].History[1]
    if input and Controls.Auto[1].Boolean then
      Timer.CallAfter(function()
        groupSwitch(input, groupNum, true)
      end, SwitchDelay)
    end
  end
