-- Run from the repository root with Lua 5.4.
local ENTRY = "modules/parts/noctalia/global-workspaces/widget.luau"
local RS = "\030"

local function instance(outputName, vertical, documents)
  local requests, intervals, trees, commands = {}, {}, {}, {}
  local throwNextLaunch = false
  local function render(tree)
    local keys = {}
    local function visit(node, isRoot)
      assert(type(node) == "table" and type(node.props) == "table", "render nodes need props")
      local key = node.props.key
      assert(type(key) == "string" and key ~= "", "native renderer requires props.key on root and controls")
      assert(not keys[key], "props.key must be unique in one rendered tree: " .. key)
      keys[key] = true
      if not isRoot and node.type == "button" then
        assert(node.props.controlSize == nil, "do not override native compact control sizing")
      end
      for _, child in ipairs(node.children or {}) do visit(child, false) end
    end
    visit(tree, true) -- Deliberately ignore node.key; Noctalia reads props.key.
    trees[#trees + 1] = tree
  end
  local env = {
    barWidget = {
      outputName = function() return outputName end,
      isVertical = function() return vertical end,
      render = render,
    },
    noctalia = {
      runAsync = function(command, callback)
        commands[#commands + 1] = command
        if throwNextLaunch then
          throwNextLaunch = false
          error("synchronous launch failure")
        end
        if type(callback) == "function" then requests[#requests + 1] = callback end
      end,
      setUpdateInterval = function(value) intervals[#intervals + 1] = value end,
      json = {
        decode = function(value)
          if documents[value] == nil then error("bad JSON fixture: " .. value) end
          if documents[value] == false then error("decode failure") end
          return documents[value]
        end,
      },
    },
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    type = type,
    tostring = tostring,
    string = string,
    table = table,
    math = math,
    pcall = pcall,
    error = error,
  }
  assert(loadfile(ENTRY, "t", env))()
  return {
    env = env,
    requests = requests,
    intervals = intervals,
    trees = trees,
    commands = commands,
    output = function(value) outputName = value end,
    orientation = function(value) vertical = value end,
    throwNextLaunch = function() throwNextLaunch = true end,
  }
end

local function identity(address, kind, name, id)
  local value = { address = address, type = kind, name = name }
  if id ~= nil then value.id = id end
  return value
end

local function workspace(address, kind, name, monitorName, monitorID, id)
  local value = identity(address, kind, name, id)
  value.monitor = monitorName
  value.monitorID = monitorID
  return value
end

local function monitor(name, id, focused, active, special)
  return {
    name = name,
    id = id,
    focused = focused,
    activeWorkspace = active,
    specialWorkspace = special or { address = "", type = "", name = "" },
  }
end

local function activeWindow(workspaceIdentity, monitorID)
  if workspaceIdentity == nil then return {} end
  return { workspace = workspaceIdentity, monitor = monitorID }
end

local function documentsFor(workspaces, monitors, window, documents)
  documents.workspaces = workspaces
  documents.monitors = monitors
  documents.window = window
  return "workspaces" .. RS .. "monitors" .. RS .. "window"
end

local function complete(widget, index, result)
  local callback = assert(widget.requests[index], "missing pending request")
  widget.requests[index] = false
  callback(result)
end

local function success(widget, index, workspaces, monitors, window, documents)
  complete(widget, index, {
    exitCode = 0,
    stdout = documentsFor(workspaces, monitors, window, documents),
  })
end

local function buttons(tree)
  local result = {}
  local function visit(node)
    if node.type == "button" then result[#result + 1] = node end
    for _, child in ipairs(node.children or {}) do visit(child) end
  end
  visit(tree)
  return result
end

local function click(widget, button)
  local before = #widget.commands
  if button.props.onClick then button.props.onClick() end
  return widget.commands[before + 1]
end

local function unquoteDispatch(command)
  local prefix = "hyprctl dispatch "
  assert(command:sub(1, #prefix) == prefix, "unexpected dispatch command prefix")
  local quoted = command:sub(#prefix + 1)
  assert(quoted:sub(1, 1) == "'", "dispatch expression must be shell quoted")
  local parts, index = {}, 2
  while index <= #quoted do
    if quoted:sub(index, index + 3) == "'\\''" then
      parts[#parts + 1] = "'"
      index = index + 4
    elseif quoted:sub(index, index) == "'" then
      assert(index == #quoted, "unexpected trailing shell text")
      return table.concat(parts)
    else
      parts[#parts + 1] = quoted:sub(index, index)
      index = index + 1
    end
  end
  error("unterminated shell-quoted dispatch")
end

local function evaluateDispatch(command)
  local calls = {}
  local hl = { dsp = {
    focus = function(options)
      assert(type(options) == "table" and type(options.workspace) == "string", "focus dispatcher argument shape")
      calls[#calls + 1] = { kind = "focus", selector = options.workspace }
    end,
    workspace = { toggle_special = function(selector)
      assert(type(selector) == "string", "special dispatcher argument type")
      calls[#calls + 1] = { kind = "special", selector = selector }
    end },
  } }
  local expression = unquoteDispatch(command)
  local chunk, err = load(expression, "workspace dispatch fixture", "t", { hl = hl })
  assert(chunk, err)
  chunk()
  assert(#calls == 1, "expression must invoke exactly one restricted dispatcher")
  return calls[1]
end

local function expectDispatch(widget, button, kind, selector, label)
  local command = click(widget, button)
  local actual = evaluateDispatch(assert(command, "expected enabled workspace callback"))
  assert(actual.kind == kind and actual.selector == selector,
    (label or "dispatcher selector mismatch") .. ": " .. actual.kind .. " " .. actual.selector)
  return command
end

local function expectList(tree, labels)
  assert(tree.type == "row" or tree.type == "column", "workspace controls must remain in a native container")
  local items = buttons(tree)
  assert(#items == #labels, "unexpected workspace control count")
  for index, label in ipairs(labels) do
    assert(items[index].props.text == label, "workspace order/label mismatch at " .. index)
  end
  return items
end

-- Numbered workspaces sort by ID; ID-less rows sort by canonical address.
-- Display names may collide and may change without changing identity.
local docs = {}
local widget = instance("DP-1", false, docs)
local all = {
  workspace("9", "normal", "Nine", "DP-2", 2, 9),
  workspace("named:beta", "normal", "Shared", "DP-2", 2),
  workspace("named:alpha", "normal", "Shared", "DP-1", 1),
  workspace("2", "normal", "Two", "DP-1", 1, 2),
}
local monitors = {
  monitor("DP-2", 2, false, identity("9", "normal", "Nine", 9)),
  monitor("DP-1", 1, true, identity("named:alpha", "normal", "Shared")),
}
local window = activeWindow(identity("named:alpha", "normal", "Shared"), 1)

assert(widget.trees[1], "entrypoint must render at load")
assert(#widget.intervals == 1 and widget.intervals[1] == 1000, "poll interval must be set once during initialization")
widget.env.update()
assert(#widget.intervals == 1, "update must not reset the poll interval")
assert(#widget.requests == 1, "update must start one snapshot request")
assert(widget.commands[1] == "workspaces=$(timeout 2s hyprctl -j workspaces) && monitors=$(timeout 2s hyprctl -j monitors) && activewindow=$(timeout 2s hyprctl -j activewindow) && printf '%s\\036%s\\036%s' \"$workspaces\" \"$monitors\" \"$activewindow\"", "snapshot command must fetch exactly three bounded JSON documents")
local beforePending = #widget.trees
widget.output("DP-2")
widget.orientation(true)
widget.env.update()
assert(#widget.requests == 1, "polling must not overlap an in-flight request")
assert(#widget.intervals == 1, "pending update must not reset interval")
assert(#widget.trees > beforePending and widget.trees[#widget.trees].type == "column", "pending poll must re-render changed bar context")
success(widget, 1, all, monitors, window, docs)
local tree = widget.trees[#widget.trees]
local ordered = expectList(tree, { "2", "9", "Shared", "Shared" })
assert(ordered[1].props.selected == false and ordered[2].props.selected == false, "focused ID-less workspace must not select numbered rows")
assert(ordered[3].props.selected == false and ordered[4].props.selected == false, "focused output bar must not select another monitor's duplicate display name")
local initialRootKey = tree.props.key
local initialAlphaKey, initialBetaKey = ordered[3].props.key, ordered[4].props.key
assert(initialAlphaKey ~= initialBetaKey, "same display name must have distinct canonical keys")

-- Focus owner changes, a workspace moves and is renamed, another is inserted,
-- and orientation changes. Canonical keys remain stable across every mutation.
widget.output("DP-1")
widget.orientation(false)
widget.env.update()
success(widget, 2, all, monitors, window, docs)
tree = widget.trees[#widget.trees]
ordered = expectList(tree, { "2", "9", "Shared", "Shared" })
assert(tree.props.key == initialRootKey, "root props.key must stay stable")
assert(ordered[3].props.key == initialAlphaKey and ordered[4].props.key == initialBetaKey, "ID-less item keys must use canonical address, not display name")
assert(ordered[3].props.selected == true, "focused ID-less active-window workspace must select on its owner bar")
local oldAlphaButton, oldBetaButton = ordered[3], ordered[4]

local renamed = {
  workspace("9", "normal", "Nine", "DP-2", 2, 9),
  workspace("named:aardvark", "normal", "New", "DP-1", 1),
  workspace("named:beta", "normal", "Shared", "DP-2", 2),
  workspace("named:alpha", "normal", "Renamed", "DP-2", 2),
  workspace("2", "normal", "Two", "DP-1", 1, 2),
}
local movedMonitors = {
  monitor("DP-2", 2, true, identity("named:alpha", "normal", "Renamed")),
  monitor("DP-1", 1, false, identity("2", "normal", "Two", 2)),
}
widget.output("DP-2")
widget.env.update()
success(widget, 3, renamed, movedMonitors, activeWindow(identity("named:alpha", "normal", "Renamed"), 2), docs)
tree = widget.trees[#widget.trees]
ordered = expectList(tree, { "2", "9", "New", "Renamed", "Shared" })
assert(ordered[4].props.key == initialAlphaKey, "move and display rename must preserve canonical key")
assert(ordered[5].props.key == initialBetaKey, "insertion before an item must not retarget its key")
assert(ordered[4].props.selected == true, "renamed workspace remains selected by its stable address")
expectDispatch(widget, ordered[4], "focus", "name:named:alpha", "renaming must not replace the canonical activation selector")
assert(click(widget, oldAlphaButton) == nil, "callback for a moved workspace must be stale")

widget.env.update()
local removed = {
  workspace("9", "normal", "Nine", "DP-2", 2, 9),
  workspace("named:beta-v2", "normal", "Shared", "DP-2", 2),
  workspace("named:alpha", "normal", "Renamed", "DP-2", 2),
  workspace("2", "normal", "Two", "DP-1", 1, 2),
}
success(widget, 4, removed, movedMonitors, activeWindow(identity("named:alpha", "normal", "Renamed"), 2), docs)
tree = widget.trees[#widget.trees]
ordered = expectList(tree, { "2", "9", "Renamed", "Shared" })
assert(ordered[3].props.key == initialAlphaKey and ordered[4].props.key ~= initialBetaKey, "removed/changed address must not inherit another workspace key")
assert(click(widget, oldBetaButton) == nil, "callback for a changed canonical address must be stale")
assert(tree.props.key == initialRootKey, "root key remains stable after removal")

-- Numeric-ID/address consistency is validated; numbered activation remains canonical.
local numericDocs = {}
local numeric = instance("DP-1", false, numericDocs)
numeric.env.update()
local numericRows = { workspace("3", "normal", "Three", "DP-1", 1, 3) }
local numericMonitor = { monitor("DP-1", 1, true, identity("3", "normal", "Three", 3)) }
success(numeric, 1, numericRows, numericMonitor, activeWindow(identity("3", "normal", "Three", 3), 1), numericDocs)
local numericButton = buttons(numeric.trees[#numeric.trees])[1]
assert(numericButton.props.text == "3", "numbered workspace label must use its numeric ID")
expectDispatch(numeric, numericButton, "focus", "3", "numbered workspace uses its numeric selector")

-- Canonical named addresses, not mutable display labels, drive selectors.
local namedDocs = {}
local namedWidget = instance("DP-1", false, namedDocs)
namedWidget.env.update()
local namedAddresses = {
  "named:apostrophe' address",
  'named:double"quote',
  "named:backslash\\path",
  'named:evil"); os.execute("touch /tmp/noctalia-test"); -- $(touch /tmp/noctalia-shell-test) ; |',
  "named:other",
}
local namedRows = {
  workspace(namedAddresses[4], "normal", "Friendly Label", "DP-1", 1),
  workspace(namedAddresses[2], "normal", "Friendly Label", "DP-1", 1),
  workspace(namedAddresses[1], "normal", "Friendly Label", "DP-1", 1),
  workspace(namedAddresses[3], "normal", "Friendly Label", "DP-1", 1),
  workspace(namedAddresses[5], "normal", "Friendly Label", "DP-1", 1),
  workspace("3", "normal", "Three", "DP-1", 1, 3),
}
success(namedWidget, 1, namedRows, numericMonitor,
  activeWindow(identity("3", "normal", "Three", 3), 1), namedDocs)
local namedButtons = buttons(namedWidget.trees[#namedWidget.trees])
for index = 2, #namedButtons do
  assert(namedButtons[index].props.text == "Friendly Label", "ID-less entries use display names, including duplicates")
end
table.sort(namedAddresses)
for index, address in ipairs(namedAddresses) do
  local command = expectDispatch(namedWidget, namedButtons[index + 1], "focus", "name:" .. address,
    "named address must survive Lua and shell quoting")
  assert(command:sub(1, #"hyprctl dispatch '") == "hyprctl dispatch '", "Lua expression must be shell-quoted as one argument")
end

-- Special overlays select the focused window workspace or none, and never
-- select a special on a bar hosted by another output.
local special = workspace("special:scratch", "special", "special:scratch", "DP-1", 1)
local normal = workspace("named:regular", "normal", "Regular", "DP-1", 1)
local overlayRows = { special, normal }
local activeNormal = identity("named:regular", "normal", "Regular")
local specialMonitor = { monitor("DP-1", 1, true, activeNormal, identity("special:scratch", "special", "special:scratch")) }

local specialDocs = {}
local focusedSpecial = instance("DP-1", false, specialDocs)
focusedSpecial.env.update()
success(focusedSpecial, 1, overlayRows, specialMonitor,
  activeWindow(identity("special:scratch", "special", "special:scratch"), 1), specialDocs)
local specialButtons = buttons(focusedSpecial.trees[#focusedSpecial.trees])
assert(specialButtons[1].props.text == "Regular" and specialButtons[2].props.text == "special:scratch", "ID-less controls sort by canonical address")
assert(specialButtons[2].props.selected == true and specialButtons[1].props.selected == false, "focused special window selects only its special workspace")
expectDispatch(focusedSpecial, specialButtons[2], "special", "scratch", "special selector uses canonical address suffix")

local regularOverlayDocs = {}
local regularOverlay = instance("DP-1", false, regularOverlayDocs)
regularOverlay.env.update()
success(regularOverlay, 1, overlayRows, specialMonitor,
  activeWindow(activeNormal, 1), regularOverlayDocs)
local regularOverlayButtons = buttons(regularOverlay.trees[#regularOverlay.trees])
assert(regularOverlayButtons[1].props.selected == true and regularOverlayButtons[2].props.selected == false, "focused regular window remains selected during a special overlay")

local noWindowDocs = {}
local noWindow = instance("DP-1", false, noWindowDocs)
noWindow.env.update()
success(noWindow, 1, overlayRows, specialMonitor, {}, noWindowDocs)
for _, button in ipairs(buttons(noWindow.trees[#noWindow.trees])) do
  assert(button.props.selected == false, "special overlay with no active window selects nothing")
end

local emptyNormalDocs = {}
local emptyNormal = instance("DP-1", false, emptyNormalDocs)
emptyNormal.env.update()
success(emptyNormal, 1, { normal }, {
  monitor("DP-1", 1, true, activeNormal),
}, {}, emptyNormalDocs)
assert(buttons(emptyNormal.trees[#emptyNormal.trees])[1].props.selected == true,
  "normal focused active workspace stays selected when it has no windows")

local remoteDocs = {}
local remoteBar = instance("DP-2", false, remoteDocs)
remoteBar.env.update()
success(remoteBar, 1, overlayRows, specialMonitor,
  activeWindow(identity("special:scratch", "special", "special:scratch"), 1), remoteDocs)
for _, button in ipairs(buttons(remoteBar.trees[#remoteBar.trees])) do
  assert(button.props.selected == false, "focused special workspace must not select on another output's bar")
end

-- Hyprland permits a normal named workspace and a special workspace to share
-- one canonical address; type remains part of every identity operation.
local collisionAddress = "special:scratch"
local normalCollision = workspace(collisionAddress, "normal", "Regular alias", "DP-1", 1)
local specialCollision = workspace(collisionAddress, "special", collisionAddress, "DP-1", 1)
local collisionRows = { specialCollision, normalCollision }
local collisionMonitor = { monitor("DP-1", 1, true,
  identity(collisionAddress, "normal", "Regular alias"),
  identity(collisionAddress, "special", collisionAddress)) }
local normalFocusDocs = {}
local normalFocus = instance("DP-1", false, normalFocusDocs)
normalFocus.env.update()
success(normalFocus, 1, collisionRows, collisionMonitor,
  activeWindow(identity(collisionAddress, "normal", "Regular alias"), 1), normalFocusDocs)
local collisionButtons = buttons(normalFocus.trees[#normalFocus.trees])
assert(collisionButtons[1].props.text == "Regular alias" and collisionButtons[2].props.text == collisionAddress,
  "type tie-break must be deterministic for equal ID-less addresses")
assert(collisionButtons[1].props.key ~= collisionButtons[2].props.key,
  "normal and special address collision needs distinct props.key values")
assert(collisionButtons[1].props.selected == true and collisionButtons[2].props.selected == false,
  "normal active window selects only its typed identity")
local normalCollisionCommand = expectDispatch(normalFocus, collisionButtons[1], "focus",
  "name:" .. collisionAddress, "normal collision uses canonical named workspace selector")
local specialCollisionCommand = expectDispatch(normalFocus, collisionButtons[2], "special", "scratch",
  "special collision uses special toggle selector")
assert(normalCollisionCommand ~= specialCollisionCommand, "typed address collision must dispatch distinct commands")

local specialFocusDocs = {}
local specialFocus = instance("DP-1", false, specialFocusDocs)
specialFocus.env.update()
success(specialFocus, 1, collisionRows, collisionMonitor,
  activeWindow(identity(collisionAddress, "special", collisionAddress), 1), specialFocusDocs)
local specialFocusButtons = buttons(specialFocus.trees[#specialFocus.trees])
assert(specialFocusButtons[1].props.key == collisionButtons[1].props.key
  and specialFocusButtons[2].props.key == collisionButtons[2].props.key,
  "typed identity keys must stay stable when focused window changes")
assert(specialFocusButtons[1].props.selected == false and specialFocusButtons[2].props.selected == true,
  "special active window selects only its typed identity")

-- Canonical default special address toggles with an empty argument; named
-- special suffix quoting is covered in the same fixture.
local specialSelectorDocs = {}
local specialSelector = instance("DP-1", false, specialSelectorDocs)
specialSelector.env.update()
local specialRows = {
  workspace("special:scratch", "special", "special:scratch", "DP-1", 1),
  workspace("special:special", "special", "special:special", "DP-1", 1),
  workspace('special:evil\' "double" \\path; os.execute("touch /tmp/noctalia-test"); -- $(touch /tmp/noctalia-shell-test) |', "special", "Evil", "DP-1", 1),
  normal,
}
success(specialSelector, 1, specialRows, specialMonitor,
  activeWindow(activeNormal, 1), specialSelectorDocs)
local specialSelectorButtons = buttons(specialSelector.trees[#specialSelector.trees])
expectDispatch(specialSelector, specialSelectorButtons[2], "special",
  'evil\' "double" \\path; os.execute("touch /tmp/noctalia-test"); -- $(touch /tmp/noctalia-shell-test) |',
  "adversarial special suffix must roundtrip as a Lua literal and shell argument")
expectDispatch(specialSelector, specialSelectorButtons[4], "special", "",
  "canonical default special address must use empty toggle argument")

-- Missing or ambiguous focused monitor preserves the complete list unselected.
local function noMonitorSelection(rows, monitorRows, windowDoc, label)
  local fixtureDocs = {}
  local fixture = instance("DP-1", false, fixtureDocs)
  fixture.env.update()
  success(fixture, 1, rows, monitorRows, windowDoc, fixtureDocs)
  local items = buttons(fixture.trees[#fixture.trees])
  assert(#items == #rows, label .. " must preserve all workspaces")
  for _, button in ipairs(items) do assert(button.props.selected == false, label .. " must select none") end
end
noMonitorSelection({ workspace("1", "normal", "One", "DP-1", 1, 1) }, {
  monitor("DP-1", 1, false, identity("1", "normal", "One", 1)),
}, {}, "no focused monitor")
noMonitorSelection({
  workspace("1", "normal", "One", "DP-1", 1, 1),
  workspace("2", "normal", "Two", "DP-2", 2, 2),
}, {
  monitor("DP-1", 1, true, identity("1", "normal", "One", 1)),
  monitor("DP-2", 2, true, identity("2", "normal", "Two", 2)),
}, activeWindow(identity("1", "normal", "One", 1), 1), "multiple focused monitors")

-- Failed, malformed, and mis-shaped snapshots publish only a disabled control.
local function rejected(result, docs, label)
  local fixture = instance("DP-1", false, docs or {})
  fixture.env.update()
  complete(fixture, 1, result)
  local controls = buttons(fixture.trees[#fixture.trees])
  assert(#controls == 1 and controls[1].props.enabled == false and controls[1].props.onClick == nil,
    (label or "failed snapshot") .. " must render one disabled, inert control")
  assert(click(fixture, controls[1]) == nil, "disabled control must not dispatch")
end

rejected({ exitCode = 1, stdout = "", stderr = "failed" }, nil, "failed query")
rejected({ exitCode = 0, stdout = "not-json" }, nil, "missing RS framing")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "extra" }, { w = {}, m = {}, a = {} }, "extra RS")
rejected({ exitCode = 0, stdout = RS .. "m" .. RS .. "a" }, { w = {}, m = {}, a = {} }, "empty first document")
rejected({ exitCode = 0, stdout = "w" .. RS .. RS .. "a" }, { w = {}, m = {}, a = {} }, "empty middle document")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS }, { w = {}, m = {}, a = {} }, "empty last document")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" }, { w = false, m = {}, a = {} }, "decode type error")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" }, { w = {}, m = { name = true }, a = {} }, "monitor document not array")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" }, { w = { foo = true }, m = {}, a = {} }, "workspace document not array")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" }, { w = {
  workspace("named:a", "normal", "Same", "DP-1", 1), workspace("named:a", "normal", "Other", "DP-1", 1),
}, m = {}, a = {} }, "duplicate canonical address")
local inconsistentDocs = {}
local inconsistentRows = { workspace("2", "normal", "Two", "DP-1", 1, 1) }
local inconsistentMonitors = { monitor("DP-1", 1, true, identity("2", "normal", "Two", 1)) }
local inconsistentWindow = activeWindow(identity("2", "normal", "Two", 1), 1)
rejected({ exitCode = 0, stdout = documentsFor(inconsistentRows, inconsistentMonitors, inconsistentWindow, inconsistentDocs) },
  inconsistentDocs, "otherwise-owned numbered ID/address mismatch")
local numberedSpecialDocs = {}
local numberedSpecialRows = {
  workspace("1", "normal", "One", "DP-1", 1, 1),
  workspace("special:scratch", "special", "special:scratch", "DP-1", 1, 2),
}
local numberedSpecialMonitors = { monitor("DP-1", 1, true,
  identity("1", "normal", "One", 1), identity("special:scratch", "special", "special:scratch")) }
local numberedSpecialWindow = activeWindow(identity("1", "normal", "One", 1), 1)
rejected({ exitCode = 0, stdout = documentsFor(numberedSpecialRows, numberedSpecialMonitors, numberedSpecialWindow, numberedSpecialDocs) },
  numberedSpecialDocs, "source-impossible numbered special workspace")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" }, { w = {
  { address = "named:a", type = "normal", name = "A", monitor = "DP-1", monitorID = "1" },
}, m = {}, a = {} }, "monitorID must match source JSON integer type")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" }, { w = {}, m = {}, a = { workspace = "wrong type" } }, "active window identity type error")

-- Sync launch exceptions clear the guard, remove stale clickability, and recover.
local recoveryDocs = {}
local recovery = instance("DP-1", false, recoveryDocs)
recovery.env.update()
success(recovery, 1, { workspace("1", "normal", "One", "DP-1", 1, 1) }, {
  monitor("DP-1", 1, true, identity("1", "normal", "One", 1)),
}, activeWindow(identity("1", "normal", "One", 1), 1), recoveryDocs)
local oldButton = buttons(recovery.trees[#recovery.trees])[1]
recovery.throwNextLaunch()
recovery.env.update()
local failedTree = recovery.trees[#recovery.trees]
local failedControls = buttons(failedTree)
assert(#failedControls == 1 and failedControls[1].props.enabled == false, "synchronous launch failure clears prior snapshot")
assert(click(recovery, oldButton) == nil, "stale callback after synchronous failure must not dispatch")
recovery.env.update()
assert(#recovery.requests == 2, "request guard must recover after a synchronous launch exception")
success(recovery, 2, { workspace("1", "normal", "One", "DP-1", 1, 1) }, {
  monitor("DP-1", 1, true, identity("1", "normal", "One", 1)),
}, activeWindow(identity("1", "normal", "One", 1), 1), recoveryDocs)
assert(buttons(recovery.trees[#recovery.trees])[1].props.selected == true, "recovered snapshot must be usable")

-- A completed async failure also clears old state and allows the next poll.
recovery.env.update()
local staleAfterFailure = buttons(recovery.trees[#recovery.trees])[1]
complete(recovery, 3, { exitCode = 1, stdout = "" })
assert(click(recovery, staleAfterFailure) == nil, "stale callback after asynchronous failure must not dispatch")
recovery.env.update()
success(recovery, 4, { workspace("1", "normal", "One", "DP-1", 1, 1) }, {
  monitor("DP-1", 1, true, identity("1", "normal", "One", 1)),
}, activeWindow(identity("1", "normal", "One", 1), 1), recoveryDocs)

print("Noctalia global workspaces regression tests passed")
