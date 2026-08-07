-- Krill bar widget: shows a headline, updated via IPC pushes.
--
--   noctalia msg plugin yokley/krill:krill all set "<headline>"
--
-- The top level runs once when the plugin loads.

barWidget.setText("Loading...")
barWidget.setGlyph("puzzle") -- swap for a news glyph from the icon set

function onIpc(event, payload)
  if event == "set" then
    barWidget.setText(payload)
    barWidget.setTooltip(payload)
  end
end
