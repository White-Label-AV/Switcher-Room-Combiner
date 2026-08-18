  ----------------------------------------------------------------------------
  -- Valid-input resolution.
  --
  -- A room's valid inputs come from its own restriction mode. A group's are
  -- the UNION of its member rooms' — combining two rooms grants each access to
  -- the other's inputs, and separating them drops each back to its own list.
  -- Buttons for inputs outside the group's set are made invisible rather than
  -- disabled, and the Select-by-Name combo boxes are re-populated to match.
  ----------------------------------------------------------------------------

  function groupInputSync(group)
    print("function start", "groupInputSync", group)
    local masterRoomInput = rooms[group]["currentInput"]
    local groupValidInputs = groups[group]["validInputs"]

    local syncAnyway = false

    -- if the group's masterRoom currentInput is not in group's validInputs or the masterRoom currentInput is not nil, nil is always valid.
    if not tablefind(groupValidInputs, masterRoomInput) and masterRoomInput ~=
        nil then
      -- update the first/only room's currentInput
      masterRoomInput = groupValidInputs[1]
      syncAnyway = true
    end
    -- trigger a group switch to the validInput

    -- check sync button
    if Controls["Link"][1].Boolean or syncAnyway then
      groupSwitch(masterRoomInput, group, 1)
    end

  end

  function updateRoomValidInputs(room)
    print("function start", "updateRoomValidInputs", room)
    local mode = rooms[room]["restrictionMode"]
    print("the restriction mode is " .. mode)

    local totalInputs = Properties["Inputs"].Value
    local roomRestrictionInputs = rooms[room]["restrictionInputs"]

    -- start building new validInputs table from scratch
    local roomValidInputs = {}

    if mode == bypass then
      for input = 1, totalInputs do
        table.insert(roomValidInputs, input)
      end
    elseif mode == allow then
      for _, input in ipairs(roomRestrictionInputs) do
        if input > 0 and input <= totalInputs then
          table.insert(roomValidInputs, input)
        end
      end
    elseif mode == restrict then
      for input = 1, totalInputs do
        if not tablefind(roomRestrictionInputs, input) then
          table.insert(roomValidInputs, input)
        end
      end
    end
    printtable("function end\tupdateRoomValidInputs", roomValidInputs)
    rooms[room]["validInputs"] = roomValidInputs

    -- pass this new info onto the group
    updateGroupValidInputs(rooms[room]["group"])
  end

  function updateGroupValidInputs(group)
    print("function start", "updateGroupValidInputs", group)
    local groupMembers = groups[group]["members"]
    local totalInputs = Properties['Inputs'].Value

    if not Properties["Input Restriction"].Value then
      -- Bypass: all inputs valid, no IsInvisible writes needed.
      groups[group]["validInputs"] = allInputs
      groupInputSync(group)
      UpdateComboChoices(group)
      return
    end

    -- Restricted: union each room's validInputs via a set (O(R×I)) then
    -- read out in order 1..max to get a sorted result without table.sort.
    local unionSet = {}
    for _, room in ipairs(groupMembers) do
      for _, input in ipairs(rooms[room]["validInputs"]) do
        unionSet[input] = true
      end
    end
    local groupValidInputs = {}
    for input = 1, totalInputs do
      if unionSet[input] then table.insert(groupValidInputs, input) end
    end

    -- Single-pass IsInvisible update using the set built above.
    for _, room in ipairs(groupMembers) do
      local roomInputCtrl = Controls["Room " .. room .. " Input"]
      for input = 1, totalInputs do
        roomInputCtrl[input].IsInvisible = not unionSet[input]
      end
    end

    groups[group]["validInputs"] = groupValidInputs
    printtable("function end\tupdateGroupValidInputs", groupValidInputs)
    groupInputSync(group)
    UpdateComboChoices(group)
  end

  function UpdateComboChoices(group)
    print('function start UpdateComboChoices', group)
    local groupValidInputs = groups[group]["validInputs"]
    local groupMembers = groups[group]["members"]

    -- build choices once; all rooms in a group share the same valid input list
    local choices = {}
    for _, input in ipairs(groupValidInputs) do
      table.insert(choices, Controls['Input Name'][input].String)
    end
    for _, room in ipairs(groupMembers) do
      Controls['Select Name'][room].Choices = choices
    end

    UpdateComboString(group)
  end

  function InputNumberfromName(name)
    for i, ctrl in pairs(Controls['Input Name']) do
      if ctrl.String == name then return i end
    end
  end

  function InputNameFromNumber(n)
    return Controls['Input Name'][n].String
  end

  function UpdateComboString(group)
    for _, room in ipairs(groups[group].members) do
      local source = tonumber(Controls['Room Select'][room].String)
      local name = InputNameFromNumber(source)
      Controls['Select Name'][room].String = name
    end
  end
