  ----------------------------------------------------------------------------
  -- User actions: what happens when someone touches a control.
  --
  -- Each of these is the target of an event handler registered in
  -- runtime/handlers.lua. They validate the request, update state, and hand off
  -- to the switching and grouping layers.
  ----------------------------------------------------------------------------

  function userSwitch(input, room, state)
    input, room = tonumber(input), tonumber(room)
    print("function start", "userSwitch", input, room, state)
    -- user has requested to switch inputs

    local group = rooms[room]["group"]
    local roomCurrentInput = rooms[room]["currentInput"]
    local groupValidInputs = groups[group]["validInputs"]
    local toggleMode = Properties["Allow Toggle Off"].Value

    -- if the user is allowed to switch to this input the state is on or the toggleMode is on
    if tablefind(groupValidInputs, input) and (state or toggleMode) then

      -- switch the group
      if Controls["Link"][1].Boolean then
        groupSwitch(input, group, state)
      else
        roomSwitch(input, room, true)
      end

    else -- if the input is not valid switch the button back off.
      roomSwitch(roomCurrentInput, room, true)
    end
  end

  function userRestrictModeChange(room, mode)
    -- print("function start", "userRestrictModeChange", room, mode)

    -- update global variable
    rooms[room]["restrictionMode"] = mode

    -- update room and group valid inputs and then check the group is on valid input.
    updateRoomValidInputs(room)
  end

  function userRestrictInputsChange(room, inputsTextBox)
    -- print("function start", "userRestrictInputsChange", room, inputsTextBox)
    local inputQty = Properties["Inputs"].Value

    -- parse text
    local inputsTable, sanitisedText = parseTextBox(inputsTextBox, inputQty)

    -- update global variable
    rooms[room]["restrictionInputs"] = inputsTable

    -- sanitised string to go back to the user
    Controls["Restrict Inputs"][room].String = sanitisedText

    updateRoomValidInputs(room)
  end

  function userWallOpenChange(wall, state)
    -- print("function start", "userWallOpenChange", wall, state)

    -- update global variable
    wallsState[wall] = state

    findRoomGroups(wall)
  end

  function userWallRoomsChange(wall, roomsTextBox)
    print("function start", "userWallRoomsChange", wall, roomsTextBox)

    local roomQty = Properties["Rooms"].Value

    -- parse text
    local roomsTable, sanitisedText = parseTextBox(roomsTextBox, roomQty)

    -- sanitised string to go back to the user
    Controls["Wall Rooms"][wall].String = sanitisedText

    -- rebuild this wall in the map, for every room
    for r = 1, Properties["Rooms"].Value do
      map[wall][r] = tablefind(roomsTable, r) and true or false
    end

    -- if the wall is open then the room groups will have changed
    if wallsState[wall] then findRoomGroups(wall) end

  end
