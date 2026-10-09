"""One circuit breaker shared by every session (and anything else) that makes
dash spend tokens or type into a session. State lives in a locked file, so
separate processes, reloads and restarts all see the same counters.

  gate.py take <model|send> <key>   exit 0 allowed, 1 refused, 2 tripped
  gate.py status                    prints the state as JSON
  gate.py reset                     clears a trip (by hand only)

A trip is sticky: nothing clears it but `reset`. Refused attempts count toward
tripping, so a loop that keeps retrying a refused call still trips it.
"""
import fcntl
import json
import os
import sys
import time

DIR = os.path.expanduser("~/.claude/dash")
STATE = os.path.join(DIR, "gate.json")
LOCK = os.path.join(DIR, "gate.lock")

ATTEMPTS_PER_SECOND = 5     # any kind, allowed or refused
MODEL_PER_SECOND = 2
MODEL_PER_MINUTE = 20
SENDS_PER_10S = 3
SEND_COOLDOWN_S = 30        # same key: refused, not tripped (double clicks)
GH_PER_10S = 5              # gh writes (mark ready)


def load():
    try:
        with open(STATE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {"tripped": None, "events": [], "attempts": []}


def save(state):
    tmp = STATE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f)
    os.replace(tmp, STATE)


def take(state, kind, key, now):
    """Returns (exit code, reason). Mutates state."""
    if state.get("tripped"):
        return 2, "breaker tripped: " + state["tripped"]["reason"]
    state["attempts"] = [t for t in state.get("attempts", []) if now - t < 1] + [now]
    state["events"] = [e for e in state.get("events", []) if now - e["t"] < 60]

    def trip(reason):
        state["tripped"] = {"at": now, "reason": reason}
        return 2, "breaker tripped: " + reason

    if len(state["attempts"]) > ATTEMPTS_PER_SECOND:
        return trip(f"more than {ATTEMPTS_PER_SECOND} attempts in a second")
    ev = [e for e in state["events"] if e["kind"] == kind]
    if kind == "model":
        if sum(now - e["t"] < 1 for e in ev) >= MODEL_PER_SECOND:
            return trip(f"{MODEL_PER_SECOND} model calls in a second")
        if len(ev) >= MODEL_PER_MINUTE:
            return trip(f"{MODEL_PER_MINUTE} model calls in a minute")
    elif kind in ("send", "gh"):
        if any(e["key"] == key and now - e["t"] < SEND_COOLDOWN_S for e in ev):
            return 1, f"already did that to {key} in the last {SEND_COOLDOWN_S}s"
        limit = SENDS_PER_10S if kind == "send" else GH_PER_10S
        if sum(now - e["t"] < 10 for e in ev) >= limit:
            return trip(f"{limit} {kind} actions in 10 seconds")
    else:
        return 1, f"unknown kind {kind}"
    state["events"].append({"t": now, "kind": kind, "key": key})
    return 0, "ok"


def take_locked(kind, key):
    """take() under the shared lock, for callers in this process."""
    os.makedirs(DIR, exist_ok=True)
    with open(LOCK, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state = load()
        code, reason = take(state, kind, key, time.time())
        save(state)
        return code, reason


def status():
    with open(LOCK, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        return load().get("tripped")


def main(argv):
    os.makedirs(DIR, exist_ok=True)
    with open(LOCK, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state = load()
        if argv[:1] == ["take"] and len(argv) == 3:
            code, reason = take(state, argv[1], argv[2], time.time())
            save(state)
            print(reason)
            return code
        if argv == ["reset"]:
            state["tripped"] = None
            state["attempts"] = []
            save(state)
            print("reset")
            return 0
        print(json.dumps({"tripped": state.get("tripped")}))
        return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
