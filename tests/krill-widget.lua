-- Run from the repository root: lua tests/krill-widget.lua (Lua 5.4).
local text, tooltip, command
barWidget = {
  setText = function(value) text = value end,
  setTooltip = function(value) tooltip = value end,
  setGlyph = function() end,
}
noctalia = {
  runAsync = function(value) command = value end,
}

dofile("modules/parts/noctalia/krill/widget.luau")

local function push(title, url)
  onIpc("set", title .. "\x1F" .. url)
end

local function expect(title, url)
  assert(text == title, "unexpected displayed title: " .. tostring(text))
  assert(tooltip == title, "unexpected tooltip: " .. tostring(tooltip))
  command = nil
  onClick()
  local expected = url and ("xdg-open '" .. url .. "'") or nil
  assert(command == expected, "title/URL mismatch: " .. tostring(command))
end

push("Older", "https://example.com/older")
push("Newer", "https://example.com/newer")
expect("Newer", "https://example.com/newer")

-- A repeated older item must select its history entry, not the newest one.
push("Older", "https://example.com/older")
expect("Older", "https://example.com/older")
onRightClick()
assert(text == "")
assert(tooltip == "Older")
command = nil
onClick()
assert(command == "xdg-open 'https://example.com/older'")
onRightClick()
expect("Older", "https://example.com/older")

-- History stays in place without duplicates; scrolling wraps from that item.
onScroll("vertical", 1, true)
expect("Newer", "https://example.com/newer")
onScroll("vertical", 1, true)
expect("Older", "https://example.com/older")
onScroll("vertical", -1, true)
expect("Newer", "https://example.com/newer")

-- Fresh pushes select the newest item; repeated linkless items stay linkless.
onIpc("set", "No link")
push("Latest", "https://example.com/latest")
expect("Latest", "https://example.com/latest")
onIpc("set", "No link")
assert(text == "No link \u{2013}")
assert(tooltip == "No link")
command = nil
onClick()
assert(command == nil, "linkless item opened another headline's URL")

print("Krill widget regression tests passed")
