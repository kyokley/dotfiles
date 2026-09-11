-- Workspace layout bar widget. Hyprland layouts are compositor-wide, so its
-- current `general:layout` value applies to the focused workspace.

local refreshing = false

local function render(layout)
  layout = layout == "master" and "primary" or layout
  barWidget.setText(layout)
  barWidget.setTooltip("Hyprland layout: " .. layout)
end

local function refresh()
  if refreshing then
    return
  end

  refreshing = true
  noctalia.runAsync("hyprctl -j getoption general:layout", function(result)
    refreshing = false

    if result.exitCode ~= 0 then
      render("?")
      noctalia.log(result.stderr)
      return
    end

    local option, err = noctalia.json.decode(result.stdout)
    if option == nil or option.str == nil or option.str == "" then
      render("?")
      noctalia.log(err or "Hyprland did not return a layout")
      return
    end

    render(option.str)
  end)
end

barWidget.setGlyph("layout-dashboard")
render("...")

function update()
  noctalia.setUpdateInterval(1000)
  refresh()
end
