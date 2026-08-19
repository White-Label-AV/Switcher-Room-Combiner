-- Control panel. One page, drawn beneath the shared White Label AV brand band.
--
-- The band is 90 px tall, so every y here is measured from `contentTop` — the
-- offset WLAVHeader.Draw returns — rather than from 0. Nothing hard-codes 90.
--
-- Note `top`/`right`/`bottom`/`left` below are margin-table indices (1..4), not
-- coordinates; the header offset is `contentTop`.

function GetControlLayout(props)
  local boxMargin, elementMargin = {8, 8, 8, 8}, {20, 4, 4, 4}
  local boxIndent = {40, 0, 0, 80}
  local tablePosX, tablePosY, currentPosY = 0, 0, 0
  local top, right, bottom, left = 1, 2, 3, 4

  local buttonSize = {36, 16}
  local textboxSize = {36, 16}
  local textDisplaySize = {64, 16}
  local ledSize = {16, 16}
  local x, y = 1, 2

  local inQty = props["Inputs"].Value
  local roomQty = props["Rooms"].Value
  local wallQty = props["Walls"].Value
  local extraWidth = 3

  -- Box sizes depend only on the property counts, not on any position, so they
  -- can be computed up front — which is what lets the panel width be known in
  -- time to hand it to the header.
  local roomsBoxSize = {
    elementMargin[left] + elementMargin[right] + textboxSize[x] * (roomQty),
    elementMargin[top] + ledSize[y] + textboxSize[y] + elementMargin[bottom] +
      elementMargin[top] + buttonSize[y] * (inQty + 2) +
      elementMargin[bottom]
  }
  local inputsBoxSize = {
    elementMargin[left] + textDisplaySize[x] + 12 + elementMargin[left] +
      textboxSize[x] * (roomQty + extraWidth) + elementMargin[right],
    elementMargin[top] + ledSize[y] + textDisplaySize[y] * (inQty + 2) +
      elementMargin[bottom]
  }
  local wallsBoxSize = {
    inputsBoxSize[x],
    elementMargin[top] +
      ((wallQty / roomQty) + (wallQty % roomQty > 0 and 1 or 0)) * 3 *
      textboxSize[y] + elementMargin[bottom]
  }

  local roomsBoxX = boxMargin[left] + boxIndent[left]
  local inputsBoxX = boxMargin[left]
  local roomBoxEdge = roomsBoxX + roomsBoxSize[x]
  local inputsBoxEdge = inputsBoxX + inputsBoxSize[x]

  -- The panel sizes itself to its contents, so the header has to be told the
  -- width the plugin actually occupies — a header wider than the plugin would
  -- stretch the panel. Widest of: the two group boxes, the Link/Auto pair
  -- parked right of the Inputs box, and the input name + active-LED columns
  -- parked right of the Rooms box.
  local panelWidth = math.max(
    roomBoxEdge,
    inputsBoxEdge,
    inputsBoxEdge + 4 + buttonSize[x] * 2,
    roomBoxEdge + 4 + buttonSize[x] + 8 + ledSize[x]
  ) + boxMargin[right]

  local layout = {}
  local graphics = {}

  -- Brand band first; everything below is laid out from what it returns.
  local contentTop = WLAVHeader.Draw(graphics, panelWidth)

  local roomsBoxPos = {roomsBoxX, contentTop + boxMargin[top]}
  local inputsBoxPos = {inputsBoxX, contentTop + boxMargin[top] + boxIndent[top]}
  local wallsBoxPos = {
    boxMargin[left], inputsBoxPos[y] + inputsBoxSize[y] + boxMargin[top]
  }

  currentPosY = roomsBoxPos[y] + elementMargin[top]
  tablePosX = roomsBoxPos[x] + elementMargin[left]

  for i = 1, inQty, 1 do
    table.insert(graphics, {
      Type = "Text",
      Text = tostring(i),
      HTextAlign = "Right",
      Position = {
        inputsBoxPos[x] + elementMargin[left],
        inputsBoxPos[y] + ledSize[y] + elementMargin[top] +
          textDisplaySize[y] * (i + 1) + 1
      },
      Size = textDisplaySize
    })
  end

  for r = 1, roomQty, 1 do
    tablePosY = currentPosY

    table.insert(graphics, {
      Type = "Text",
      Text = tostring(r),
      HTextAlign = "Center",
      Size = textboxSize,
      Position = {tablePosX, tablePosY}
    })

    tablePosY = tablePosY + textboxSize[y] + elementMargin[bottom] +
                  elementMargin[top]

    layout["Room LED " .. r] = {
      Style = "Led",
      Size = ledSize,
      Position = {tablePosX + 10, tablePosY}
    }

    tablePosY = tablePosY + buttonSize[y]

    layout["Room Select " .. r] = {
      Style = "Textbox",
      Size = buttonSize,
      Position = {tablePosX, tablePosY},
      HTextAlign = "Center",
      PrettyName = "Room " .. r .. "~Select by Number",
      Legend = "1",
      Text = "1"
    }
    tablePosY = tablePosY + buttonSize[y]

    layout["Select Name " .. r] = {
      Style = "ComboBox",
      Size = buttonSize,
      Position = {tablePosX, tablePosY},
      HTextAlign = "Center",
      PrettyName = "Room " .. r .. "~Select by Name",
      Text = ""
    }
    tablePosY = tablePosY + buttonSize[y]

    for i = 1, inQty, 1 do
      if inQty > 1 then
        layout["Room " .. r .. " Input " .. i] = {
          Style = "Button",
          ButtonStyle = "Toggle",
          Size = buttonSize,
          Position = {tablePosX, tablePosY},
          PrettyName = "Room " .. r .. "~Input " .. i
        }
        layout["Input Active " .. i] = {
          Style = "Indicator",
          IndicatorStyle = "Led",
          Position = {roomBoxEdge + 4 + buttonSize[1] + 8, tablePosY},
          PrettyName = "Active~Input " .. i
        }
        layout["Input Name " .. i] = {
          Style = "Textbox",
          Size = textboxSize,
          Position = {roomBoxEdge + 4, tablePosY},
          PrettyName = "Names~Input " .. i
        }
      else
        layout["Room " .. r .. " Input"] = {
          Style = "Button",
          ButtonStyle = "Toggle",
          Size = buttonSize,
          Position = {tablePosX, tablePosY},
          PrettyName = "Room " .. r .. "~Input " .. i
        }
        layout["Input Active"] = {
          Style = "Indicator",
          IndicatorStyle = "Led",
          Position = {inputsBoxSize[1] + 20, contentTop + 84 + (16 * i)},
          PrettyName = "Active~Input " .. i
        }
        layout["Input Name"] = {
          Style = "Textbox",
          Size = textboxSize,
          Position = {roomBoxEdge + 4, tablePosY},
          PrettyName = "Names~Input " .. i
        }
      end
      tablePosY = tablePosY + buttonSize[y]
    end

    tablePosX = tablePosX + buttonSize[x]
  end

  currentPosY = wallsBoxPos[y] + elementMargin[top]
  tablePosX = wallsBoxPos[x] + elementMargin[left] + textDisplaySize[x] + 12 +
                elementMargin[left]

  if props["Input Restriction"].Value then
    local restrictBoxSize = {
      inputsBoxSize[x],
      elementMargin[top] + textboxSize[y] * 2 + elementMargin[bottom]
    }
    local restrictBoxPos = {wallsBoxPos[x], wallsBoxPos[y]}
    wallsBoxPos[y] = wallsBoxPos[y] + restrictBoxSize[y] + boxMargin[bottom]
    roomsBoxSize[y] = roomsBoxSize[y] + boxMargin[bottom] + restrictBoxSize[y]

    table.insert(graphics, {
      Type = "GroupBox",
      Text = "Input Restrict",
      HTextAlign = "Left",
      StrokeWidth = 1,
      CornerRadius = 8,
      Position = restrictBoxPos,
      Size = restrictBoxSize
    })
    table.insert(graphics, {
      Type = "Text",
      Text = "Mode",
      HTextAlign = "Right",
      Position = {
        restrictBoxPos[x] + elementMargin[left],
        restrictBoxPos[y] + elementMargin[top]
      },
      Size = textDisplaySize
    })
    table.insert(graphics, {
      Type = "Text",
      Text = "Inputs",
      HTextAlign = "Right",
      Position = {
        restrictBoxPos[x] + elementMargin[left],
        restrictBoxPos[y] + elementMargin[top] + textboxSize[y]
      },
      Size = textDisplaySize
    })

    for r = 1, roomQty, 1 do
      tablePosY = currentPosY

      layout["Restrict Mode " .. r] = {
        Style = "ComboBox",
        Size = textboxSize,
        Position = {tablePosX, tablePosY}
      }

      tablePosY = tablePosY + textboxSize[y]

      layout["Restrict Inputs " .. r] = {
        Style = "Textbox",
        Size = textboxSize,
        Position = {tablePosX, tablePosY}
      }

      tablePosX = tablePosX + textboxSize[x]
    end

    currentPosY = wallsBoxPos[y] + elementMargin[top]
    tablePosX = wallsBoxPos[x] + elementMargin[left] + textDisplaySize[x] +
                  12 + elementMargin[left]
  else
    -- GetControls declares these whatever the property says, so they still need
    -- a layout entry when the restrict panel is hidden. Style "None" draws
    -- nothing but keeps the control and its saved value alive — without it the
    -- entries are unplaced, and a design's stored restriction setup would be
    -- lost the moment someone toggled the property off and back on.
    for r = 1, roomQty, 1 do
      layout["Restrict Mode " .. r] = {Style = "None"}
      layout["Restrict Inputs " .. r] = {Style = "None"}
    end
  end

  for w = 1, wallQty, 1 do
    tablePosY = currentPosY

    table.insert(graphics, {
      Type = "Text",
      Text = tostring(w),
      HTextAlign = "Centre",
      Size = textboxSize,
      Position = {tablePosX, tablePosY}
    })

    tablePosY = tablePosY + textboxSize[y]

    layout[wallQty > 1 and "Wall Opens " .. w or "Wall Opens"] = {
      Style = "Button",
      ButtonStyle = "Toggle",
      Size = buttonSize,
      Position = {tablePosX, tablePosY},
      HTextAlign = "Centre",
      PrettyName = "Wall " .. w .. "~Open"
    }

    tablePosY = tablePosY + textboxSize[y]

    layout[wallQty > 1 and "Wall Rooms " .. w or "Wall Rooms"] = {
      Style = "Textbox",
      Size = textboxSize,
      Position = {tablePosX, tablePosY},
      HTextAlign = "Centre",
      PrettyName = "Wall " .. w .. "~Rooms"
    }

    tablePosX = tablePosX + textboxSize[x]

    if w % roomQty == 1 then
      table.insert(graphics, {
        Type = "Text",
        Text = "Open",
        HTextAlign = "Right",
        Size = textDisplaySize,
        Position = {
          inputsBoxPos[x] + elementMargin[left],
          currentPosY + textboxSize[y]
        }
      })
      table.insert(graphics, {
        Type = "Text",
        Text = "Rooms",
        HTextAlign = "Right",
        Size = textDisplaySize,
        Position = {
          inputsBoxPos[x] + elementMargin[left],
          currentPosY + textboxSize[y] * 2
        }
      })
    end
    if w % roomQty == 0 then -- Add another row & wrap around
      currentPosY = tablePosY + buttonSize[y]
      tablePosX = wallsBoxPos[x] + textDisplaySize[x] + 12 +
                    elementMargin[left]
    end

    tablePosY = currentPosY
  end

  table.insert(graphics, {
    Type = "GroupBox",
    Text = "Rooms",
    HTextAlign = "Left",
    StrokeWidth = 1,
    CornerRadius = 8,
    Position = roomsBoxPos,
    Size = roomsBoxSize
  })
  table.insert(graphics, {
    Type = "GroupBox",
    Text = "Inputs",
    HTextAlign = "Left",
    StrokeWidth = 1,
    CornerRadius = 8,
    Position = inputsBoxPos,
    Size = inputsBoxSize
  })
  table.insert(graphics, {
    Type = "Text",
    Text = "Combined",
    HTextAlign = "Right",
    Position = {
      inputsBoxPos[x] + elementMargin[left],
      inputsBoxPos[y] + elementMargin[top]
    },
    Size = textDisplaySize
  })
  table.insert(graphics, {
    Type = "Text",
    Text = "Select",
    HTextAlign = "Right",
    Position = {
      inputsBoxPos[x] + elementMargin[left],
      inputsBoxPos[y] + ledSize[y] + elementMargin[top]
    },
    Size = textDisplaySize
  })
  table.insert(graphics, {
    Type = "Text",
    Text = "Sel Name",
    HTextAlign = "Right",
    Position = {
      inputsBoxPos[x] + elementMargin[left],
      inputsBoxPos[y] + ledSize[y] * 2 + elementMargin[top]
    },
    Size = textDisplaySize
  })
  table.insert(graphics, {
    Type = "GroupBox",
    Text = "Walls",
    HTextAlign = "Left",
    StrokeWidth = 1,
    CornerRadius = 8,
    Position = wallsBoxPos,
    Size = {wallsBoxSize[x], wallsBoxSize[y]}
  })

  layout["Link"] = {
    Style = "Button",
    Size = buttonSize,
    Color = {242, 137, 174},
    UnlinkOffColor = false,
    Position = {inputsBoxEdge + 4, contentTop + 100},
    PrettyName = "Link Combined Rooms"
  }
  layout["Auto"] = {
    Style = "Button",
    Size = buttonSize,
    Position = {layout["Link"].Position[1] + buttonSize[1], contentTop + 100},
    PrettyName = "Auto Switch"
  }
  table.insert(graphics, {
    Type = "Text",
    Text = "Auto",
    HTextAlign = "Left",
    Position = {layout["Auto"].Position[1], layout["Auto"].Position[2] - 20},
    Size = buttonSize
  })
  table.insert(graphics, {
    Type = "Text",
    Text = "Link",
    HTextAlign = "Left",
    Position = {layout["Link"].Position[1], layout["Link"].Position[2] - 20},
    Size = buttonSize
  })
  table.insert(graphics, {
    Type = "Text",
    Text = "Active",
    HTextAlign = "Left",
    Position = {
      roomBoxEdge + buttonSize[1] + 4,
      inputsBoxPos[y] + elementMargin[top]
    },
    Size = buttonSize
  })
  table.insert(graphics, {
    Type = "Text",
    Text = "Name",
    HTextAlign = "Left",
    Position = {roomBoxEdge + 4, inputsBoxPos[y] + elementMargin[top]},
    Size = buttonSize
  })

  -- Status bar across the foot of the panel. Style must be "Text" per the
  -- Status Reporting standard, which also forbids styling it at runtime.
  -- wallsBoxPos is read here rather than earlier because the Input Restrict
  -- panel shifts it down when that property is on.
  layout["Status"] = {
    PrettyName = "Status",
    Style = "Text",
    Position = {
      boxMargin[left],
      wallsBoxPos[y] + wallsBoxSize[y] + boxMargin[top]
    },
    Size = {panelWidth - boxMargin[left] - boxMargin[right], 20}
  }

  return layout, graphics
end
