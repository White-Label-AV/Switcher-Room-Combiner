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
  ledColours = Properties["Use Custom Colours"].Value == true and
                 split(Properties["Custom Colours CSV"].Value, ", ") or {
    "Red", "LimeGreen", "Cyan", "DarkViolet", "#7C0000" -- default off colour
  }

  -- Reserved for algorithmically generating a distinct LED colour per group:
  -- 256 evenly-spread HSV hues. Not yet wired to anything.
  defaultH_Values = {0.00,89.39,180.00,269.39,357.55,88.16,178.78,268.16,356.33,86.94,176.33,266.94,355.10,84.49,175.10,265.71,353.88,83.27,173.88,263.27,352.65,82.04,172.65,262.04,351.43,80.82,171.43,260.82,350.20,79.59,170.20,259.59,347.76,78.37,168.98,258.37,346.53,77.14,166.53,257.14,345.31,74.69,165.31,255.92,344.08,73.47,164.08,254.69,342.86,72.24,162.86,252.24,341.63,71.02,161.63,251.02,340.41,69.80,160.41,249.80,339.18,68.57,159.18,248.57,336.73,67.35,157.96,247.35,335.51,66.12,155.51,246.12,334.29,63.67,154.29,244.90,333.06,62.45,153.06,242.45,331.84,61.22,151.84,241.22,330.61,60.00,150.61,238.78,329.39,58.78,149.39,237.55,326.94,57.55,148.16,236.33,325.71,56.33,145.71,235.10,324.49,55.10,144.49,233.88,323.27,53.88,143.27,232.65,322.04,52.65,142.04,230.20,320.82,51.43,140.82,228.98,319.59,48.98,139.59,227.76,317.14,47.76,138.37,226.53,315.92,46.53,137.14,225.31,314.69,45.31,134.69,224.08,313.47,44.08,133.47,222.86,312.24,42.86,132.24,220.41,311.02,41.63,131.02,219.18,309.80,40.41,129.80,217.96,308.57,37.96,128.57,216.73,306.12,36.73,127.35,215.51,304.90,35.51,124.90,214.29,303.67,34.29,123.67,213.06,302.45,33.06,122.45,211.84,301.22,31.84,121.22,209.39,300.00,30.61,118.78,208.16,298.78,28.16,117.55,206.94,297.55,26.94,116.33,205.71,296.33,25.71,115.10,204.49,295.10,24.49,112.65,203.27,293.88,23.27,111.43,202.04,291.43,22.04,110.20,199.59,290.20,20.82,108.98,198.37,288.98,19.59,107.76,197.14,287.76,17.14,106.53,195.92,286.53,15.92,105.31,194.69,285.31,14.69,102.86,193.47,284.08,13.47,101.63,192.24,282.86,12.24,100.41,191.02,280.41,11.02,99.18,188.57,279.18,9.80,97.96,187.35,277.96,7.35,96.73,186.12,276.73,6.12,95.51,184.90,275.51,4.90,94.29,183.67,274.29,3.67,91.84,182.45,273.06,2.45,90.61,181.22}

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
