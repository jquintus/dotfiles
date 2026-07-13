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

print_status "Done. Some changes require a logout/restart to take effect."
