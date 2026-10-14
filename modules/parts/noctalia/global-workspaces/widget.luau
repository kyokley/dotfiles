-- Compact, global Hyprland workspace buttons. Publish only complete snapshots.

local SEP = "\030" -- ASCII record separator between complete JSON documents
local POLL_MS = 1000
local LABEL_FONT_SIZE = 11 -- Noctalia Style::fontSizeMini
local PILL_SIZE = 16 -- Noctalia Style::baseGlyphSize, logical pixels
local ACTIVE_PILL_SIZE = 2.0 -- modules/parts/noctalia/noctalia.nix widget.workspaces.active_pill_size
local INACTIVE_PILL_SIZE = 1.0
local PILL_PADDING = PILL_SIZE * 0.3 -- native regular style adds 0.6 * pill height total
local PILL_RADIUS = 8 -- inherited bar capsule_radius, logical pixels
local WORKSPACE_GAP = 4 -- Noctalia Style::spaceXs, logical pixels
local inFlight = false
local workspaces = nil
local focusedIdentity = nil
local focusedMonitor = nil
local cachedOutputName = nil
local cachedIsVertical = false
local hoveredIdentity = nil

local function cacheBarContext()
  cachedOutputName = barWidget.outputName()
  cachedIsVertical = barWidget.isVertical()
end

local function shellQuote(value)
  return "'" .. string.gsub(value, "'", "'\\''") .. "'"
end

local function luaStringLiteral(value)
  return '"' .. string.gsub(value, '[\\"]', function(character)
    return "\\" .. character
  end) .. '"'
end

local function workspaceIdentity(workspace)
  return workspace.type .. ":" .. #workspace.address .. ":" .. workspace.address
end

local function validText(value)
  return type(value) == "string" and value ~= "" and not value:find("[%z\1-\31\127]")
end

local function workspaceLabel(workspace)
  if workspace.id ~= nil then return string.format("%.0f", workspace.id) end
  return workspace.name
end

local function styleFor(workspace, selected, hovered)
  if hovered then return "hover", "on_hover" end
  local fill
  if selected then
    fill = "primary"
  elseif workspace.active then
    fill = "secondary"
  elseif workspace.urgent then
    fill = "error"
  elseif workspace.occupied then
    fill = "secondary"
  else
    fill = "surface_variant/0.55"
  end
  if workspace.urgent then return fill, "on_error" end
  if fill == "primary" then return fill, "on_primary" end
  if fill == "secondary" then return fill, "on_secondary" end
  return fill, "on_surface"
end

local function activationSelector(workspace)
  if workspace.special then
    local suffix = workspace.address == "special:special" and ""
      or workspace.address:sub(1, 8) == "special:" and workspace.address:sub(9)
      or workspace.address
    if not validText(suffix) and suffix ~= "" then return nil end
    return suffix, true
  end
  if workspace.id ~= nil then
    return string.format("%.0f", workspace.id)
  end
  return "name:" .. workspace.address, false
end

local function isCurrent(workspace)
  if workspaces == nil then return false end
  for _, current in ipairs(workspaces) do
    if workspaceIdentity(current) == workspaceIdentity(workspace)
      and current.monitor == workspace.monitor then
      return activationSelector(current) ~= nil
    end
  end
  return false
end

local function isArray(value)
  if type(value) ~= "table" then return false end
  local count, max = 0, 0
  for key in pairs(value) do
    if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then return false end
    count = count + 1
    if key > max then max = key end
  end
  return count == max
end

local function workspaceForIdentity(workspaces, identity)
  if type(identity) ~= "table" then return nil end
  local id = identity.id
  local address = identity.address
  local name = identity.name
  local kind = identity.type
  if id ~= nil and (type(id) ~= "number" or id % 1 ~= 0 or id <= 0) then return nil end
  if not validText(address) or not validText(name) then return nil end
  if kind ~= "normal" and kind ~= "special" then return nil end
  local found
  local wantedIdentity = workspaceIdentity(identity)
  for _, workspace in ipairs(workspaces) do
    if workspaceIdentity(workspace) == wantedIdentity and (id == nil or workspace.id == id) then
      if found ~= nil then return nil end
      found = workspace
    end
  end
  return found
