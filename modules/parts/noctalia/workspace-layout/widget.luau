-- Workspace layout bar widget. Hyprland layouts are compositor-wide, so its
-- current `general:layout` value applies to the focused workspace.

local refreshing = false

local function render(layout)
  barWidget.setText(layout)
  barWidget.setTooltip("Hyprland layout: " .. layout)
end

local function failed(result, err)
  refreshing = false
  render("?")
  noctalia.log(err or result.stderr)
end

local function decodeOption(result)
  if result.exitCode ~= 0 then
    failed(result)
    return nil
  end

  local option, err = noctalia.json.decode(result.stdout)
  if type(option) ~= "table" or type(option.str) ~= "string" or option.str == "" then
    failed(result, err or "Hyprland did not return a layout")
    return nil
  end

  return option.str
end

local function refresh()
  if refreshing then
    return
  end

  refreshing = true
  noctalia.runAsync("hyprctl -j getoption general:layout", function(result)
    local layout = decodeOption(result)
    if layout == nil then
      return
    end

    if layout ~= "master" then
      refreshing = false
      render(layout)
      return
    end

    noctalia.runAsync("hyprctl -j getoption master:orientation", function(orientationResult)
      local orientation = decodeOption(orientationResult)
      if orientation == nil then
        return
      end

      refreshing = false
      render(({ left = "tall", top = "wide" })[orientation] or "primary")
    end)
  end)
end

barWidget.setGlyph("layout-dashboard")
render("...")

function update()
  noctalia.setUpdateInterval(1000)
  refresh()
end
