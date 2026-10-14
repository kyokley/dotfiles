-- Run from the repository root with Lua 5.4.
local ENTRY = "modules/parts/noctalia/global-workspaces/widget.luau"
local RS = "\030"
local STUB_SOCAT = "/test-store/bin/socat"
local STUB_SLEEP = "/test-store/bin/sleep"
local RECONNECT_MARKER = "__YOKLEY_GLOBAL_WORKSPACES_RECONNECT__"

local function instance(outputName, vertical, documents, options)
  options = options or {}
  local requests, intervals, trees, commands, frameContexts = {}, {}, {}, {}, {}
  local streamAttempts, streams = {}, {}
  local streamOutcomes = options.streamOutcomes or {}
  local environment = options.environment or {
    XDG_RUNTIME_DIR = "/run/user/1000",
    HYPRLAND_INSTANCE_SIGNATURE = "test-hyprland",
  }
  local throwNextLaunch = false
  local callbackContext = false
  local expectedFocusedOutput, expectedSelectedIndex
  local function render(tree)
    assert(tree.props.key == "global-workspaces" and tree.props.gap == 4,
      "workspace gap must match native Style::spaceXs")
    local keys = {}
    local function visit(node, isRoot)
      assert(type(node) == "table" and type(node.props) == "table", "render nodes need props")
      local key = node.props.key
      assert(type(key) == "string" and key ~= "", "native renderer requires props.key on root and controls")
      assert(not keys[key], "props.key must be unique in one rendered tree: " .. key)
      if key:sub(1, #"workspace-entry-") == "workspace-entry-" then
        assert(node.type == "row" and node.props.radius == 8,
          "workspace pills must use the configured bar capsule radius")
        if vertical then
          assert(node.props.width == nil and node.props.minWidth == 16
            and (node.props.minHeight == 16 or node.props.minHeight == 32),
            "vertical pills must keep full label width and native active-axis sizing")
        else
          assert(node.props.minHeight == 16 and node.props.paddingH == 4.8
            and node.props.width == nil and (node.props.minWidth == 16 or node.props.minWidth == 32),
            "horizontal pills must use native inactive/active minimum widths")
        end
        assert(node.props.fill ~= nil and node.props.onClick and node.props.onHover and node.props.tooltip,
          "each pill must retain palette fill, click, hover, and tooltip behavior")
        assert(node.children[1].type == "label" and node.children[1].props.fontSize == 11,
          "workspace labels must use Noctalia mini typography")
        assert(node.children[1].props.maxWidth == nil,
          "workspace display names must remain complete in both orientations")
        assert(node.children[1].props.fontFamily == nil and node.children[1].props.fontWeight == nil,
          "workspace labels must inherit the configured bar font family and weight")
        local expectedText = ({
          primary = "on_primary",
          secondary = "on_secondary",
          error = "on_error",
          hover = "on_hover",
          ["surface_variant/0.55"] = "on_surface",
        })[node.props.fill]
        assert(node.children[1].props.color == expectedText,
          "workspace label contrast must follow the built-in palette role")
      end
      keys[key] = true
      for _, child in ipairs(node.children or {}) do visit(child, false) end
    end
    visit(tree, true) -- Deliberately ignore node.key; Noctalia reads props.key.
    trees[#trees + 1] = tree
    frameContexts[#frameContexts + 1] = {
      output = outputName,
      vertical = vertical,
      focusedOutput = expectedFocusedOutput,
      selectedIndex = expectedSelectedIndex,
      asyncCallback = callbackContext,
    }
  end
  local env = {
    barWidget = {
      outputName = function()
        if callbackContext then return nil end
        return outputName
      end,
      isVertical = function()
        if callbackContext then return false end
        return vertical
      end,
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
        return true
      end,
      runStream = function(command, callback)
        streamAttempts[#streamAttempts + 1] = { command = command, callback = callback }
        local outcome = table.remove(streamOutcomes, 1)
        if outcome == "throw" then error("synchronous stream launch failure") end
        if outcome == false then return false end
        streams[#streams + 1] = { command = command, callback = callback }
        return true
      end,
      setUpdateInterval = function(value) intervals[#intervals + 1] = value end,
      getenv = function(name) return environment[name] end,
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
  local input = assert(io.open(ENTRY, "r"))
  local source = input:read("*a")
  input:close()
  source = source:gsub("@SOCAT@", function() return STUB_SOCAT end)
  source = source:gsub("@SLEEP@", function() return STUB_SLEEP end)
  assert(not source:find("@SOCAT@", 1, true) and not source:find("@SLEEP@", 1, true),
    "test loader must replace runtime tool placeholders")
  assert(load(source, "@" .. ENTRY, "t", env))()
  return {
    env = env,
    requests = requests,
    intervals = intervals,
    trees = trees,
    frameContexts = frameContexts,
    commands = commands,
    streamAttempts = streamAttempts,
    streams = streams,
    output = function(value) outputName = value end,
    orientation = function(value) vertical = value end,
    expectSelection = function(focusedOutput, selectedIndex)
      expectedFocusedOutput = focusedOutput
      expectedSelectedIndex = selectedIndex
    end,
    deliverAsync = function(callback, result)
      callbackContext = true
      local ok, err = pcall(callback, result)
      callbackContext = false
      if not ok then error(err) end
    end,
    deliverStreamLine = function(callback, line)
      callbackContext = true
      local ok, err = pcall(callback, line)
      callbackContext = false
      if not ok then error(err) end
    end,
    throwNextLaunch = function() throwNextLaunch = true end,
    setEnvironment = function(name, value) environment[name] = value end,
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
  documents.clients = documents.clients or {}
  return "workspaces" .. RS .. "monitors" .. RS .. "window" .. RS .. "clients"
end

local function complete(widget, index, result)
  local callback = assert(widget.requests[index], "missing pending request")
  widget.requests[index] = false
  local before = #widget.trees
  widget.deliverAsync(callback, result)
  assert(#widget.trees > before, "async completion must render a frame")
  for frame = before + 1, #widget.trees do
    assert(widget.frameContexts[frame].asyncCallback, "completion frames must use native no-bar-context callback scope")
  end
end

local function success(widget, index, workspaces, monitors, window, documents)
  complete(widget, index, {
    exitCode = 0,
    stdout = documentsFor(workspaces, monitors, window, documents),
  })
end

local function emitStreamLine(widget, index, line)
  local stream = assert(widget.streams[index], "missing started Hyprland event stream")
  widget.deliverStreamLine(stream.callback, line)
end

local function assertOneListener(widget, environment)
  assert(#widget.streamAttempts == 1 and #widget.streams == 1, "each widget runtime must start one listener")
  local socketPath = environment.XDG_RUNTIME_DIR .. "/hypr/" .. environment.HYPRLAND_INSTANCE_SIGNATURE .. "/.socket2.sock"
  socketPath = string.gsub(socketPath, "[\\'\"]", function(character) return "\\" .. character end)
  local address = "UNIX-CONNECT:" .. socketPath
  local quotedAddress = "'" .. string.gsub(address, "'", "'\\''") .. "'"
  local command = widget.streamAttempts[1].command
  local expected = "while :; do if '" .. STUB_SOCAT .. "' -u " .. quotedAddress
    .. " - 2>/dev/null; then :; fi; printf '%s\\n' '" .. RECONNECT_MARKER .. "'; '"
    .. STUB_SLEEP .. "' 1; done"
  assert(command == expected, "stream command must use quoted absolute tools and reconnect backoff: " .. command)
end

local function buttons(tree)
  local result = {}
  local function visit(node)
    local key = node.props and node.props.key or ""
    if node.type == "button" or key:sub(1, #"workspace-entry-") == "workspace-entry-" then
      result[#result + 1] = node
    end
    for _, child in ipairs(node.children or {}) do visit(child) end
  end
  visit(tree)
  return result
end

local function labelOf(node)
  if node.type == "button" then return node.props.text end
  return node.children[1].props.text
end

local function selected(node)
  return node.props.fill == "primary"
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

local function assertFramesUseHostContext(widget, firstFrame)
  local failures = {}
  for index = firstFrame, #widget.trees do
    local tree = widget.trees[index]
    local context = widget.frameContexts[index]
    local expectedOrientation = context.vertical and "column" or "row"
    if tree.type ~= expectedOrientation then
      failures[#failures + 1] = string.format("frame %d: expected %s, got %s (async=%s)", index,
        expectedOrientation, tostring(tree.type), tostring(context.asyncCallback))
    end
    local items = buttons(tree)
    for itemIndex, item in ipairs(items) do
      local expected = context.output ~= nil and context.output == context.focusedOutput
        and context.selectedIndex == itemIndex
      local selected = item.props.fill == "primary"
      if selected ~= expected then
        failures[#failures + 1] = string.format("frame %d workspace %d: expected selected=%s, fill=%s (output=%s, async=%s)",
          index, itemIndex, tostring(expected), tostring(item.props.fill), tostring(context.output), tostring(context.asyncCallback))
      end
    end
  end
  assert(#failures == 0, table.concat(failures, "\n"))
end

local function expectList(tree, labels)
  assert(tree.type == "row" or tree.type == "column", "workspace controls must remain in a native container")
  local items = buttons(tree)
  assert(#items == #labels, "unexpected workspace control count")
  for index, label in ipairs(labels) do
    assert(labelOf(items[index]) == label, "workspace order/label mismatch at " .. index)
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

local styleDocs = {
  clients = {
    { workspace = identity("9", "normal", "Nine", 9), urgent = false },
    { workspace = identity("named:beta", "normal", "Shared"), urgent = true },
  },
}
local styleEnvironment = {
  XDG_RUNTIME_DIR = "/run/user/1000/runtime space 'quoted' \\segment",
  HYPRLAND_INSTANCE_SIGNATURE = 'sig "double";$(touch /tmp/noctalia-shell-test)',
}
local styleWidget = instance("DP-1", false, styleDocs, { environment = styleEnvironment })
assert(#styleWidget.requests == 1, "plugin load must start an immediate initial snapshot")
assertOneListener(styleWidget, styleEnvironment)
styleWidget.expectSelection("DP-1", 3)
styleWidget.env.update()
success(styleWidget, 1, all, monitors, window, styleDocs)
local stylePills = buttons(styleWidget.trees[#styleWidget.trees])
assert(stylePills[1].props.fill == "surface_variant/0.55" and stylePills[1].props.minWidth == 16,
  "empty workspace uses dim surface_variant and inactive pill size")
assert(stylePills[2].props.fill == "secondary" and stylePills[2].props.minWidth == 16,
  "active workspace on another output uses occupied color and does not expand on this bar")
assert(stylePills[3].props.fill == "primary" and stylePills[3].props.minWidth == 32,
  "focused owning-output workspace uses primary color and active pill size")
assert(stylePills[4].props.fill == "error" and stylePills[4].props.minWidth == 16,
  "urgent occupied workspace uses native error color")
stylePills[1].props.onHover("true")
assert(buttons(styleWidget.trees[#styleWidget.trees])[1].props.fill == "hover",
  "workspace hover uses the native hover palette")
buttons(styleWidget.trees[#styleWidget.trees])[1].props.onHover("false")

-- Relevant socket events start immediate catch-up snapshots; bursts coalesce
-- to one follow-up, even when that response fails. Unrelated lines are ignored.
emitStreamLine(styleWidget, 1, "windowtitle>>unrelated")
emitStreamLine(styleWidget, 1, "not-an-event")
assert(#styleWidget.requests == 1, "unrelated or malformed socket lines must not refresh")
local relevantEvents = {
  "workspacev2", "focusedmonv2", "activespecialv2", "createworkspacev2",
  "destroyworkspacev2", "renameworkspace", "changeworkspaceid", "moveworkspacev2",
  "openwindow", "closewindow", "movewindowv2", "urgent", "activewindowv2",
  "monitoraddedv2", "monitorremovedv2",
}
for index, event in ipairs(relevantEvents) do
  emitStreamLine(styleWidget, 1, event .. ">>payload-" .. index)
  if index == 1 then
    assert(#styleWidget.requests == 2, "relevant event must launch catch-up immediately")
    local frame = styleWidget.trees[#styleWidget.trees]
    assert(styleWidget.frameContexts[#styleWidget.frameContexts].asyncCallback
      and selected(buttons(frame)[3]), "stream callback must render with cached host focus context")
  else
    assert(#styleWidget.requests == 2, "event burst must not overlap snapshot requests")
  end
end
emitStreamLine(styleWidget, 1, RECONNECT_MARKER)
assert(#styleWidget.requests == 2, "reconnect catch-up joins pending event burst")
success(styleWidget, 2, all, monitors, window, styleDocs)
assert(#styleWidget.requests == 3, "event burst drains as exactly one immediate follow-up")
emitStreamLine(styleWidget, 1, "activewindowv2>>queued-during-followup")
complete(styleWidget, 3, { exitCode = 1, stdout = "" })
assert(#styleWidget.requests == 4, "events pending across a failed snapshot still trigger one recovery query")
success(styleWidget, 4, all, monitors, window, styleDocs)
emitStreamLine(styleWidget, 1, RECONNECT_MARKER)
assert(#styleWidget.requests == 5, "listener reconnect marker catches up after reconnect")
success(styleWidget, 5, all, monitors, window, styleDocs)
styleWidget.env.update()
assert(#styleWidget.requests == 6 and #styleWidget.streamAttempts == 1,
  "five-second fallback poll remains active without starting another listener")
success(styleWidget, 6, all, monitors, window, styleDocs)

assert(widget.trees[1], "entrypoint must render at load")
assert(#widget.intervals == 1 and widget.intervals[1] == 5000, "fallback poll interval must be set once during initialization")
widget.expectSelection("DP-1", 3)
widget.env.update()
assert(#widget.intervals == 1, "update must not reset the poll interval")
assert(#widget.requests == 1, "update must start one snapshot request")
assert(widget.commands[1] == "workspaces=$(timeout 2s hyprctl -j workspaces) && monitors=$(timeout 2s hyprctl -j monitors) && activewindow=$(timeout 2s hyprctl -j activewindow) && clients=$(timeout 2s hyprctl -j clients) && printf '%s\\036%s\\036%s\\036%s' \"$workspaces\" \"$monitors\" \"$activewindow\" \"$clients\"", "snapshot command must fetch exactly four bounded JSON documents")
local beforePending = #widget.trees
widget.output("DP-2")
widget.orientation(true)
widget.env.update()
assert(#widget.requests == 1, "polling must not overlap an in-flight request")
assert(#widget.intervals == 1, "pending update must not reset interval")
assert(#widget.trees > beforePending and widget.trees[#widget.trees].type == "column", "pending poll must re-render changed bar context")
local firstStableFrame = #widget.trees + 1
success(widget, 1, all, monitors, window, docs)
local tree = widget.trees[#widget.trees]
assert(tree.type == "column", "async completion must preserve latest vertical bar context")
local ordered = expectList(tree, { "2", "9", "Shared", "Shared" })
assert(not selected(ordered[1]) and not selected(ordered[2]), "focused ID-less workspace must not select numbered rows")
assert(not selected(ordered[3]) and not selected(ordered[4]), "focused output bar must not select another monitor's duplicate display name")
assert(ordered[2].props.minWidth == 16,
  "active workspace on another monitor must not expand on this unfocused bar")
local initialRootKey = tree.props.key
local initialAlphaKey, initialBetaKey = ordered[3].props.key, ordered[4].props.key
assert(initialAlphaKey ~= initialBetaKey, "same display name must have distinct canonical keys")

-- Focus owner changes, a workspace moves and is renamed, another is inserted,
-- and orientation changes. Canonical keys remain stable across every mutation.
widget.output("DP-1")
widget.orientation(true)
widget.expectSelection("DP-1", 3)
widget.env.update()
success(widget, 2, all, monitors, window, docs)
tree = widget.trees[#widget.trees]
ordered = expectList(tree, { "2", "9", "Shared", "Shared" })
assert(tree.type == "column", "identical poll completion must preserve vertical orientation")
assertFramesUseHostContext(widget, firstStableFrame)
assert(tree.props.key == initialRootKey, "root props.key must stay stable")
assert(ordered[3].props.key == initialAlphaKey and ordered[4].props.key == initialBetaKey, "ID-less item keys must use canonical address, not display name")
assert(selected(ordered[3]), "focused ID-less active-window workspace must select on its owner bar")
assert(ordered[3].props.minHeight == 32,
  "only the selected workspace receives active-pill expansion on its owning bar")
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
widget.output("DP-1")
widget.orientation(true)
widget.expectSelection("DP-1", 3)
widget.env.update()
assert(#widget.requests == 3, "pending contextual updates must not start another poll")
widget.output(nil)
widget.orientation(false)
widget.expectSelection("DP-1", 3)
widget.env.update()
assert(widget.frameContexts[#widget.frameContexts].output == nil
  and widget.trees[#widget.trees].type == "row",
  "genuinely unknown output must replace prior known output and current orientation")
  for _, button in ipairs(buttons(widget.trees[#widget.trees])) do
   assert(button.props.fill ~= "primary", "unknown output must never retain previous highlight")
end
widget.output("DP-2")
widget.orientation(false)
widget.expectSelection("DP-1", 3)
widget.env.update()
assert(widget.frameContexts[#widget.frameContexts].output == "DP-2"
  and widget.trees[#widget.trees].type == "row",
  "latest pending output/orientation must replace the nil context")
widget.expectSelection("DP-2", 4)
success(widget, 3, renamed, movedMonitors, activeWindow(identity("named:alpha", "normal", "Renamed"), 2), docs)
tree = widget.trees[#widget.trees]
ordered = expectList(tree, { "2", "9", "New", "Renamed", "Shared" })
assert(tree.type == "row" and selected(ordered[4]),
  "callback must use most recent pending host context and focused selection")
assert(ordered[4].props.key == initialAlphaKey, "move and display rename must preserve canonical key")
assert(ordered[5].props.key == initialBetaKey, "insertion before an item must not retarget its key")
assert(selected(ordered[4]), "renamed workspace remains selected by its stable address")
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
assert(labelOf(numericButton) == "3", "numbered workspace label must use its numeric ID")
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
  assert(labelOf(namedButtons[index]) == "Friendly Label", "ID-less entries retain their complete display names")
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
assert(labelOf(specialButtons[1]) == "Regular" and labelOf(specialButtons[2]) == "special:scratch", "ID-less controls retain display names and canonical address order")
assert(selected(specialButtons[2]) and not selected(specialButtons[1]), "focused special window selects only its special workspace")
expectDispatch(focusedSpecial, specialButtons[2], "special", "scratch", "special selector uses canonical address suffix")

local regularOverlayDocs = {}
local regularOverlay = instance("DP-1", false, regularOverlayDocs)
regularOverlay.env.update()
success(regularOverlay, 1, overlayRows, specialMonitor,
  activeWindow(activeNormal, 1), regularOverlayDocs)
local regularOverlayButtons = buttons(regularOverlay.trees[#regularOverlay.trees])
assert(selected(regularOverlayButtons[1]) and not selected(regularOverlayButtons[2]), "focused regular window remains selected during a special overlay")

local noWindowDocs = {}
local noWindow = instance("DP-1", false, noWindowDocs)
noWindow.env.update()
success(noWindow, 1, overlayRows, specialMonitor, {}, noWindowDocs)
for _, button in ipairs(buttons(noWindow.trees[#noWindow.trees])) do
  assert(not selected(button), "special overlay with no active window selects nothing")
  assert(button.props.minWidth == 16, "special overlay without a focused window keeps pills inactive-sized")
end

local emptyNormalDocs = {}
local emptyNormal = instance("DP-1", false, emptyNormalDocs)
emptyNormal.env.update()
success(emptyNormal, 1, { normal }, {
  monitor("DP-1", 1, true, activeNormal),
}, {}, emptyNormalDocs)
assert(selected(buttons(emptyNormal.trees[#emptyNormal.trees])[1]),
  "normal focused active workspace stays selected when it has no windows")

local remoteDocs = {}
local remoteBar = instance("DP-2", false, remoteDocs)
remoteBar.env.update()
success(remoteBar, 1, overlayRows, specialMonitor,
  activeWindow(identity("special:scratch", "special", "special:scratch"), 1), remoteDocs)
for _, button in ipairs(buttons(remoteBar.trees[#remoteBar.trees])) do
  assert(not selected(button), "focused special workspace must not select on another output's bar")
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
assert(labelOf(collisionButtons[1]) == "Regular alias" and labelOf(collisionButtons[2]) == collisionAddress,
  "type tie-break must be deterministic for equal ID-less addresses")
assert(collisionButtons[1].props.key ~= collisionButtons[2].props.key,
  "normal and special address collision needs distinct props.key values")
assert(selected(collisionButtons[1]) and not selected(collisionButtons[2]),
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
assert(not selected(specialFocusButtons[1]) and selected(specialFocusButtons[2]),
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
  for _, button in ipairs(items) do assert(not selected(button), label .. " must select none") end
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
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "c" .. RS .. "extra" }, { w = {}, m = {}, a = {}, c = {} }, "extra RS")
rejected({ exitCode = 0, stdout = RS .. "m" .. RS .. "a" .. RS .. "c" }, { w = {}, m = {}, a = {}, c = {} }, "empty first document")
rejected({ exitCode = 0, stdout = "w" .. RS .. RS .. "a" .. RS .. "c" }, { w = {}, m = {}, a = {}, c = {} }, "empty middle document")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS }, { w = {}, m = {}, a = {}, c = {} }, "empty last document")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "c" }, { w = false, m = {}, a = {}, c = {} }, "decode type error")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "c" }, { w = {}, m = { name = true }, a = {}, c = {} }, "monitor document not array")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "c" }, { w = { foo = true }, m = {}, a = {}, c = {} }, "workspace document not array")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "c" }, { w = {
  workspace("named:a", "normal", "Same", "DP-1", 1), workspace("named:a", "normal", "Other", "DP-1", 1),
}, m = {}, a = {}, c = {} }, "duplicate canonical address")
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
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "c" }, { w = {
  { address = "named:a", type = "normal", name = "A", monitor = "DP-1", monitorID = "1" },
}, m = {}, a = {}, c = {} }, "monitorID must match source JSON integer type")
rejected({ exitCode = 0, stdout = "w" .. RS .. "m" .. RS .. "a" .. RS .. "c" }, { w = {}, m = {}, a = { workspace = "wrong type" }, c = {} }, "active window identity type error")

-- Sync launch exceptions clear the guard, remove stale clickability, and recover.
local recoveryDocs = {}
local recovery = instance("DP-1", true, recoveryDocs)
recovery.env.update()
success(recovery, 1, { workspace("1", "normal", "One", "DP-1", 1, 1) }, {
  monitor("DP-1", 1, true, identity("1", "normal", "One", 1)),
}, activeWindow(identity("1", "normal", "One", 1), 1), recoveryDocs)
local oldButton = buttons(recovery.trees[#recovery.trees])[1]
recovery.throwNextLaunch()
recovery.env.update()
local failedTree = recovery.trees[#recovery.trees]
local failedControls = buttons(failedTree)
assert(failedTree.type == "column" and #failedControls == 1 and failedControls[1].props.enabled == false,
  "synchronous launch failure clears prior snapshot and preserves cached orientation")
assert(not recovery.frameContexts[#recovery.frameContexts].asyncCallback
  and recovery.frameContexts[#recovery.frameContexts].output == "DP-1",
  "synchronous launch exceptions must leave contextual update state intact")
assert(click(recovery, oldButton) == nil, "stale callback after synchronous failure must not dispatch")
recovery.env.update()
assert(#recovery.requests == 2, "request guard must recover after a synchronous launch exception")
success(recovery, 2, { workspace("1", "normal", "One", "DP-1", 1, 1) }, {
  monitor("DP-1", 1, true, identity("1", "normal", "One", 1)),
}, activeWindow(identity("1", "normal", "One", 1), 1), recoveryDocs)
assert(selected(buttons(recovery.trees[#recovery.trees])[1]), "recovered snapshot must be usable")

-- A completed async failure also clears old state and allows the next poll.
recovery.env.update()
local staleAfterFailure = buttons(recovery.trees[#recovery.trees])[1]
complete(recovery, 3, { exitCode = 1, stdout = "" })
assert(click(recovery, staleAfterFailure) == nil, "stale callback after asynchronous failure must not dispatch")
assert(recovery.trees[#recovery.trees].type == "column", "async failure callback must preserve cached orientation")
recovery.env.update()
success(recovery, 4, { workspace("1", "normal", "One", "DP-1", 1, 1) }, {
  monitor("DP-1", 1, true, identity("1", "normal", "One", 1)),
}, activeWindow(identity("1", "normal", "One", 1), 1), recoveryDocs)

-- Failed/missing stream starts retry on later updates, successful starts stay unique.
local retryDocs = {}
local retry = instance("DP-1", false, retryDocs, { streamOutcomes = { false, "throw", true } })
assert(#retry.streamAttempts == 1 and #retry.streams == 0 and #retry.requests == 1,
  "false runStream startup must not block the immediate initial snapshot")
success(retry, 1, numericRows, numericMonitor, activeWindow(identity("3", "normal", "Three", 3), 1), retryDocs)
retry.env.update()
assert(#retry.streamAttempts == 2 and #retry.streams == 0 and #retry.requests == 2,
  "thrown stream startup must be caught and retried on contextual update")
success(retry, 2, numericRows, numericMonitor, activeWindow(identity("3", "normal", "Three", 3), 1), retryDocs)
retry.env.update()
assert(#retry.streamAttempts == 3 and #retry.streams == 1 and #retry.requests == 3,
  "successful stream startup after retries must register exactly one listener")
assert(retry.streams[1].command == retry.streamAttempts[1].command,
  "listener reconnect command remains stable across start retries")
success(retry, 3, numericRows, numericMonitor, activeWindow(identity("3", "normal", "Three", 3), 1), retryDocs)
retry.env.update()
assert(#retry.streamAttempts == 3 and #retry.requests == 4,
  "later fallback update must reuse the started listener")
success(retry, 4, numericRows, numericMonitor, activeWindow(identity("3", "normal", "Three", 3), 1), retryDocs)

local missingEnvironmentDocs = {}
local missingEnvironment = instance("DP-1", false, missingEnvironmentDocs, { environment = {} })
assert(#missingEnvironment.streamAttempts == 0 and #missingEnvironment.requests == 1,
  "missing socket environment must skip stream startup and retain immediate snapshot")
success(missingEnvironment, 1, numericRows, numericMonitor,
  activeWindow(identity("3", "normal", "Three", 3), 1), missingEnvironmentDocs)
missingEnvironment.env.update()
assert(#missingEnvironment.streamAttempts == 0 and #missingEnvironment.requests == 2,
  "missing socket environment must retain periodic snapshot fallback")
success(missingEnvironment, 2, numericRows, numericMonitor,
  activeWindow(identity("3", "normal", "Three", 3), 1), missingEnvironmentDocs)

print("Noctalia global workspaces regression tests passed")
