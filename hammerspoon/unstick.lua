-- Rescue a stuck drag.
--
-- macOS sometimes loses the mouse-up that ends a drag. The cursor keeps wearing
-- the drag image, the window the drag started from won't close, clicks land
-- nowhere, no new Finder window will open, and anything watching modifiers
-- (cmux flashes its split preview on every Shift) behaves as though a drag is
-- still in flight. Escape does nothing, and neither does clicking, Cmd+Tab,
-- `killall Finder`, or `killall Dock` -- the session lives in WindowServer, not
-- in the app. Short of logging out, the only fix is to synthesize the mouse-up
-- the system never delivered. Loaded from init.lua via require("unstick").bind().
--
-- The release is posted over the menu bar rather than wherever the cursor is
-- sitting, because a real drop target would accept the payload and genuinely
-- move the folder. The menu bar refuses drops, so the drag ends having relocated
-- nothing. The cursor goes back where it was afterwards.
--
-- Always the PRIMARY screen's menu bar: with "Displays have separate Spaces"
-- off, the other displays have no menu bar, and the top few pixels there are
-- desktop -- which is a drop target, and would file the folder onto the Desktop.

local M = {}

-- Three pixels down is inside the menu bar on the primary screen, whose frame
-- origin is (0, 0) by definition; centred horizontally so the release is clear
-- of the Apple menu and the status items on either end.
local function menuBarPoint()
  local f = hs.screen.primaryScreen():fullFrame()
  return hs.geometry.point(f.x + f.w / 2, f.y + 3)
end

-- End the drag. Exposed on M so it can also be driven from a terminal
-- (`hs -c 'require("unstick").release()'`), which matters because a captured
-- drag may swallow the hotkey before Hammerspoon ever sees it.
function M.release()
  local origin = hs.mouse.absolutePosition()
  local safe = menuBarPoint()

  hs.mouse.absolutePosition(safe)
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, safe):post()

  -- Give the drag session a moment to unwind before moving the cursor back,
  -- so the release is processed at the menu bar and not mid-flight.
  hs.timer.doAfter(0.3, function() hs.mouse.absolutePosition(origin) end)

  hs.alert.show("🖱 drag released")
end

function M.bind(mods)
  mods = mods or { "alt", "ctrl", "shift" }
  hs.hotkey.bind(mods, "f5", M.release) -- Release a stuck drag (M-C-S-F5)
end

return M
