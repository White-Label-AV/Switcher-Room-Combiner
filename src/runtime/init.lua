  ----------------------------------------------------------------------------
  -- State and initialisation.
  --
  -- All rooms belong to a group even if there's only one room in the group.
  -- The group's lowest numbered room determines the group number. When groups
  -- change, the individual allowed inputs for each group-room member are added
  -- to the group. Inputs are switched by group, and not by room.
  --
  -- Nothing here is `local`: this state has to outlive the init pass, and the
  -- garbage collector would take anything scoped to it.
  ----------------------------------------------------------------------------

  print("Room Combine Switcher v" .. PluginInfo.Version .. " starting")

  bypass = "Bypass"
  restrict = "Restrict"
  allow = "Allow"

  -- Last entry is the OFF colour; the ones before it cycle per combined group.
  -- Fixed on purpose: custom room LED colours are the job of the separate
  -- Room Combiner Custom LEDs plugin.
  ledColours = {"Red", "LimeGreen", "Cyan", "DarkViolet", "#7C0000"}

  allInputs = {}
  for i = 1, Properties["Inputs"].Value do table.insert(allInputs, i) end

  rooms = {} -- rooms[roomNo]["data"] data = restrictionMode,validInputs,group,input
  allRooms = {} -- just a table of room numbers
  groups = {} -- groups[groupNo]["data"] data = validInputs, members

  -- Seed each room from whatever the design already had in its text boxes, so
  -- a reload or a Core restart comes back up where the operator left it.
  for r = 1, Properties["Rooms"].Value do
    table.insert(allRooms, r)
    rooms[r] = {}
    groups[r] = {}

    -- if there's something in the text box, use that, otherwise default to input nil
    rooms[r]["currentInput"] = Controls["Room Select"][r].String ~= "" and
                                 tonumber(
                                   Controls["Room Select"][r].String) or
                                 1
    Controls["Room Select"][r].String = rooms[r]["currentInput"]

    rooms[r]["restrictionMode"] =
      Controls["Restrict Mode"][r].String == "" and bypass or
        Controls["Restrict Mode"][r].String
    Controls["Restrict Mode"][r].String = rooms[r]["restrictionMode"]
    rooms[r]["restrictionInputs"], Controls["Restrict Inputs"][r].String =
      parseTextBox(Controls["Restrict Inputs"][r].String,
                   Properties["Inputs"].Value)
    rooms[r]["group"] = r
    rooms[r]["validInputs"] = allInputs -- initial assign to all rooms, then update to actual rooms below

    Controls["Restrict Mode"][r].Choices = {bypass, restrict, allow}

    groups[r]["members"] = {r}

    -- Only set the active button; others are false by default/saved state.
    Controls["Room " .. r .. " Input"][rooms[r]["currentInput"]].Boolean = true
  end

  map = {} -- map[wallNo][roomNo] = true or false depending on if there is an association or not.
  wallsState = {} -- wallsState[wallNo]
  do
    local walls = {} -- only used for init
    for w = 1, Properties["Walls"].Value do
      walls[w], Controls["Wall Rooms"][w].String = parseTextBox(
                                                     Controls["Wall Rooms"][w]
                                                       .String,
                                                     Properties["Rooms"]
                                                       .Value)
      wallsState[w] = Controls["Wall Opens"][w].Boolean
      map[w] = {}
      for r = 1, Properties["Rooms"].Value do
        map[w][r] = tablefind(walls[w], r) and true or false
      end
    end
  end

  -- Compute correct per-room validInputs before group assembly so findRoomGroups(0)
  -- calls updateGroupValidInputs exactly once per group with correct data instead of
  -- rebuilding adjacency K times (once per open wall) with stale allInputs placeholders.
  for r = 1, Properties["Rooms"].Value do
    local mode = rooms[r]["restrictionMode"]
    local totalInputs = Properties["Inputs"].Value
    local roomRestrictionInputs = rooms[r]["restrictionInputs"]
    local roomValidInputs = {}
    if mode == bypass then
      for input = 1, totalInputs do table.insert(roomValidInputs, input) end
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
    rooms[r]["validInputs"] = roomValidInputs
  end

  findRoomGroups(0)
