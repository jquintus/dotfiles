#!/bin/bash
#
# macOS system defaults.
#
# Standalone from install-mac.sh (which only symlinks dotfiles): this script
# mutates system state via `defaults write`, so it is run explicitly, not as
# part of linking. Safe to re-run; each setting is idempotent.
#
#     ./scripts/macos-defaults.sh
#
# Some changes require logging out / restarting affected apps to take effect.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status()  { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS. Current OS: $OSTYPE"
    exit 1
fi

print_status "Applying macOS defaults..."

########################################
# Keyboard
########################################
# Disable press-and-hold accent menu so holding a key repeats it instead.
print_status "Disabling press-and-hold (enables key repeat)"
defaults write -g ApplePressAndHoldEnabled -bool false

# Disable double-space -> period (Keyboard > Text Input > "Add period with double-space").
print_status "Disabling double-space period substitution"
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable the F11 "Show Desktop" shortcut that scatters all windows aside.
# It's a macOS default (not stored in the user plist until overridden), so we
# add explicit disabled entries. IDs 36 and 37 are the two Show Desktop hotkeys.
print_status "Disabling F11 Show Desktop shortcut"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 '{ enabled = 0; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 37 '{ enabled = 0; }'
# Apply the hotkey change without requiring a logout.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

########################################
# Dock
########################################
# Move the Dock to the left edge (Desktop & Dock > "Position on screen").
# Vertical space is the scarce resource, and the bottom edge is the one the
# pointer hits by accident, which is what makes the Dock hop between displays.
print_status "Moving the Dock to the left edge"
defaults write com.apple.dock orientation -string left

# Auto-hide the Dock (Desktop & Dock > "Automatically hide and show the Dock").
#   autohide-delay          seconds the pointer must rest on the edge first.
#                           Raise to ~1000 to stop hover reveals entirely and
#                           drive it only with Cmd+Opt+D.
#   autohide-time-modifier  slide animation speed multiplier (lower = faster).
print_status "Auto-hiding the Dock"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.15
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Smaller tiles, no zoom-on-hover (Desktop & Dock > Size / Magnification).
print_status "Shrinking Dock tiles and disabling magnification"
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock magnification -bool false

# Drop the trailing "recent applications" section (Desktop & Dock > "Show
# suggested and recent apps in Dock").
print_status "Hiding recent applications in the Dock"
defaults write com.apple.dock show-recents -bool false

killall Dock 2>/dev/null || true

# NOT scripted, on purpose:
#
# The Dock hopping to whichever display the pointer is on is controlled by
# Desktop & Dock > Mission Control > "Displays have separate Spaces". Turning it
# off pins the Dock and menu bar to the primary display, but then a fullscreen
# app blanks every other display, and it needs a logout to take effect. Left as
# a manual decision:
#     defaults write com.apple.spaces spans-displays -bool true   # then log out
#
# Finder and Trash cannot be removed from the Dock. There is no setting for it.

########################################
# Menu bar
########################################
# Show seconds in the menu bar clock (Control Center > Clock > "Display the time
# with seconds").
print_status "Showing seconds in the menu bar clock"
defaults write com.apple.menuextra.clock ShowSeconds -bool true
killall SystemUIServer 2>/dev/null || true

########################################
# Finder
########################################
# Show the path bar at the bottom of Finder windows (View > Show Path Bar).
print_status "Showing Finder path bar"
defaults write com.apple.finder ShowPathbar -bool true
killall Finder 2>/dev/null || true

########################################
# Sound
########################################
# Disable UI sound effects (Sound > Play user interface sound effects).
print_status "Disabling UI sound effects"
defaults write -g com.apple.sound.uiaudio.enabled -int 0

# Mute the alert/beep volume (Sound > Alert volume slider to zero).
print_status "Muting alert volume"
defaults write -g com.apple.sound.beep.volume -float 0

# Mute the startup chime. Stored in firmware (NVRAM), so this needs sudo.
print_status "Muting startup chime (requires sudo)"
sudo nvram StartupMute=%01

