-- Krill bar widget: shows a headline, updated via IPC pushes.
-- Left-click opens the current headline's link; scrolling up/down moves
-- through previous headlines in history; right-click toggles the headline
-- text (the news glyph always stays visible).
--
--   noctalia msg plugin yokley/krill:krill all set "<headline>\x1F<url>"
--
-- The IPC runtime delivers a single string payload, so the url travels in
-- the same payload, separated from the headline by the ASCII unit separator
-- (0x1F, see splitPayload).  This avoids collisions with pipes that may
-- appear in URLs or encoded text.

local MAX_LENGTH = 50
local MAX_HISTORY = 100
local SEP = "\x1F" -- ASCII unit separator — never appears in headlines or URLs

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
-- reachable on hover.  Items without a link get a subtle trailing marker
-- so the user knows clicking won't navigate anywhere.
local function display(item)
  if not textVisible then
    barWidget.setText("")
  else
    local shown = truncate(item.title)
    if item.link == nil then
      shown = shown .. " \u{2013}" -- en-dash = "no link" marker
    end
    barWidget.setText(shown)
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

-- Normalize a URL for deduplication: strip trailing slashes, fragment
-- identifiers, and sort query-string params so that the same story served
-- from slightly different URLs still collapses into one history entry.
local function normalizeUrl(url)
  if url == nil or url == "" then
    return nil
  end
  local normalized = url
    :gsub("#.*$", "")   -- drop fragment
    :gsub("/+$", "")    -- strip trailing slashes
    :gsub("%?.*$", "")  -- strip query string entirely for dedup
  return normalized == "" and url or normalized
end

-- A single IPC "set" payload carries both fields separated by the unit
-- separator: "<headline>\x1F<url>".  An empty url keeps the item linkless.
-- Payloads without the separator are treated as a bare headline.
local function splitPayload(payload)
  local title, url = payload:match("^(.*)" .. SEP .. "(.*)$")
  if title == nil then
    return payload, nil
  end
  if url == "" then
    url = nil
  end
  return title, url
end

-- Prepend the newest item, dropping the oldest once history is full.
-- An item already in history (same title + normalized link) is not inserted
-- again; it stays in place but is shown as the current headline.
local function push(payload)
  local title, url = splitPayload(payload)
  local norm = normalizeUrl(url)
  local item = { title = title }
  if url ~= nil and url ~= "" then
    item.link = url
  end
  for _, existing in ipairs(history) do
    local eNorm = normalizeUrl(existing.link)
    if existing.title == item.title and eNorm == norm then
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

function onIpc(event, payload)
  if event == "set" then
    push(payload)
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
  local item = history[index]
  if item.link ~= nil and item.link ~= "" then
    -- single-quote escape so the URL survives /bin/sh -c safely
    local url = "'" .. string.gsub(item.link, "'", "'\\''") .. "'"
    noctalia.runAsync("xdg-open " .. url)
  end
end
