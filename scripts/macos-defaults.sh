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
# Default apps
########################################
# Open .csv files in MacVim. Uses `duti` to set the LaunchServices handler for
# the CSV UTI. `duti` is brew-installed and not guaranteed present, so skip
# (with a warning) rather than fail if it's missing. The MacVim bundle id is
# looked up at runtime rather than hardcoded, so this works regardless of how
# MacVim was installed (and skips gracefully if it isn't).
if command -v duti >/dev/null 2>&1; then
    macvim_id=$(osascript -e 'id of app "MacVim"' 2>/dev/null || true)
    if [[ -n "$macvim_id" ]]; then
        print_status "Setting MacVim ($macvim_id) as default handler for .csv files"
        duti -s "$macvim_id" public.comma-separated-values-text all
    else
        print_warning "MacVim not found; skipping .csv association"
    fi
else
    print_warning "duti not found; skipping .csv -> MacVim association (brew install duti)"
fi

print_status "Done. Some changes require a logout/restart to take effect."
