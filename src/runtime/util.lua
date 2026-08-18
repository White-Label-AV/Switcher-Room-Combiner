  ----------------------------------------------------------------------------
  -- Generic helpers: array normalisation, table utilities, text parsing.
  --
  -- Included inside `if Controls then`, so everything here is two-space
  -- indented to match its insertion depth — a bare `end` at column 0 would
  -- read as the terminator of the runtime block itself.
  ----------------------------------------------------------------------------

  -- Q-SYS hands back a bare control rather than a table when Count == 1, so
  -- Controls["Wall Opens"] is a lone control in a one-wall design and a table
  -- in a two-wall one. Normalising once here means the rest of the runtime can
  -- always index [n] without caring. Thanks Callum Brieske.
  --
  -- Detected by shape, not by type: on a Core a lone control is userdata, but
  -- under the host-side test mock it is a table with a metatable. Sniffing for
  -- userdata alone left the mock un-normalised, so every Controls[name][n] in
  -- the runtime indexed nil and the plugin could not be tested or linted.
  -- A Count > 1 array always has [1]; a lone control never does.
  for i, v in pairs(Controls) do
    local t = type(v)
    if t == "userdata" or (t == "table" and v[1] == nil) then
      Controls[i] = { v }
    end
  end

  ----------------------------------------------------------------------------
  -- Debug output, gated by the "Debug Print" property.
  --
  -- These functions run on every switch and every combine, in a design that may
  -- have hundreds of rooms, so printing unconditionally floods the debug window
  -- and costs time on the shared 30 fps thread. Default is None.
  ----------------------------------------------------------------------------

  DebugFunction, DebugState = false, false

  function SetupDebugPrint()
    local d = Properties["Debug Print"].Value
    if d == "Function Calls" then
      DebugFunction = true
    elseif d == "All" then
      DebugFunction, DebugState = true, true
    end
  end
  SetupDebugPrint()

  function dbgFn(...) if DebugFunction then print(...) end end
  function dbgState(...) if DebugState then print(...) end end

  function split(source, delimiters)
    local elements = {}
    local pattern = '([^' .. delimiters .. ']+)'
    string.gsub(source, pattern,
                function(value) elements[#elements + 1] = value; end);
    return elements
  end

  function printmap() -- dev helper: dump the wall/room association matrix
    local x = ""
    for w = 1, Properties["Walls"].Value do
      for r = 1, Properties["Rooms"].Value do
        x = x .. tostring(map[w][r]) .. "\t"
      end
      print(x)
      x = ""
    end
  end

  -- Called on every valid-input recalculation, so it is state-gated and builds
  -- no string at all unless "All" is selected.
  function printtable(prefix, t)
    if not DebugState then return end
    local x = ""
    for i, v in ipairs(t) do x = x .. tostring(v) .. "\t" end
    print(prefix, x)
  end

  function printwalls() -- dev helper: dump each wall's open/closed state
    for w = 1, Properties["Walls"].Value do print(wallsState[w]) end
  end

  function tablefind(t, f) -- find element v of t satisfying f(v)
    for _, v in ipairs(t) do if f == v then return v end end
    return nil
  end

  function tableconcat(t1, t2) -- t2 gets added onto the end of t1, removes duplicates
    for _, v in ipairs(t2) do
      if not tablefind(t1, v) then table.insert(t1, v) end
    end
  end

  function IndexLookup(t, x)
    for i, v in pairs(t) do if v == x then return (i) end end
  end

  ----------------------------------------------------------------------------
  -- Text parsing for the Wall Rooms and Restrict Inputs boxes. Both accept
  -- free-form entry like "1-4, 7" and hand back a clean table plus a
  -- sanitised string that is written straight back to the user.
  ----------------------------------------------------------------------------

  function parseRange(strToParse, max)
    local t = {}
    local s = ""
    if #strToParse > 0 then

      -- first look for ranges of digits eg 1-4
      local matchRange = "([%d]+)%-([%d]+)"
      -- remove any crap at the start plus the matchRange
      local removeRange = "[^%d]*" .. matchRange

      local mA, mB = strToParse:match(matchRange)
      while mA do
        local rangeA, rangeB = tonumber(mA), tonumber(mB)
        -- math.min/max handles descending ranges and clamps to 1..max
        local rangeMin = math.max(1, math.min(rangeA, rangeB))
        local rangeMax = math.min(max, math.max(rangeA, rangeB))
        s = s == "" and tostring(rangeMin) .. "-" .. tostring(rangeMax)
                     or s .. ", " .. tostring(rangeMin) .. "-" .. tostring(rangeMax)
        for digit = rangeMin, rangeMax do
          if digit > 0 then table.insert(t, digit) end
        end
        strToParse = strToParse:gsub(removeRange, "", 1)
        mA, mB = strToParse:match(matchRange)
      end
    end
    return t, s, strToParse
  end

  function parseDigits(strToParse, max)
    local t = {}
    local s = ""

    if #strToParse > 0 then
      local matchDigit = "%d+"
      -- remove any crap on either side of the digit
      local removeDigit = "[^%d]*" .. matchDigit .. "[^%d]*"

      local m = strToParse:match(matchDigit)
      while m do
        local digit = tonumber(m)
        if digit > 0 and digit <= max then
          table.insert(t, digit)
          s = s == "" and m or s .. ", " .. m
        end
        strToParse = strToParse:gsub(removeDigit, "", 1)
        m = strToParse:match(matchDigit)
      end
    end
    return t, s
  end

  function parseTextBox(strToParse, max)
    -- look for ranges first and then digits
    local t1, t2 = {}, {}
    local s1, s2 = "", ""
    local leftoverStr
    t1, s1, leftoverStr = parseRange(strToParse, max)
    t2, s2 = parseDigits(leftoverStr, max)

    tableconcat(t1, t2)
    table.sort(t1)

    local separator = ","
    if s1 == "" or s2 == "" then separator = "" end
    local s = s1 .. separator .. s2

    return t1, s
  end
