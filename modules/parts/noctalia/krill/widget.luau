-- Krill bar widget: shows a headline, updated via IPC pushes.
-- Left-click opens the current headline's link; scrolling up/down moves
-- through previous headlines in history.
--
--   noctalia msg plugin yokley/krill:krill all set "<headline>" "<url>"
--
-- The top level runs once when the plugin loads.

local MAX_LENGTH = 50
local MAX_HISTORY = 100

local history = {} -- array of { title = string, link = string }, newest first
local index = 1 -- currently displayed item (1 = newest)

-- Right-side truncation that never splits a UTF-8 sequence.
local function truncate(text)
  if string.len(text) <= MAX_LENGTH then
    return text
  end
  return string.sub(text, 1, MAX_LENGTH) .. "..."
end

local function display(item)
  barWidget.setText(truncate(item.title))
  barWidget.setTooltip(item.title) -- full headline on hover
end

-- Prepend the newest item, dropping the oldest once history is full.
local function push(title, link)
  local item = { title = title }
  if link ~= nil and link ~= "" then
    item.link = link
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
  -- scroll up = back toward the newest
  index = math.clamp(index + (steps > 0 and 1 or -1), 1, #history)
  display(history[index])
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
