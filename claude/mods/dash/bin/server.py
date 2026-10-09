"""Dash in a browser: a local server that rebuilds the dashboard from the same
scanners the /dash mod uses and accepts a short list of named actions.

  python3 -I server.py            serves http://127.0.0.1:7419/

Safety:
  - binds 127.0.0.1 only; rejects any Host but 127.0.0.1/localhost:PORT
    (DNS rebinding) and any foreign Origin
  - every API call needs the per-install token as X-Dash-Token, a custom
    header no other site can send without a CORS preflight this server never
    approves
  - actions are named and validated against current state; reply text comes
    from the server's own data, never from the request
  - each action id runs at most once; every send and gh write takes the shared
    breaker in gate.py; nothing retries
  - it never calls a model: verdicts come from the cache the mods write
"""
import json
import os
import secrets
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# Run with -I (isolated), which leaves this folder off sys.path.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import actions  # noqa: E402
import gate  # noqa: E402
import scan  # noqa: E402

PORT = 7419
HOSTS = {f"127.0.0.1:{PORT}", f"localhost:{PORT}"}
DIR = os.path.expanduser("~/.claude/dash")
TOKEN_FILE = os.path.join(DIR, "token")
HERE = os.path.dirname(os.path.abspath(__file__))
MAX_BODY = 4096


def token():
    os.makedirs(DIR, exist_ok=True)
    if not os.path.exists(TOKEN_FILE):
        fd = os.open(TOKEN_FILE, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "w") as f:
            f.write(secrets.token_urlsafe(32))
    with open(TOKEN_FILE) as f:
        return f.read().strip()


def read_json(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, ValueError):
        return default


# ---------- state ----------

lock = threading.Lock()
state = {"sessions": [], "questions": [], "github": {}, "tickets": [], "updatedAt": 0}


def session_infos():
    out = []
    for pid, sid in scan.live_sessions():
        cwd = scan.cwd_of(pid)
        path = scan.transcript(sid, cwd)
        if not path:
            continue
        entries = scan.read_tail(path)
        title, _ = scan.pending(entries)
        surface, workspace = scan.cmux_ids(pid)
        sid = sid or os.path.basename(path)[:-6]
        out.append({
            "id": sid,
            "name": title or os.path.basename(cwd) or sid[:8],
            "cwd": cwd,
            "surface": surface,
            "workspace": workspace,
        })
    return out


def refresh_local(with_prs):
    infos = session_infos()
    prev = {s["id"]: s for s in state["sessions"]}
    for s in infos:
        try:
            here = scan.here(s["id"], with_prs)
        except Exception:
            here = {"prs": None, "tasks": [], "ticketHint": None}
        s["tasks"] = here["tasks"]
        s["ticket"] = here.get("ticketHint")
        s["prs"] = here["prs"] if with_prs else prev.get(s["id"], {}).get("prs", [])

    verdicts = read_json(os.path.join(DIR, "verdicts.json"), {})
    questions = []
    for q in scan.sessions()["questions"]:
        key = f"{q['id']}@{q['askedAt']}"
        q["key"] = key
        if q["kind"] == "ask":
            questions.append(q)
            continue
        v = verdicts.get(key)
        if v is None:
            # Untriaged: no model here, so fall back to the plain check.
            if q.get("hasQuestionMark"):
                questions.append(q)
            continue
        if v.get("isWaiting"):
            q.update(summary=v.get("summary") or q["summary"], gist=v.get("gist", ""), replies=v.get("replies", []))
            questions.append(q)

    with lock:
        state["sessions"] = infos
        state["questions"] = questions
        state["tickets"] = read_json(os.path.join(DIR, "tickets.json"), [])
        state["tripped"] = gate.status()
        state["updatedAt"] = time.time()


def refresh_github():
    data = scan.github()
    with lock:
        state["github"] = data


