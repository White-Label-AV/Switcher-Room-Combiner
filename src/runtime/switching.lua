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

  -- `input` may legitimately be nil: a room whose restriction leaves it with no
  -- valid inputs has nothing to select, and userSwitch reverts to a
  -- currentInput that can itself be nil. That is a real state — every button
  -- goes off and the text boxes clear — not an error, so it is handled here
  -- rather than guarded at each of the four call sites.
  function roomSwitch(input, room, state) -- Create radio buttons.  Thanks to Callum Brieske.
    input, room = tonumber(input), tonumber(room)

    if state then
      -- for each input button for the room; with input nil nothing matches, so
      -- this deselects the lot, which is what "no valid input" should look like
      for i, v in ipairs(Controls["Room " .. room .. " Input"]) do
        v.Value = i == input and 1 or 0
      end
    elseif input then
      Controls["Room " .. room .. " Input"][input].Value = state
    end

    -- update global variable and text
    local selected = state and input or nil
    rooms[room]["currentInput"] = selected
    -- Blank, not the string "nil": init reads this box back on load and treats
    -- an empty string as "unset", where "nil" would be a value it must parse.
    Controls["Room Select"][room].String = selected and tostring(selected) or ""
    Controls["Select Name"][room].String =
      selected and InputNameFromNumber(selected) or ""
  end

  function groupSwitch(input, group, state)
    dbgFn("function start", "groupSwitch", input, group, state)
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
    dbgFn('function start HistoryRemove', input)
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
    dbgFn('function start SwitchToLatest')
    local input = groups[groupNum].History[1]
    if input and Controls.Auto[1].Boolean then
      Timer.CallAfter(function()
        groupSwitch(input, groupNum, true)
      end, SwitchDelay)
    end
  end