########################################
# Google Chrome
########################################
# Allow AppleScript to run JavaScript in Chrome tabs (execute ... javascript).
# This powers the Hammerspoon Google Meet hotkeys (hammerspoon/meet.lua).
# Equivalent to Chrome menu: View > Developer > Allow JavaScript from Apple
# Events. Takes effect on Chrome's next launch.
#
# NOTE: two related permissions are TCC-protected and CANNOT be scripted here;
# grant them manually the first time Hammerspoon runs:
#   - Hammerspoon: Accessibility (for global hotkeys)
#   - Automation: Hammerspoon -> Google Chrome (to control Chrome)
print_status "Allowing JavaScript from Apple Events in Chrome"
defaults write com.google.Chrome AllowJavaScriptAppleEvents -bool true

########################################
# AltTab
########################################
# Trigger AltTab with Cmd+Tab instead of its default Option+Tab (AltTab Settings >
# Controls > Shortcut 1 > hold key). AltTab owns the shortcut and disables the
# native Cmd+Tab / Cmd+Shift+Tab symbolic hotkeys itself, so the Dock's switcher
# stops eating the keystroke. It applies that at launch from these stored prefs,
# which is what makes setting it here equivalent to setting it in the UI.
#
# Two things make this uglier than a normal `defaults write`:
#   - The value is a dict, not a string. `secureData` is an NSKeyedArchiver blob
#     holding an SRShortcut (keyCode 65535 = modifier-only, modifierFlags 1048576
#     = Command); `string` is only the label drawn in the shortcut recorder.
#   - There is no plain-string fallback. AltTab deletes any value it cannot decode
#     and silently reverts to Option+Tab, so the blob is written verbatim.
#
# `nextWindowShortcut` is deliberately absent: Tab is already AltTab's registered
# default for the first slot, so only the hold key needs overriding.
#
# This leaves Cmd+` alone, so macOS keeps cycling windows of the active app. That
# covers what AltTab's second shortcut slot (Option+`) did before v11.0.0 moved
# extra shortcut slots behind AltTab Pro.
print_status "Setting AltTab to trigger on Cmd+Tab"
alttab_was_running=false
if pgrep -x AltTab >/dev/null 2>&1; then
    alttab_was_running=true
    osascript -e 'quit app "AltTab"' 2>/dev/null || true
fi
defaults write com.lwouis.alt-tab-macos holdShortcut '{
  string = "⌘";
  secureData = <
    62706c6973743030d401020304050607
    0a582476657273696f6e592461726368
    697665725424746f7058246f626a6563
    747312000186a05f100f4e534b657965
    644172636869766572d1080954726f6f
    748001a50b0c191a1b55246e756c6cd6
    0d0e0f1011121314151417145d6d6f64
    6966696572466c6167735f101b636861
    7261637465727349676e6f72696e674d
    6f646966696572735624636c6173735a
    63686172616374657273576b6579436f
    64655776657273696f6e800380008004
    80008002800011ffff1200100000d21c
    1d1e1f5a24636c6173736e616d655824
    636c61737365735a535253686f727463
    7574a21e20584e534f626a6563740811
    1a24293237494c5153595f6c7a989faa
    b2babcbec0c2c4c6c9ced3dee7f2f500
    00000000000101000000000000002100
    0000000000000000000000000000fe
  >;
}'
# Silence the AltTab Pro upgrade campaign. v11.0.0 made AltTab freemium and added
# a scheduled series of upgrade prompts (welcome, then days 4, 12, 15, 21, and a
# final day-35 window). Only the day-35 window carries a "No thanks, don't ask
# again" button, and clicking it sets exactly these two flags. Writing them up
# front skips the whole series: `ProTransitionScheduler.computeNextFireDate`
# returns nil as soon as both are set. Note it takes BOTH; `userOptedOut` alone
# leaves the early-return untriggered. This is the app's own opt-out, not a
# bypass of anything paid, and Pro features stay locked either way.
print_status "Opting out of the AltTab Pro upgrade prompts"
defaults write com.lwouis.alt-tab-macos.license "proTransition.userOptedOut" -bool true
defaults write com.lwouis.alt-tab-macos.license "proTransition.hasSeenDay35" -bool true

