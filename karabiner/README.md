# Karabiner-Elements

Holds one rule.

## Caps Lock -> Hyper

**Caps Lock becomes a Hyper key** (Cmd+Ctrl+Opt+Shift when held) and **Escape
when tapped alone**. Nothing else on macOS claims that four-modifier
combination, which is what makes it safe to hang an entire keymap off it.

The keymap itself lives in `hammerspoon/launcher.lua`: Hyper+letter and
Hyper+number jump to apps, Hyper+/ shows the cheat sheet. Karabiner only
produces the modifier; Hammerspoon decides what it does.

## Do not try to remap the MX Anywhere 3 thumb buttons here

Tried and abandoned 2026-08-10. Karabiner **cannot** see those buttons, so no
rule will ever fire on them. Written down because the idea looks obviously
workable and is worth an hour of anyone's time before they find out otherwise.

The mouse does not send the thumb buttons as HID `button4`/`button5`. They
travel over Logitech's proprietary HID++ channel to the Options+ agent, which
delivers the navigation action straight to the frontmost application's process.
Karabiner sits below that, on the raw HID stream, and there is nothing there to
match.

How that was established, in case a future mouse needs the same test:

- Karabiner was made to grab the mouse (`devices` entry, `"ignore": false`, ids
  from `karabiner_cli --list-connected-devices`); `/var/log/karabiner/core_service.log`
  confirmed `... MX Anywhere 3 ... is started (grabbed)`. A `pointing_button`
  rule still did nothing.
- A Hammerspoon `hs.eventtap` on `otherMouseDown` + modified `keyDown` logged
  ordinary keyboard chords but **never** saw a thumb-button press, even while
  Chrome was visibly navigating back from it. Invisible to a session-level tap
  means it was posted directly to the target pid.

Killing the Options+ agent *does* hand the thumb buttons back: with it stopped
and the mouse power-cycled, they report as ordinary `button4`/`button5` and
Karabiner can remap them freely. That was measured, and it is a real option if
Logitech's software ever becomes intolerable.

It was rejected anyway, because the other customisation on this mouse — middle
button and wheel-mode-shift swapped — cannot survive without Options+, for two
separate reasons:

- The **button behind the wheel never reports anything to the host.** Twenty-six
  minutes of logging caught zero events from it. It toggles ratchet/free-spin in
  firmware. Karabiner can only transform events that exist.
- **Making the wheel press toggle ratchet/free-spin is not a remap at all.** It
  means sending an HID++ *command to the mouse*. Karabiner consumes events and
  emits events; it has no channel for writing to a device. Even a visible button
  would not help here.

So that swap requires an HID++ agent, and on macOS Options+ is the only shipped
one (Linux has `solaar` and `logiops`; there is no Mac equivalent). Since
Options+ has to run regardless, the VS Code navigation goes there too, as a
per-application keystroke assignment. See `README.md` step 7 for what to click.

**None of this generalises to other mice.** It is a property of Logitech's
HID++ stack, not of Karabiner or of mice at large. An ordinary HID mouse with no
vendor daemon reports its thumb buttons as plain `button4`/`button5`, and then
the rule sketched above works exactly as expected — it only needs a `devices`
entry to opt the pointing device in, since Karabiner ignores pointing devices by
default. `TODO.md` has the pending version of this for the Keychron travel mouse.

## Why JSON with no comments

`karabiner.json` is machine-written, and JSON has no comment syntax, so the
explanation lives here instead. The one rule to understand:

```
from        caps_lock, with "optional": ["any"] so it composes with other modifiers
to          left_shift + command + control + option   (all four = Hyper)
to_if_alone escape, if released within 250ms without another key
```

Bump `basic.to_if_alone_timeout_milliseconds` if you type slowly enough that a
deliberate tap sometimes fails to produce Escape.

## Symlink caveat, read before editing in the UI

`~/.config/karabiner/karabiner.json` is a symlink back to this repo. Karabiner
rewrites that file on **any** settings change, and it writes atomically (temp
file plus rename), which can **replace the symlink with a regular file**. When
that happens your changes silently stop reaching this repo.

After changing anything in the Karabiner UI:

```sh
ls -l ~/.config/karabiner/karabiner.json    # still an arrow pointing here?
```

If it became a real file, copy it back and re-link:

```sh
cp ~/.config/karabiner/karabiner.json ~/dotfiles/karabiner/karabiner.json
ln -sfn ~/dotfiles/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
```

Editing `karabiner/karabiner.json` in this repo by hand is the safer path.

**But a hand edit does not reload on its own.** Karabiner watches the
*directory* `~/.config/karabiner/` for filesystem events. Editing the symlink's
target over here changes a file in a different directory, so no event fires and
the daemon keeps running the config it loaded at login — the edit looks like it
did nothing. Re-create the symlink to force a reload; replacing the directory
entry is an event Karabiner does see:

```sh
ln -sfn ~/dotfiles/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
```

Confirm it actually reloaded, and that the devices you expect were picked up:

```sh
grep 'Load \|grabbed' /var/log/karabiner/core_service.log | tail
```

A fresh `Load /Users/jq/.config/karabiner/karabiner.json...` with the current
timestamp means the change is live.

## First-run permissions

Karabiner installs a system driver extension, so it needs more than the usual
Accessibility grant. See `README.md` > "Fresh machine setup" > step 7.

## Conflicts to watch for

- System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys must leave
  Caps Lock set to "Caps Lock". If macOS itself remaps it, Karabiner never sees
  the key.
- Caps Lock's actual capslock function is gone. That is the intent.