def loop():
    """Fixed timers; a failure waits for the next tick, never retries sooner."""
    tick = 0
    while True:
        try:
            refresh_local(with_prs=tick % 4 == 0)
        except Exception as err:
            print("local refresh failed:", err, flush=True)
        if tick % 6 == 0:
            try:
                refresh_github()
            except Exception as err:
                print("github refresh failed:", err, flush=True)
        tick += 1
        time.sleep(15)


# ---------- actions ----------

seen_ids = []
seen_lock = threading.Lock()


def run_action(body):
    action_id = str(body.get("actionId", ""))
    if not (8 <= len(action_id) <= 64):
        return 400, "bad action id"
    with seen_lock:
        if action_id in seen_ids:
            return 409, "already handled"
        seen_ids.append(action_id)
        del seen_ids[:-500]

    kind = body.get("kind")
    with lock:
        sessions = {s["id"]: s for s in state["sessions"]}
        questions = {q["key"]: q for q in state["questions"]}
        prs = {p["url"]: p for p in state["github"].get("mine", [])}
        for s in state["sessions"]:
            for p in s.get("prs") or []:
                prs[p["url"]] = p

    if kind == "ready":
        pr = prs.get(body.get("url"))
        if not pr or pr.get("action") != "mark ready":
            return 400, "that PR isn't a draft waiting for review"
        ok, msg = actions.ready_for_review(pr["url"])
        return (200 if ok else 409), msg

    if kind in ("reply", "more", "focus"):
        q = questions.get(body.get("q"))
        if not q or not q.get("surface"):
            return 400, "that question isn't open anymore"
        if kind == "focus":
            return 200, actions.focus(q["workspace"], q["surface"])[1]
        if q["kind"] != "text":
            return 400, "answer this one in the session"
        if kind == "more":
            text = ("Before I decide, give me more context on this: what led here, what each "
                    "option changes, and what you'd worry about with each. Keep it short.")
        else:
            replies = q.get("replies") or []
            i = body.get("index")
            if not isinstance(i, int) or not 0 <= i < len(replies):
                return 400, "no such reply"
            text = replies[i]["reply"]
        ok, msg = actions.send_text(q["id"], q["surface"], text)
        return (200 if ok else 409), msg

    if kind == "reset":
        gate.main(["reset"])
        return 200, "breaker reset"

    return 400, "unknown action"


# ---------- http ----------

TOKEN = token()


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def guard(self):
        if self.headers.get("Host") not in HOSTS:
            self.reply(403, "text/plain", b"bad host")
            return False
        origin = self.headers.get("Origin")
        if origin and origin not in {f"http://{h}" for h in HOSTS}:
            self.reply(403, "text/plain", b"bad origin")
            return False
        return True

    def authed(self):
        if not secrets.compare_digest(self.headers.get("X-Dash-Token", ""), TOKEN):
            self.reply(403, "text/plain", b"bad token")
            return False
        return True

    def reply(self, code, ctype, body):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if not self.guard():
            return
        if self.path == "/":
            with open(os.path.join(HERE, "dash.html")) as f:
                page = f.read().replace("__DASH_TOKEN__", TOKEN)
            self.reply(200, "text/html; charset=utf-8", page.encode())
        elif self.path == "/api/state":
            if not self.authed():
                return
            with lock:
                body = json.dumps(state).encode()
            self.reply(200, "application/json", body)
        else:
            self.reply(404, "text/plain", b"not found")

    def do_POST(self):
        if not self.guard() or not self.authed():
            return
        if self.path != "/api/action":
            self.reply(404, "text/plain", b"not found")
            return
        size = int(self.headers.get("Content-Length") or 0)
        if size > MAX_BODY:
            self.reply(413, "text/plain", b"too big")
            return
        try:
            body = json.loads(self.rfile.read(size) or b"{}")
        except ValueError:
            self.reply(400, "text/plain", b"bad json")
            return
        code, msg = run_action(body if isinstance(body, dict) else {})
        self.reply(code, "application/json", json.dumps({"message": msg}).encode())


if __name__ == "__main__":
    threading.Thread(target=loop, daemon=True).start()
    print(f"dash: http://127.0.0.1:{PORT}/", flush=True)
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