# Drop AltTab to a single shortcut slot. Slot 2 (Option+`) is still configured by
# default, but v11 hard-gates its keypress behind Pro, so it no longer switches
# anything and only raises an upgrade popover, which the opt-out above does NOT
# suppress. Setting the count to 1 unregisters the slot so the popover can't fire.
# Stored as a string ("2" by default), so -string, not -int. Raise it back to 2 if
# AltTab Pro ever gets bought.
print_status "Limiting AltTab to one shortcut slot"
defaults write com.lwouis.alt-tab-macos shortcutCount -string 1

# AltTab caches preferences in memory, so the new shortcut needs a relaunch.
if [[ "$alttab_was_running" == true ]]; then
    open -a AltTab 2>/dev/null || true
fi

########################################
# VimR
########################################
# Open files from Finder in the window that is already there, instead of
# spawning a new VimR instance per file. Double-clicking five files should give
# five buffers, not five windows.
#
# `inCurrentWindow` is the enum's own raw value; VimR's AppDelegate switches on
# exactly two cases, .inCurrentWindow (open in the key window) and everything
# else (new main window), so this is the only value that changes the behaviour.
#
# Two reasons this is PlistBuddy rather than `defaults write`:
#   - The key lives nested inside a numeric state-version dict (168 at time of
#     writing), so there is no top-level key to target. The version is discovered
#     rather than hardcoded, since it moves with VimR releases.
#   - VimR rewrites its whole plist when it quits, so writing while it runs is
#     pointless. Quit first, write, relaunch, exactly like the AltTab block.
#
# Deliberately NOT touching open-new-window-on-reactivation or
# open-new-window-when-launching. Zeroing those means clicking the Dock icon
# with no window open does nothing at all, which reads as a broken app.
vimr_plist="$HOME/Library/Preferences/com.qvacua.VimR.plist"
if [[ -f "$vimr_plist" ]]; then
    vimr_was_running=false
    if pgrep -x VimR >/dev/null 2>&1; then
        vimr_was_running=true
        osascript -e 'quit app "VimR"' 2>/dev/null || true
        sleep 2
    fi
    vimr_state_key=$(/usr/libexec/PlistBuddy -c "Print" "$vimr_plist" 2>/dev/null |
        grep -oE "^    [0-9]+ = Dict" | head -1 | tr -dc '0-9')
    if [[ -n "$vimr_state_key" ]]; then
        print_status "Setting VimR to open files in the current window"
        /usr/libexec/PlistBuddy \
            -c "Set :${vimr_state_key}:open-files-from-applications-action inCurrentWindow" \
            "$vimr_plist" 2>/dev/null || true

        # VimR ships with Menlo, which has none of the Nerd Font glyphs the nvim
        # config draws with, so anything using them renders as garbage boxes.
        # This is the PostScript name (what the plist wants), not the family
        # name Ghostty takes. The Mono variant is deliberate: VimR renders on a
        # character grid, and the non-Mono glyphs are double-width and overlap.
        #   MesloLGSNFM-Regular  Nerd Font Mono   <- this
        #   MesloLGSNF-Regular   Nerd Font        (what ghostty/config names)
        print_status "Setting VimR's font to MesloLGS Nerd Font Mono"
        /usr/libexec/PlistBuddy \
            -c "Set :${vimr_state_key}:main-window:appearance:editor-font-name MesloLGSNFM-Regular" \
            "$vimr_plist" 2>/dev/null || true
        killall cfprefsd 2>/dev/null || true
    else
        print_warning "Could not find VimR's state key; skipping open-in-current-window"
    fi
    if [[ "$vimr_was_running" == true ]]; then
        open -a VimR 2>/dev/null || true
    fi