end

local function sortWorkspaces(workspaces)
  table.sort(workspaces, function(a, b)
    if a.id ~= nil and b.id ~= nil then return a.id < b.id end
    if a.id ~= nil then return true end
    if b.id ~= nil then return false end
    if a.address ~= b.address then return a.address < b.address end
    return a.type < b.type
  end)
end

local function normalize(workspaceDoc, monitorDoc, windowDoc, clientsDoc)
  if not isArray(workspaceDoc) or not isArray(monitorDoc) or type(windowDoc) ~= "table"
    or not isArray(clientsDoc) then return nil end
  local result, ids, identities, monitors, monitorIds = {}, {}, {}, {}, {}
  for _, raw in ipairs(workspaceDoc) do
    if type(raw) ~= "table" or (raw.id ~= nil and (type(raw.id) ~= "number"
      or raw.id % 1 ~= 0 or raw.id <= 0 or raw.type ~= "normal"
      or string.format("%.0f", raw.id) ~= raw.address))
      or not validText(raw.address) or not validText(raw.name) or not validText(raw.monitor)
      or (raw.type ~= "normal" and raw.type ~= "special")
      or type(raw.monitorID) ~= "number" or raw.monitorID % 1 ~= 0 then
      return nil
    end
    if raw.id ~= nil then
      if ids[raw.id] then return nil end
      ids[raw.id] = true
    end
    local identityKey = workspaceIdentity(raw)
    if identities[identityKey] then return nil end
    identities[identityKey] = true
    result[#result + 1] = {
      id = raw.id,
      address = raw.address,
      type = raw.type,
      name = raw.name,
      monitor = raw.monitor,
      monitorID = raw.monitorID,
      special = raw.type == "special",
      active = false,
      occupied = false,
      urgent = false,
    }
  end
  local focused, ambiguousFocus
  for _, raw in ipairs(monitorDoc) do
    if type(raw) ~= "table" or not validText(raw.name) or type(raw.id) ~= "number"
      or raw.id % 1 ~= 0 or type(raw.focused) ~= "boolean"
      or type(raw.activeWorkspace) ~= "table"
      or raw.activeWorkspace.type ~= "normal"
      or type(raw.specialWorkspace) ~= "table" then
      return nil
    end
    if not validText(raw.activeWorkspace.address) or not validText(raw.activeWorkspace.name)
      or (raw.activeWorkspace.id ~= nil and (type(raw.activeWorkspace.id) ~= "number"
        or raw.activeWorkspace.id % 1 ~= 0 or raw.activeWorkspace.id == 0)) then return nil end
    if type(raw.specialWorkspace.address) ~= "string" or type(raw.specialWorkspace.type) ~= "string"
      or type(raw.specialWorkspace.name) ~= "string" then return nil end
    local inactiveSpecial = raw.specialWorkspace.address == "" and raw.specialWorkspace.type == ""
      and raw.specialWorkspace.name == ""
    if not inactiveSpecial and (raw.specialWorkspace.type ~= "special"
      or not validText(raw.specialWorkspace.address) or not validText(raw.specialWorkspace.name)) then return nil end
    if monitors[raw.name] then return nil end
    if monitorIds[raw.id] then return nil end
    monitors[raw.name] = true
    monitorIds[raw.id] = raw.name
    local active = workspaceForIdentity(result, raw.activeWorkspace)
    if active == nil or active.special or active.monitor ~= raw.name or active.monitorID ~= raw.id then return nil end
    active.active = true
    if not inactiveSpecial then
      local special = workspaceForIdentity(result, raw.specialWorkspace)
      if special == nil or not special.special or special.monitor ~= raw.name or special.monitorID ~= raw.id then return nil end
      special.active = true
    end
    if raw.focused then
      if focused ~= nil then
        ambiguousFocus = true
      else
        focused = { monitor = raw.name, monitorId = raw.id, active = raw.activeWorkspace,
          special = raw.specialWorkspace }
      end
    end
  end
  for _, raw in ipairs(clientsDoc) do
    if type(raw) ~= "table" then return nil end
    if raw.workspace ~= nil then
      local clientWorkspace = workspaceForIdentity(result, raw.workspace)
      if clientWorkspace ~= nil then
        if raw.urgent ~= nil and type(raw.urgent) ~= "boolean" then return nil end
        clientWorkspace.occupied = true
        clientWorkspace.urgent = clientWorkspace.urgent or raw.urgent == true
      elseif type(raw.workspace) ~= "table" or not validText(raw.workspace.address)
        or not validText(raw.workspace.name)
        or (raw.workspace.type ~= "normal" and raw.workspace.type ~= "special") then
        return nil
      end
    end
  end
  for _, workspace in ipairs(result) do
    if monitorIds[workspace.monitorID] ~= workspace.monitor then return nil end
  end
  if focused == nil or ambiguousFocus then
    sortWorkspaces(result)
    return result, nil
  end
  local active = workspaceForIdentity(result, focused.active)
  if active == nil or active.special or active.monitor ~= focused.monitor then return nil end
  local overlay = focused.special.address ~= ""
  local special
  if overlay then
    special = workspaceForIdentity(result, focused.special)
    if special == nil or not special.special or special.monitor ~= focused.monitor then return nil end
  end
  local selected = active
  if overlay then selected = nil end
  if next(windowDoc) ~= nil then
    local identity = windowDoc.workspace
    if type(identity) ~= "table" then return nil end
    local windowWorkspace = workspaceForIdentity(result, identity)
    if windowWorkspace == nil or windowWorkspace.monitor ~= focused.monitor
      or windowWorkspace.monitorID ~= focused.monitorId then return nil end
    if type(windowDoc.monitor) ~= "number" or windowDoc.monitor ~= focused.monitorId then
      return nil
    end
    if overlay then
      if workspaceIdentity(windowWorkspace) ~= workspaceIdentity(active)
        and workspaceIdentity(windowWorkspace) ~= workspaceIdentity(special) then return nil end
    elseif workspaceIdentity(windowWorkspace) ~= workspaceIdentity(active) then
      return nil
    end
    selected = windowWorkspace
  elseif type(windowDoc.workspace) ~= "nil" or type(windowDoc.monitor) ~= "nil" then
    return nil
  end
  sortWorkspaces(result)
  return result, { monitor = focused.monitor, selected = selected }
