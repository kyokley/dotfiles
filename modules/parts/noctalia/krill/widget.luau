-- Krill bar widget: shows a headline, updated via IPC pushes.
--
--   noctalia msg plugin yokley/krill:krill all set "<headline>"
--
-- The top level runs once when the plugin loads.

local MAX_LENGTH = 50

-- Right-side truncation that never splits a UTF-8 sequence.
-- Matches the old qtile Krill widget (100 chars + "...").
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
  end
end
