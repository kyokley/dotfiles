-- Krill bar widget: shows a headline, updated via IPC pushes.
-- Left-click opens the item's link.
--
--   noctalia msg plugin yokley/krill:krill all set "<headline>"
--   noctalia msg plugin yokley/krill:krill all link "<url>"
--
-- The top level runs once when the plugin loads.

local MAX_LENGTH = 50
local currentLink = ""

-- Right-side truncation that never splits a UTF-8 sequence.
local function truncate(text)
  if string.len(text) <= MAX_LENGTH then
    return text
  end
  return string.sub(text, 1, MAX_LENGTH) .. "..."
end

barWidget.setText("Loading...")
barWidget.setGlyph("news") -- swap for a news glyph from the icon set

function onIpc(event, payload)
  if event == "set" then
    barWidget.setText(truncate(payload))
    barWidget.setTooltip(payload) -- full headline on hover
  elseif event == "link" then
    currentLink = payload
  end
end

function onClick()
  if currentLink ~= "" then
    -- single-quote escape so the URL survives /bin/sh -c safely
    local url = "'" .. string.gsub(currentLink, "'", "'\\''") .. "'"
    noctalia.runAsync("xdg-open " .. url)
  end
end
