-- Run from the repository root with Lua 5.4.
local ENTRY = "modules/parts/noctalia/workspace-layout/widget.luau"
local text, tooltip, glyph
local requests, intervals, logs, decodeResults = {}, {}, {}, {}
barWidget = {
  setText = function(value) text = value end,
  setTooltip = function(value) tooltip = value end,
  setGlyph = function(value) glyph = value end,
}
noctalia = {
  runAsync = function(command, callback)
    requests[#requests + 1] = { command = command, callback = callback }
  end,
  setUpdateInterval = function(value) intervals[#intervals + 1] = value end,
  log = function(value) logs[#logs + 1] = value end,
  json = {
    decode = function(value)
      local decoded = decodeResults[value]
      if decoded == nil then return nil, "invalid JSON: " .. tostring(value) end
      return decoded
    end,
  },
}

dofile(ENTRY)

local function expect(value, label)
  assert(text == value, (label or "text") .. ": expected " .. tostring(value) .. ", got " .. tostring(text))
  assert(tooltip == "Hyprland layout: " .. value,
    (label or "tooltip") .. ": unexpected tooltip " .. tostring(tooltip))
end

local function complete(index, result)
  local request = assert(requests[index], "missing request " .. index)
  request.callback(result)
end

local function jsonResult(stdout, decoded)
  decodeResults[stdout] = decoded
  return { exitCode = 0, stdout = stdout, stderr = "" }
end

local function beginRefresh()
  update()
  assert(intervals[#intervals] == 1000, "poll interval must remain one second")
end

local function master(index, orientation, expected)
  beginRefresh()
  local previousText, previousTooltip = text, tooltip
  local layoutRequest = assert(requests[index], "missing layout query")
  assert(layoutRequest.command == "hyprctl -j getoption general:layout", "layout query changed")
  complete(index, jsonResult("layout-" .. index, { str = "master" }))
  assert(text == previousText and tooltip == previousTooltip,
    "master must retain the current display while orientation loads")
  assert(#requests == index + 1, "master layout must issue sequential orientation query")
  update()
  assert(#requests == index + 1, "polling must not overlap an in-flight orientation query")
  local orientationRequest = requests[index + 1]
  assert(orientationRequest.command == "hyprctl -j getoption master:orientation", "orientation query changed")
  complete(index + 1, jsonResult("orientation-" .. index, { str = orientation }))
  expect(expected)
end

assert(glyph == "layout-dashboard", "glyph must remain unchanged")
expect("...", "initial loading state")
assert(#requests == 0, "loading state must not start a query before update")

beginRefresh()
assert(#requests == 1, "update must start one layout query")
assert(requests[1].command == "hyprctl -j getoption general:layout", "layout query changed")
update()
assert(#requests == 1, "polling must not overlap an in-flight layout query")
complete(1, jsonResult("scrolling", { str = "scrolling" }))
expect("scrolling")

master(2, "left", "tall")
master(4, "top", "wide")
master(6, "right", "primary")

beginRefresh()
complete(8, jsonResult("monocle", { str = "monocle" }))
expect("monocle")

-- Failed and malformed layout queries render '?' and release the refresh guard.
beginRefresh()
complete(9, { exitCode = 1, stdout = "", stderr = "layout failed" })
expect("?")
assert(logs[#logs] == "layout failed", "layout command failure must be logged")
beginRefresh()
complete(10, jsonResult("bad-layout", nil))
expect("?")
assert(logs[#logs] == "invalid JSON: bad-layout", "malformed layout JSON must be logged")
beginRefresh()
complete(11, jsonResult("missing-layout", {}))
expect("?")
assert(logs[#logs] == "Hyprland did not return a layout", "missing layout string must be logged")
beginRefresh()
complete(12, jsonResult("empty-layout", { str = "" }))
expect("?")
beginRefresh()
complete(13, jsonResult("wrong-type-layout", { str = false }))
expect("?")

-- Orientation command failures must log an error and release the refresh guard.
local beforeOrientationFailure = #requests
beginRefresh()
complete(beforeOrientationFailure + 1, jsonResult("master-before-failure", { str = "master" }))
local orientationIndex = beforeOrientationFailure + 2
complete(orientationIndex, { exitCode = 1, stdout = "", stderr = "orientation failed" })
expect("?")
assert(logs[#logs] == "orientation failed", "orientation command failure must be logged")

local function orientationError(stdout, decoded, label)
  beginRefresh()
  local layoutIndex = #requests
  complete(layoutIndex, jsonResult("master-" .. label, { str = "master" }))
  local logCount = #logs
  complete(layoutIndex + 1, jsonResult(stdout, decoded))
  expect("?")
  assert(#logs == logCount + 1, label .. " orientation failure must add exactly one log")
end

orientationError("bad-orientation", nil, "malformed")
orientationError("missing-orientation", {}, "missing")
orientationError("empty-orientation", { str = "" }, "empty")
orientationError("wrong-type-orientation", { str = false }, "wrong-type")

-- Polling recovers after an orientation error.
master(#requests + 1, "left", "tall")

print("Noctalia workspace-layout regression tests passed")