end

local function render()
  local children = {}
  if workspaces == nil then
    children[1] = { type = "button", props = { key = "unavailable",
      text = "—", enabled = false, variant = "ghost", tooltip = "No validated workspaces available",
    } }
  elseif #workspaces == 0 then
    children[1] = { type = "button", props = { key = "empty",
      text = "—", enabled = false, variant = "ghost", tooltip = "No workspaces available",
    } }
  else
    for _, workspace in ipairs(workspaces) do
      local selector, special = activationSelector(workspace)
      local label = workspaceLabel(workspace)
      local identity = workspaceIdentity(workspace)
      local selected = cachedOutputName ~= nil and focusedMonitor == cachedOutputName
        and focusedIdentity == identity
      local hovered = hoveredIdentity == identity
      local fill, textColor = styleFor(workspace, selected, hovered)
      local activePill = selected
      local tooltip = "Workspace " .. label .. " · " .. workspace.name
        .. " · " .. workspace.monitor
      if workspace.special then tooltip = tooltip .. " · toggles on focused monitor" end
      children[#children + 1] = {
        type = "row",
        props = {
          key = "workspace-entry-" .. identity,
          fill = fill,
          radius = PILL_RADIUS,
          minHeight = PILL_SIZE,
          justify = "center",
          align = "center",
          onClick = selector ~= nil and function()
            if not isCurrent(workspace) then return end
            local expression = special
              and ("hl.dsp.workspace.toggle_special(" .. luaStringLiteral(selector) .. ")")
              or ("hl.dsp.focus({workspace = " .. luaStringLiteral(selector) .. "})")
            noctalia.runAsync("hyprctl dispatch " .. shellQuote(expression))
          end or nil,
          onHover = function(state)
            if state == "true" then
              hoveredIdentity = identity
            elseif hoveredIdentity == identity then
              hoveredIdentity = nil
            end
            render()
          end,
          tooltip = tooltip,
        },
        children = {
          {
            type = "label",
            props = {
              key = "workspace-label-" .. identity,
              text = label,
              fontSize = LABEL_FONT_SIZE,
              color = textColor,
              maxLines = 1,
            },
          },
        },
      }
      if cachedIsVertical then
        local pillMainSize = PILL_SIZE * (activePill and ACTIVE_PILL_SIZE or INACTIVE_PILL_SIZE)
        children[#children].props.minWidth = PILL_SIZE
        children[#children].props.minHeight = pillMainSize
      else
        children[#children].props.minWidth = PILL_SIZE * (activePill and ACTIVE_PILL_SIZE or INACTIVE_PILL_SIZE)
        children[#children].props.paddingH = PILL_PADDING
      end
    end
  end
  barWidget.render({
    type = cachedIsVertical and "column" or "row",
    props = { key = "global-workspaces", gap = WORKSPACE_GAP, align = "center" },
    children = children,
  })
end

local function refresh()
  if inFlight then
    render()
    return
  end
  inFlight = true
  local command = "workspaces=$(timeout 2s hyprctl -j workspaces)"
    .. " && monitors=$(timeout 2s hyprctl -j monitors)"
    .. " && activewindow=$(timeout 2s hyprctl -j activewindow)"
    .. " && clients=$(timeout 2s hyprctl -j clients)"
    .. " && printf '%s\\036%s\\036%s\\036%s' \"$workspaces\" \"$monitors\" \"$activewindow\" \"$clients\""
  local started = pcall(noctalia.runAsync, command, function(result)
    inFlight = false
    local ok, nextSnapshot, nextFocus = pcall(function()
      if type(result) ~= "table" or result.exitCode ~= 0 or type(result.stdout) ~= "string" then
        return nil
      end
      local boundary = result.stdout:find(SEP, 1, true)
      if boundary == nil then return nil end
      local secondBoundary = result.stdout:find(SEP, boundary + 1, true)
      if secondBoundary == nil then return nil end
      local thirdBoundary = result.stdout:find(SEP, secondBoundary + 1, true)
      if thirdBoundary == nil or result.stdout:find(SEP, thirdBoundary + 1, true) ~= nil then return nil end
      local workspacesJson = result.stdout:sub(1, boundary - 1)
      local monitorsJson = result.stdout:sub(boundary + #SEP, secondBoundary - 1)
      local activewindowJson = result.stdout:sub(secondBoundary + #SEP, thirdBoundary - 1)
      local clientsJson = result.stdout:sub(thirdBoundary + #SEP)
      if workspacesJson == "" or monitorsJson == "" or activewindowJson == "" or clientsJson == "" then return nil end
      local workspaceDoc = noctalia.json.decode(workspacesJson)
      local monitorDoc = noctalia.json.decode(monitorsJson)
      local activewindowDoc = noctalia.json.decode(activewindowJson)
      local clientsDoc = noctalia.json.decode(clientsJson)
      return normalize(workspaceDoc, monitorDoc, activewindowDoc, clientsDoc)
    end)
    workspaces = ok and nextSnapshot or nil
    focusedIdentity = nil
    focusedMonitor = nil
    if ok and nextSnapshot ~= nil then
      workspaces = nextSnapshot
      if type(nextFocus) == "table" and nextFocus.selected ~= nil then
        focusedMonitor = nextFocus.monitor
        focusedIdentity = workspaceIdentity(nextFocus.selected)
      end
    end
    render()
  end)
  if not started then
    inFlight = false
    workspaces = nil
    focusedIdentity = nil
    focusedMonitor = nil
  end
  render() -- hosting output/orientation are read at render time, including pending polls
end

function update()
  cacheBarContext()
  refresh()
end

cacheBarContext()
noctalia.setUpdateInterval(POLL_MS)
render()
