-- Google Meet global controls (Chrome)
--
-- Drives Meet's on-screen buttons via injected JS, so there is NO focus change
-- and no window flicker. Works from any app, including from a desk macropad.
-- Loaded from init.lua via require("meet").bind().
--
-- Requires (one-time; see dotfiles scripts/macos-defaults.sh + README):
--   1. Hammerspoon: Accessibility permission (prompted on first hotkey).
--   2. Chrome: "Allow JavaScript from Apple Events"
--        View > Developer > Allow JavaScript from Apple Events, or
--        defaults write com.google.Chrome AllowJavaScriptAppleEvents -bool true
--   3. Automation permission for Hammerspoon -> Google Chrome (prompted once).

local M = {}

local MEET = "meet.google.com"

-- Run JS inside the first Chrome tab whose URL is a Meet call.
-- Returns the JS result string, "notab" if no Meet tab, or nil on failure.
-- NOTE: js must use single quotes only (it is embedded in a double-quoted
-- AppleScript string).
local function meetJS(js)
  local script = [[
    tell application "Google Chrome"
      repeat with w in windows
        repeat with t in tabs of w
          if URL of t contains "]] .. MEET .. [[" then
            return execute t javascript "]] .. js .. [["
          end if
        end repeat
      end repeat
      return "notab"
    end tell
  ]]
  local ok, result = hs.osascript.applescript(script)
  if not ok then return nil end
  return result
end

-- Click a mic/camera control (both carry data-is-muted) matched by aria-label
-- word, reporting the state we transition TO (derived from the pre-click state,
-- so the toast is correct regardless of when Meet updates the attribute).
-- data-is-muted="true" means mic muted / camera off.
local function toggleControl(labelWord)
  local js = "(function(){"
    .. "var b=document.querySelector('[data-is-muted][aria-label*=" .. labelWord .. " i]');"
    .. "if(!b)return 'noctrl';"
    .. "var off=b.getAttribute('data-is-muted')==='true';"
    .. "b.click();"
    .. "return off?'on':'off';"
    .. "})()"
  return meetJS(js)
end

local function alertControl(res, onMsg, offMsg)
  if res == "on" then hs.alert.show(onMsg)
  elseif res == "off" then hs.alert.show(offMsg)
  else hs.alert.show("No Google Meet call found") end
end

function M.toggleMic()
  alertControl(toggleControl("microphone"), "🎤 Unmuted", "🔇 Muted")
end

function M.toggleCamera()
  alertControl(toggleControl("camera"), "📹 Camera on", "📹 Camera off")
end

-- Raise/lower hand. Not a data-is-muted control, so match by aria-label
-- ("Raise hand" / "Lower hand") and read the label to know the direction.
function M.toggleHand()
  local js = "(function(){"
    .. "var b=document.querySelector('[aria-label*=hand i]');"
    .. "if(!b)return 'noctrl';"
    .. "var down=/raise/i.test(b.getAttribute('aria-label'));"
    .. "b.click();"
    .. "return down?'up':'down';"
    .. "})()"
  local res = meetJS(js)
  if res == "up" then hs.alert.show("✋ Hand raised")
  elseif res == "down" then hs.alert.show("🙌 Hand lowered")
  else hs.alert.show("No Google Meet call found") end
end

-- Copy the Meet call link to the clipboard (no focus change). The tab URL in a
-- call is the invite link; strip any query string to a clean meet.google.com/x.
function M.copyLink()
  local script = [[
    tell application "Google Chrome"
      repeat with w in windows
        repeat with t in tabs of w
          if URL of t contains "]] .. MEET .. [[" then
            return URL of t
          end if
        end repeat
      end repeat
      return "notab"
    end tell
  ]]
  local ok, url = hs.osascript.applescript(script)
  if not ok or url == nil or url == "notab" then
    hs.alert.show("No Google Meet call found")
    return
  end
  url = url:match("^(https://meet%.google%.com/[a-z%-]+)") or url
  hs.pasteboard.setContents(url)
  hs.alert.show("🔗 Meet link copied")
end

-- Current mic state, for external readers such as the menu-bar indicator.
-- Returns "muted", "live", or nil when there is no active call / control.
function M.micState()
  local js = "(function(){"
    .. "var b=document.querySelector('[data-is-muted][aria-label*=microphone i]');"
    .. "return b?b.getAttribute('data-is-muted'):'none';"
    .. "})()"
  local res = meetJS(js)
  if res == "true" then return "muted"
  elseif res == "false" then return "live" end
  return nil
end

-- Bind all Meet hotkeys. mods defaults to Option+Ctrl+Shift (vim M-C-S; on
-- macOS vim "M"/Meta = Option). Pass your own set if your macropad differs.
function M.bind(mods)
  mods = mods or { "alt", "ctrl", "shift" }
  hs.hotkey.bind(mods, "f6", M.toggleMic)     -- Toggle mute/unmute  (M-C-S-F6)
  hs.hotkey.bind(mods, "f1", M.toggleCamera)  -- Toggle video on/off (M-C-S-F1)
  hs.hotkey.bind(mods, "f4", M.copyLink)      -- Copy share link     (M-C-S-F4)
  hs.hotkey.bind(mods, "f8", M.toggleHand)    -- Raise/lower hand    (M-C-S-F8)

  -- NOT bound, by design:
  --   Share / present (wanted on F2): starting a screen share goes through
  --     Chrome's native screen-picker, which requires a trusted user gesture a
  --     synthetic JS click cannot provide. Cannot be a no-focus global hotkey.
  --   Pause share (wanted on F7): Meet has no pause-sharing feature; only
  --     start/stop exists, so there is nothing to bind.
end

return M
