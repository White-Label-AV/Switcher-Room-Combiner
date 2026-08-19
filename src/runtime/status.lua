  ----------------------------------------------------------------------------
  -- Status reporting.
  --
  -- This plugin controls no device, so there is no connection to report on.
  -- What the Status control carries instead is plugin health: whether the
  -- current restriction setup has left any room unable to select anything, and
  -- otherwise a summary of what is combined.
  --
  -- Status changes reach the Core Event Log when Reflect is enabled, so the
  -- standard requires that the value is not flipped excessively. UpdateStatus
  -- is therefore called once at the end of a user action or an init pass —
  -- never from inside the per-group recalculation loops, which run many times
  -- for a single click.
  ----------------------------------------------------------------------------

  StatusState = {
    OK = 0,
    COMPROMISED = 1,
    FAULT = 2,
    NOTPRESENT = 3,   -- application only, never set here
    MISSING = 4,
    INITIALIZING = 5  -- application only, never set here
  }

  function ReportStatus(state, message)
    Controls["Status"][1].Value = StatusState[state]
    Controls["Status"][1].String = message or ""
  end

  function UpdateStatus()
    dbgFn("function start", "UpdateStatus")
    local roomQty = Properties["Rooms"].Value

    -- A room with no valid inputs has every one of its buttons hidden and
    -- cannot be switched at all until the restriction is widened. That is a
    -- live misconfiguration worth surfacing rather than leaving to be found.
    local stranded = {}
    for r = 1, roomQty do
      if #rooms[r]["validInputs"] == 0 then
        stranded[#stranded + 1] = r
      end
    end
    if #stranded > 0 then
      ReportStatus("COMPROMISED",
                   "No valid inputs for room " .. table.concat(stranded, ", "))
      return
    end

    -- Counted from each room's own group pointer, which findRoomGroups always
    -- rewrites. The groups table keeps stale members entries for rooms that
    -- have since joined another group, so it cannot be scanned directly.
    local combinedRooms, groupsSeen = 0, {}
    for r = 1, roomQty do
      local g = rooms[r]["group"]
      if #groups[g]["members"] > 1 then
        combinedRooms = combinedRooms + 1
        groupsSeen[g] = true
      end
    end
    local groupCount = 0
    for _ in pairs(groupsSeen) do groupCount = groupCount + 1 end

    if groupCount == 0 then
      ReportStatus("OK", roomQty .. " rooms, all separate")
    else
      ReportStatus("OK", ("%d rooms, %d combined into %d group%s")
                         :format(roomQty, combinedRooms, groupCount,
                                 groupCount == 1 and "" or "s"))
    end
  end
