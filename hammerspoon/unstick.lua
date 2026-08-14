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
-- The stuck button is not always the left one -- a middle-button drag can hang
-- exactly the same way, and posting a leftMouseUp then does nothing at all,
-- which reads as "the hotkey is broken". So poll which buttons the system
-- currently believes are held and release every one of them.
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
-- origin is (0, 0) by definition; centered horizontally so the release is clear
-- of the Apple menu and the status items on either end.
local function menuBarPoint()
  local f = hs.screen.primaryScreen():fullFrame()
  return hs.geometry.point(f.x + f.w / 2, f.y + 3)
end

-- hs.eventtap.checkMouseButtons() numbers buttons from 1 (left, right, middle,
-- then whatever else the mouse has). CGEvent counts the same buttons from 0,
-- and only the first two get a named event type -- every other button rides on
-- otherMouseUp and is told apart solely by its button number.
local UP_EVENT_TYPE = {
  hs.eventtap.event.types.leftMouseUp,
  hs.eventtap.event.types.rightMouseUp,
}
local BUTTON_NAME = { "left", "right", "middle" }

local function releaseButton(index, point)
  local e = hs.eventtap.event.newMouseEvent(
    UP_EVENT_TYPE[index] or hs.eventtap.event.types.otherMouseUp, point)
  e:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, index - 1)
  e:post()
  return BUTTON_NAME[index] or ("button " .. index)
end

local function heldButtons()
  local held = {}
  for index, pressed in ipairs(hs.eventtap.checkMouseButtons()) do
    if pressed then held[#held + 1] = index end
  end
  -- A drag can also hang with nothing polling as held, when WindowServer alone
  -- is the one still tracking the session. Left is the overwhelming case there.
  if #held == 0 then held = { 1 } end
  return held
end

-- End the drag. Exposed on M so it can also be driven from a terminal
-- (`hs -c 'require("unstick").release()'`), which matters because a captured
-- drag may swallow the hotkey before Hammerspoon ever sees it.
function M.release()
  local origin = hs.mouse.absolutePosition()
  local safe = menuBarPoint()

  hs.mouse.absolutePosition(safe)
  local released = {}
  for _, index in ipairs(heldButtons()) do
    released[#released + 1] = releaseButton(index, safe)
  end

  -- Give the drag session a moment to unwind before moving the cursor back,
  -- so the release is processed at the menu bar and not mid-flight.
  hs.timer.doAfter(0.3, function() hs.mouse.absolutePosition(origin) end)

  hs.alert.show("🖱 drag released: " .. table.concat(released, ", "))
end

function M.bind(mods)
  mods = mods or { "alt", "ctrl", "shift" }
  hs.hotkey.bind(mods, "f5", M.release) -- Release a stuck drag (M-C-S-F5)
end

return M