else
    print_warning "VimR has no preferences file yet; launch it once, then re-run"
fi

########################################
# Default apps
########################################
# Open text, code and data files in VimR from Finder, rather than TextEdit,
# Console, or (for .csv) Numbers. Was MacVim, which had quietly become the
# handler for a dozen-odd types.
#
# VimR over Neovide because it is a native Mac app with windows, tabs and a
# file drawer, the same shape as MacVim; Neovide is closer to the terminal nvim
# floated into a window. Both read the same nvim config, so `vim/` is now
# Windows-only.
#
# ASSOCIATE BY UTI, NOT BY EXTENSION. `duti -s <id> md all` exits 0 and changes
# nothing; only `duti -s <id> net.daringfireball.markdown all` actually works.
# The exception is csv, where the extension form is the one that takes, so it
# gets both. Find a type's real UTI with:
#     mdls -name kMDItemContentType somefile.ext
#
# Three oddities behind the list below:
#   - `.ts` is public.mpeg-2-transport-stream. macOS classes it as video, so
#     claiming TypeScript here also claims MPEG-2 streams. Fine in practice, but
#     that is why a video UTI appears in an editor list.
#   - `.jsx` has only a dynamic UTI (dyn.ah62d4rv4ge80y652), which means macOS
#     has no idea what it is. Not claimable, so it is absent.
#   - The org.vim.* UTIs (.tsx, .toml, .ini, .conf, .sql) are DEFINED BY MACVIM.
#     VimR exports none of them. Uninstalling MacVim removes those declarations
#     and orphans those five types no matter what is set here, which is a real
#     constraint on retiring it.
#
# Note .md goes to VimR, including notes in the Obsidian vault. LaunchServices
# cannot route by path, so opening vault files from Finder lands here.
#
# `duti` is brew-installed and not guaranteed present, so skip with a warning
# rather than fail. The bundle id is looked up at runtime, so this works however
# VimR was installed, and skips if it is absent.
vimr_utis=(
    public.plain-text                    # .txt .text
    net.daringfireball.markdown          # .md .markdown
    com.netscape.javascript-source       # .js
    public.python-script                 # .py
    public.ruby-script                   # .rb
    org.golang.go-script                 # .go
    org.rust-lang.rust-script            # .rs
    org.lua.lua-source                   # .lua
    public.shell-script                  # .sh
    public.zsh-script                    # .zsh
    public.bash-script                   # .bash
    public.json                          # .json
    public.yaml                          # .yaml .yml
    public.tab-separated-values-text     # .tsv
    com.apple.log                        # .log
    public.mpeg-2-transport-stream       # .ts, see note above
    org.vim.typescript-source            # .tsx   ) these five are MacVim's
    org.vim.toml-file                    # .toml  ) declarations and die
    org.vim.ini-file                     # .ini   ) with it
    org.vim.cfg-file                     # .conf  )
    org.vim.sql-file                     # .sql   )
    public.comma-separated-values-text   # .csv
)
if command -v duti >/dev/null 2>&1; then
    vimr_id=$(osascript -e 'id of app "VimR"' 2>/dev/null || true)
    if [[ -n "$vimr_id" ]]; then
        print_status "Setting VimR ($vimr_id) as handler for ${#vimr_utis[@]} file types"
        for uti in "${vimr_utis[@]}"; do
            duti -s "$vimr_id" "$uti" all 2>/dev/null || true
        done
        # csv is the one type where the extension form is what LaunchServices
        # honours; the UTI above is claimed too, for correctness.
        duti -s "$vimr_id" csv all 2>/dev/null || true
    else
        print_warning "VimR not found; skipping file type associations"
    fi
else
    print_warning "duti not found; skipping VimR file type associations (brew install duti)"
fi

print_status "Done. Some changes require a logout/restart to take effect."
print_status "Remaining manual steps (permissions, sign-ins) are in README.md > Fresh machine setup > step 7."
