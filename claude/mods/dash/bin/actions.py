"""The only code in the browser server that acts on the outside world.
Each function takes the shared gate before acting and never retries."""
import re
import subprocess

from gate import take_locked

CMUX = "cmux"


def _run(argv, timeout=15):
    return subprocess.run(argv, capture_output=True, text=True, timeout=timeout)


def send_text(session_id, surface, text):
    """Types `text` into a session's prompt and submits it, as Josh would.
    Refuses when the prompt holds a draft. Returns (ok, message)."""
    screen = _run([CMUX, "read-screen", "--surface", surface, "--lines", "15"]).stdout
    prompts = re.findall(r"^❯ ?(.*)$", screen, flags=re.M)
    if not prompts:
        return False, "couldn't find that session's prompt; not sent"
    if prompts[-1].strip():
        return False, "that session has a draft in its prompt; not sent"
    code, reason = take_locked("send", session_id)
    if code != 0:
        return False, reason
    _run([CMUX, "send", "--surface", surface, text])
    _run([CMUX, "send-key", "--surface", surface, "Enter"])
    return True, "sent"


def review_team(url):
    """The team to request for a PR's org, from machine-local config (the
    dotfiles repo is public, so no org or team names live in code)."""
    import json
    import os
    try:
        with open(os.path.expanduser("~/.claude/dash/config.json")) as f:
            teams = json.load(f).get("reviewTeams", {})
    except (OSError, ValueError):
        return None
    org = url.split("/")[3]
    return f"{org}/{teams[org]}" if org in teams else None


def ready_for_review(url):
    """Takes a draft out of draft and requests the org's review team."""
    code, reason = take_locked("gh", url)
    if code != 0:
        return False, reason
    res = _run(["gh", "pr", "ready", url], timeout=30)
    if res.returncode != 0 and "already" not in (res.stderr or ""):
        return False, (res.stderr or "gh pr ready failed").strip()[:200]
    team = review_team(url)
    if not team:
        return True, "ready for review (no review team configured for this org)"
    res = _run(["gh", "pr", "edit", url, "--add-reviewer", team], timeout=30)
    if res.returncode != 0:
        return False, f"ready, but requesting {team} failed: " + (res.stderr or "").strip()[:160]
    return True, f"ready for review; requested {team}"


def focus(workspace, surface):
    _run([CMUX, "select-workspace", "--workspace", workspace])
    _run([CMUX, "focus-panel", "--panel", surface, "--workspace", workspace])
    return True, "focused"


if __name__ == "__main__":
    import sys

    # For the /dash mod: `actions.py ready <url>` prints the result.
    if len(sys.argv) == 3 and sys.argv[1] == "ready":
        ok, msg = ready_for_review(sys.argv[2])
        print(msg)
        sys.exit(0 if ok else 1)
    sys.exit(2)
