-- Krill bar widget: shows a headline, updated via IPC pushes.
-- Left-click opens the current headline's link; scrolling up/down moves
-- through previous headlines in history; right-click toggles the headline
-- text (the news glyph always stays visible).
--
--   noctalia msg plugin yokley/krill:krill all set "<headline>|<url>"
--
-- The IPC runtime delivers a single string payload, so the url travels in
-- the same payload, separated from the headline by "|" (see splitPayload).
-- The top level runs once when the plugin loads.

local MAX_LENGTH = 50
local MAX_HISTORY = 100

local history = {} -- array of { title = string, link = string }, newest first
local index = 1 -- currently displayed item (1 = newest)
local textVisible = true -- right-click toggles; the glyph always stays

-- Right-side truncation that never splits a UTF-8 sequence.
local function truncate(text)
  if string.len(text) <= MAX_LENGTH then
    return text
  end
  return string.sub(text, 1, MAX_LENGTH) .. "..."
end

-- Render the currently selected item. When text is toggled off, only the
-- glyph shows; the tooltip still carries the full headline so it stays
-- reachable on hover.
local function display(item)
  if textVisible then
    barWidget.setText(truncate(item.title))
  else
    barWidget.setText("")
  end
  barWidget.setTooltip(item.title) -- full headline on hover
end

-- Right-click flips the headline text on/off. The glyph set at load time is
-- never touched, so it stays visible in either state.
local function toggleText()
  textVisible = not textVisible
  if #history > 0 then
    display(history[index])
  else
    barWidget.setText(textVisible and "Loading..." or "")
  end
end

-- A single IPC "set" payload carries both fields as "<headline>|<url>".
-- The headline itself may contain "|", so it is split at the LAST separator;
-- an empty url keeps the item linkless. Payloads without a separator are
-- treated as a bare headline (legacy single-field pushes).
local function splitPayload(payload)
  local title, url = payload:match("^(.*)|(.*)$")
  if title == nil then
    return payload, nil
  end
  if url == "" then
    url = nil
  end
  return title, url
end

-- Prepend the newest item, dropping the oldest once history is full.
-- An item already in history (same title + link) is not inserted again;
-- it stays in place but is shown as the current headline.
local function push(payload, link)
  local title, url = splitPayload(payload)
  if link ~= nil and link ~= "" then
    url = link -- an explicit link argument wins if the runtime ever grows one
  end
  local item = { title = title }
  if url ~= nil and url ~= "" then
    item.link = url
  end
  for _, existing in ipairs(history) do
    if existing.title == item.title and existing.link == item.link then
      index = 1
      display(existing)
      return
    end
  end
  table.insert(history, 1, item)
  if #history > MAX_HISTORY then
    table.remove(history) -- drops the last (oldest) entry
  end
  index = 1
  display(item)
end

barWidget.setText("Loading...")
barWidget.setGlyph("news") -- swap for a news glyph from the icon set

function onIpc(event, payload, link)
  if event == "set" then
    push(payload, link)
  elseif event == "link" then
    -- legacy event: attach the link to the newest item
    if #history > 0 and link ~= nil and link ~= "" then
      history[1].link = link
    end
  end
end

function onScroll(axis, steps, startsGesture)
  if #history == 0 or axis ~= "vertical" or not startsGesture then
    return
  end
  -- a wheel burst counts as one move; scroll down = older items,
  -- scroll up = back toward the newest; either end wraps around
  local count = #history
  index = (index + (steps > 0 and 1 or -1) - 1 + count) % count + 1
  display(history[index])
end

function onRightClick()
  toggleText()
end

function onClick()
  if #history == 0 then
    return
  end
  local item = history[index] -- the headline currently displayed
  -- open the link for the headline currently displayed
  if item.link ~= nil and item.link ~= "" then
    -- single-quote escape so the URL survives /bin/sh -c safely
    local url = "'" .. string.gsub(item.link, "'", "'\\''") .. "'"
    noctalia.runAsync("xdg-open " .. url)
  end
end
