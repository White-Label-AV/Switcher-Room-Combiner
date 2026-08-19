  ----------------------------------------------------------------------------
  -- Room grouping: which rooms are currently combined with which.
  --
  -- Walls are edges and rooms are nodes: an open wall joins every room
  -- associated with it. findRoomGroups walks the resulting graph and names each
  -- connected component after its LOWEST room number, which is what makes group
  -- identity stable regardless of the order walls were opened in.
  --
  -- Every room belongs to a group, even when it is alone in one.
  ----------------------------------------------------------------------------

  function getStartingRooms(wall)
    -- print("function start", "getStartingRooms", wall)
    local t = {}
    if wall == 0 then -- special wall used on init, get all rooms
      for r = 1, Properties["Rooms"].Value do
        table.insert(t, r)
      end
    else
      for r, valid in ipairs(map[wall]) do
        if valid then table.insert(t, r) end
      end
    end
    -- printtable("function end\tgetStartingRooms", t)
    return t
  end

  function updateLEDs(group)
    -- print("function start updateLEDs("..tostring(group)..")")
    local groupMembers = groups[group]["members"]
    local offColour = ledColours[#ledColours] -- off colour is the last value.
    local colourIndex = (group - 1) % (#ledColours - 1) + 1
    local combinedState = #groupMembers > 1 and true or false

    -- Rubric 8 wants generic styling so integrators can restyle on a UCI, but
    -- here the colour IS the information: it is how an operator tells which
    -- rooms are combined into which group, and the palette is a documented
    -- property. The stock Room Combiner colours its LEDs the same way. Note
    -- this silences the linter, not the rubric — it still needs a waiver at
    -- Library submission.
    for _, room in ipairs(groupMembers) do
      -- if there's more than 1 room in the group, rooms are combined.
      Controls["Room LED"][room].Boolean = combinedState
      if combinedState then
        -- qsys-lint: ignore QP009 group colour identifies the combine group
        Controls["Room LED"][room].Color = ledColours[colourIndex]
      else
        -- qsys-lint: ignore QP009 off colour is the last entry of the palette
        Controls["Room LED"][room].Color = offColour
      end
    end
    -- print("function end updateLEDs")
  end

  function findRoomGroups(wall)
    -- print("function start", "findRoomGroups", wall)

    -- Pre-compute adjacency list once; avoids rescanning all walls per room
    local adjacency = {}
    local adjSeen = {}
    for r = 1, Properties["Rooms"].Value do
      adjacency[r] = {}
      adjSeen[r] = {}
    end
    for w, roomsTable in ipairs(map) do
      if wallsState[w] then
        for r1, v1 in ipairs(roomsTable) do
          if v1 then
            for r2, v2 in ipairs(roomsTable) do
              if v2 and r1 ~= r2 and not adjSeen[r1][r2] then
                adjSeen[r1][r2] = true
                table.insert(adjacency[r1], r2)
              end
            end
          end
        end
      end
    end

    local startingRooms = getStartingRooms(wall)
    local unvisited = {}
    for _, r in ipairs(startingRooms) do unvisited[r] = true end

    for _, startingRoom in ipairs(startingRooms) do
      if unvisited[startingRoom] then
        local currentGroup = {}
        local seen = { [startingRoom] = true }
        local roomStack = { startingRoom }
        unvisited[startingRoom] = nil

        while #roomStack > 0 do
          local currentRoom = table.remove(roomStack)
          table.insert(currentGroup, currentRoom)

          for _, adj in ipairs(adjacency[currentRoom]) do
            if not seen[adj] then
              seen[adj] = true
              unvisited[adj] = nil
              table.insert(roomStack, adj)
            end
          end
        end

        table.sort(currentGroup)

        local group = currentGroup[1] -- lowest room number denotes the group number
        groups[group]["members"] = currentGroup
        groups[group]["validInputs"] = {}
        groups[group]['History'] = {}

        for _, room in ipairs(groups[group]["members"]) do
          rooms[room]["group"] = group
        end

        updateLEDs(group)

        updateGroupValidInputs(group)
      end
    end
  end
