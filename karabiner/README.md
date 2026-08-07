# Karabiner-Elements

Holds one rule: **Caps Lock becomes a Hyper key** (Cmd+Ctrl+Opt+Shift when held)
and **Escape when tapped alone**. Nothing else on macOS claims that four-modifier
combination, which is what makes it safe to hang an entire keymap off it.

The keymap itself lives in `hammerspoon/launcher.lua`: Hyper+letter and
Hyper+number jump to apps, Hyper+/ shows the cheat sheet. Karabiner only
produces the modifier; Hammerspoon decides what it does.

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
Karabiner picks up changes to the file within a second or two, no restart needed.

## First-run permissions

Karabiner installs a system driver extension, so it needs more than the usual
Accessibility grant. See `README.md` > "Fresh machine setup" > step 7.

## Conflicts to watch for

- System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys must leave
  Caps Lock set to "Caps Lock". If macOS itself remaps it, Karabiner never sees
  the key.
- Caps Lock's actual capslock function is gone. That is the intent.
