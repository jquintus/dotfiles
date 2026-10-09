"""Collect what needs Josh: pending questions in live Claude sessions, and
GitHub PRs to review, merge, or apply (Atlantis). Prints JSON for the dash mod.

Usage: scan.py sessions | scan.py github
"""
import glob
import json
import os
import re
import subprocess
import sys

PROJECTS = os.path.expanduser("~/.claude/projects")
TAIL_BYTES = 3_000_000


def run(argv, timeout=20):
    return subprocess.run(argv, capture_output=True, text=True, timeout=timeout).stdout


# ---------- sessions ----------

def live_sessions():
    """(pid, session id) for every interactive claude process."""
    out = []
    for line in run(["ps", "-Ao", "pid=,command="]).splitlines():
        pid, _, cmd = line.strip().partition(" ")
        argv = cmd.split()
        if not argv or not argv[0].endswith("/claude") or "-p" in argv or "--print" in argv:
            continue
        sid = None
        for flag in ("--session-id", "--resume", "-r"):
            if flag in argv and argv.index(flag) + 1 < len(argv):
                sid = argv[argv.index(flag) + 1]
                break
        out.append((pid, sid))
    return out


def cwd_of(pid):
    out = run(["lsof", "-a", "-p", pid, "-d", "cwd", "-Fn"])
    return next((l[1:] for l in out.splitlines() if l.startswith("n")), "")


def transcript(sid, cwd):
    """The session's transcript; a plain `claude` gets its project's newest."""
    if sid:
        paths = glob.glob(os.path.join(PROJECTS, "*", f"{sid}.jsonl"))
    else:
        paths = glob.glob(os.path.join(PROJECTS, re.sub(r"[^A-Za-z0-9]", "-", cwd), "*.jsonl"))
        paths.sort(key=os.path.getmtime, reverse=True)
    return paths[0] if paths else None


def cmux_ids(pid):
    env = run(["ps", "eww", "-o", "command=", "-p", pid])
    get = lambda k: (re.search(rf"\b{k}=(\S+)", env) or [None, None])[1]
    return get("CMUX_SURFACE_ID"), get("CMUX_WORKSPACE_ID")


def read_tail(path):
    with open(path, "rb") as f:
        f.seek(0, 2)
        size = f.tell()
        f.seek(max(0, size - TAIL_BYTES))
        data = f.read().decode("utf-8", "replace")
    lines = data.splitlines()
    if size > TAIL_BYTES:
        lines = lines[1:]  # first line is partial
    out = []
    for l in lines:
        try:
            out.append(json.loads(l))
        except ValueError:
            pass
    return out


def text_of(content):
    if isinstance(content, str):
        return content
    return "\n".join(b.get("text", "") for b in content or [] if b.get("type") == "text")


def ends_with_question(text):
    tail = re.sub(r"```.*?```", "", text, flags=re.S).strip()[-400:]
    last = tail.split("\n\n")[-1]
    return "?" in last


def pending(entries):
    """The pending question at the end of a transcript, or None."""
    title = None
    convo = []
    for e in entries:
        if e.get("type") == "custom-title":
            title = e.get("customTitle")
        elif e.get("type") == "ai-title" and not title:
            title = e.get("aiTitle") or e.get("title")
        if e.get("type") in ("user", "assistant") and not e.get("isSidechain"):
            convo.append(e)
    if not convo or convo[-1]["type"] != "assistant":
        return title, None

    # The trailing assistant turn, and the user prompt that started it.
    i = len(convo)
    while i > 0 and convo[i - 1]["type"] == "assistant":
        i -= 1
    turn = convo[i:]
    prompt = None
    for e in reversed(convo[:i]):
        c = e["message"].get("content")
        if isinstance(c, str) or not any(b.get("type") == "tool_result" for b in c or []):
            prompt = text_of(c).strip()
            break

    last = turn[-1]
    blocks = last["message"].get("content") or []
    asked_at = last.get("timestamp")
    tool = next((b for b in reversed(blocks) if b.get("type") == "tool_use"), None)
    if tool:
        if tool.get("name") != "AskUserQuestion":
            return title, None  # a tool is running or awaiting permission
        qs = tool.get("input", {}).get("questions", [])
        return title, {
            "kind": "ask",
            "text": "\n\n".join(
                q.get("question", "") + "\n" + "\n".join(f"  - {o.get('label')}: {o.get('description', '')}" for o in q.get("options", []))
                for q in qs
            ),
            "summary": qs[0].get("question", "") if qs else "Question",
            "askedAt": asked_at,
            "prompt": prompt,
        }
    text = "\n".join(text_of(e["message"].get("content")) for e in turn).strip()
    if last["message"].get("stop_reason") not in (None, "end_turn") or not text:
        return title, None
    # Every finished turn is a candidate; the mod asks a model whether it
    # waits on Josh. `hasQuestionMark` is the fallback when it can't.
    q = [s for s in re.split(r"(?<=[.?!])\s+|\n", text) if s.strip().endswith("?")]
    return title, {
        "kind": "text",
        "hasQuestionMark": ends_with_question(text),
        "text": text,
        "summary": (q[-1] if q else text[-120:]).strip(),
        "askedAt": asked_at,
        "prompt": prompt,
    }


def sessions():
    out = []
    for pid, sid in live_sessions():
        cwd = cwd_of(pid)
        path = transcript(sid, cwd)
        if not path:
            continue
        title, q = pending(read_tail(path))
        if not q:
            continue
        sid = sid or os.path.basename(path)[:-6]
        surface, workspace = cmux_ids(pid)
        q.update(
            id=sid,
            name=title or os.path.basename(cwd) or sid[:8],
            cwd=cwd,
            surface=surface,
            workspace=workspace,
        )
        out.append(q)
    out.sort(key=lambda q: q.get("askedAt") or "")
    return {"questions": out}


# ---------- github ----------

def github_query():
    return """
query {
  reviews: search(type: ISSUE, first: 30, query: "is:pr is:open review-requested:@me -is:draft archived:false") {
    nodes { ... on PullRequest { number title url updatedAt repository { nameWithOwner } author { login } } }
  }
  mine: search(type: ISSUE, first: 50, query: "is:pr is:open author:@me archived:false sort:updated-desc") {
    nodes { ... on PullRequest { %s } }
  }
}
""" % PR_FIELDS


def item(pr, **extra):
    return {
        "key": pr["url"],
        "repo": pr["repository"]["nameWithOwner"],
        "number": pr["number"],
        "title": pr["title"],
        "url": pr["url"],
        **extra,
    }


def classify(data):
    reviews = [item(p, author=(p.get("author") or {}).get("login")) for p in data["reviews"]["nodes"] if p]
    mine = [pr_status(p) for p in data["mine"]["nodes"] if p]
    merges = [m for m in mine if m["action"] == "merge"]
    applies = [m for m in mine if m["action"] == "apply"]
    return {"reviews": reviews, "merges": merges, "applies": applies, "mine": mine}


def github():
    out = run(["gh", "api", "graphql", "-f", f"query={github_query()}"], timeout=30)
    return classify(json.loads(out)["data"])


# ---------- this session ----------

def started_at(sid):
    """When the process running session `sid` started, as an ISO string."""
    for pid, live in live_sessions():
        if live == sid:
            lstart = run(["ps", "-o", "lstart=", "-p", pid]).strip()
            out = run(["date", "-u", "-j", "-f", "%a %b %d %T %Y", lstart, "+%Y-%m-%dT%H:%M:%S"]).strip()
            return out or None
    return None


BG_ID = re.compile(r"agentId:\s*([\w-]+)|with ID:\s*([\w-]+)|\b(wf_[\w-]+)|task[_ ]?id[\":\s]+([\w-]+)", re.I)
KINDS = {"Agent": "agent", "Bash": "shell", "Monitor": "monitor", "Workflow": "workflow"}


def background(entries, since):
    """Background tasks launched since `since` that haven't reported finishing."""
    launched, done = {}, set()
    calls = {}
    wakeup = None
    for e in entries:
        if e.get("type") not in ("user", "assistant") or e.get("isSidechain"):
            # Completions also arrive as system/attachment entries.
            done.update(re.findall(r"<task-id>([^<]+)</task-id>", json.dumps(e)))
            continue
        c = e["message"].get("content")
        if isinstance(c, str):
            done.update(re.findall(r"<task-id>([^<]+)</task-id>", c))
            continue
        for b in c or []:
            if b.get("type") == "tool_use":
                calls[b["id"]] = b
                if b.get("name") == "TaskStop":
                    i = b.get("input", {})
                    done.add(i.get("task_id") or i.get("shell_id"))
                if b.get("name") == "ScheduleWakeup" and (e.get("timestamp") or "") >= (since or ""):
                    i = b.get("input", {})
                    wakeup = None if i.get("stop") else (e.get("timestamp"), i.get("delaySeconds", 0), i.get("reason", "wakeup"))
            elif b.get("type") == "tool_result":
                call = calls.get(b.get("tool_use_id"))
                if not call or call.get("name") not in KINDS:
                    continue
                if call["name"] == "Bash" and not call.get("input", {}).get("run_in_background"):
                    continue
                text = b.get("content")
                text = text if isinstance(text, str) else json.dumps(text)
                m = BG_ID.search(text)
                if m and (e.get("timestamp") or "") >= (since or ""):
                    tid = next(g for g in m.groups() if g)
                    i = call.get("input", {})
                    launched[tid] = {
                        "id": tid,
                        "kind": KINDS[call["name"]],
                        "label": i.get("description") or i.get("name") or (i.get("command") or "")[:60] or call["name"],
                        "startedAt": e.get("timestamp"),
                    }
            elif b.get("type") == "text":
                done.update(re.findall(r"<task-id>([^<]+)</task-id>", b.get("text", "")))
    tasks = [t for tid, t in launched.items() if tid not in done]
    if wakeup:
        tasks.append({"id": "wakeup", "kind": "wakeup", "label": wakeup[2], "startedAt": wakeup[0], "delaySeconds": wakeup[1]})
    return tasks


PR_FIELDS = """
  number title url state isDraft reviewDecision mergeable baseRefName headRefName
  reviewRequests(first: 20) { nodes { requestedReviewer { ... on Bot { login } ... on User { login } } } }
  latestReviews(first: 20) { nodes { author { login } } }
  reviewThreads(first: 100) { nodes { isResolved comments(first: 1) { nodes { author { login } } } } }
  commits(last: 1) { nodes { commit { statusCheckRollup {
    state
    contexts(first: 100) { nodes {
      __typename
      ... on CheckRun { status conclusion }
      ... on StatusContext { context state }
    } }
  } } } }
"""


def pr_status(p):
    rollup = ((p["commits"]["nodes"] or [{}])[0].get("commit") or {}).get("statusCheckRollup") or {}
    passed = failed = pending = 0
    statuses = {}
    for c in (rollup.get("contexts") or {}).get("nodes", []):
        if c.get("__typename") == "CheckRun":
            if c["status"] != "COMPLETED":
                pending += 1
            elif c["conclusion"] in ("SUCCESS", "NEUTRAL", "SKIPPED"):
                passed += 1
            else:
                failed += 1
        else:
            statuses[c["context"]] = c["state"]
            if c["context"].startswith("atlantis/apply"):
                continue  # apply is an action, not a check
            if c["state"] == "SUCCESS":
                passed += 1
            elif c["state"] in ("PENDING", "EXPECTED"):
                pending += 1
            else:
                failed += 1
    copilot = "none"
    if any(re.search("copilot", (r.get("requestedReviewer") or {}).get("login", ""), re.I) for r in p["reviewRequests"]["nodes"]):
        copilot = "requested"
    elif any(re.search("copilot", (r.get("author") or {}).get("login", ""), re.I) for r in p["latestReviews"]["nodes"]):
        copilot = "reviewed"
    open_threads = [t for t in p["reviewThreads"]["nodes"] if not t["isResolved"]]

    def by_copilot(t):
        first = ((t.get("comments") or {}).get("nodes") or [{}])[0] or {}
        return bool(re.search("copilot", (first.get("author") or {}).get("login", ""), re.I))

    threads = len(open_threads)
    copilot_threads = sum(by_copilot(t) for t in open_threads)
    ci = "fail" if failed else "pending" if pending else "pass" if passed else "none"
    approved = p["reviewDecision"] == "APPROVED"
    plan_ok = statuses.get("atlantis/plan") == "SUCCESS"
    applied = statuses.get("atlantis/apply") == "SUCCESS"

    # What Josh has to do next, if anything.
    if p["state"] != "OPEN":
        action = None
    elif plan_ok and not applied and approved:
        action = "apply"
    elif p["mergeable"] == "CONFLICTING":
        action = "conflicts"
    elif p["isDraft"]:
        # Josh's review once the Copilot/CI loop is done; until then, wait.
        loop_done = ci in ("pass", "none") and copilot != "requested"
        action = "mark ready" if loop_done else None
    elif approved and ci == "pass":
        action = "merge"
    else:
        action = None  # waiting on reviewers, or still in the loop
    return {
        "key": p["url"],
        "repo": p["url"].split("/")[4],
        "number": p["number"],
        "title": p["title"],
        "url": p["url"],
        "state": p["state"],
        "isDraft": p["isDraft"],
        "ci": ci,
        "failed": failed,
        "pending": pending,
        "copilot": copilot,
        "threads": threads,
        "humanThreads": threads - copilot_threads,
        "approved": approved,
        "action": action,
        "base": p.get("baseRefName"),
        "head": p.get("headRefName"),
    }


def here(sid, with_prs=True):
    path = transcript(sid, "")
    if not path:
        return {"prs": [], "tasks": []}
    entries = read_tail(path)
    since = started_at(sid)
    # PR links can be older than the tail, so read them from the whole file.
    urls = []
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            if '"pr-link"' not in line:
                continue
            try:
                e = json.loads(line)
            except ValueError:
                continue
            if e.get("type") == "pr-link" and e.get("prUrl") not in urls:
                urls.append(e["prUrl"])
    prs = []
    if urls and with_prs:
        parts = []
        for i, url in enumerate(urls[:20]):
            owner, repo, _, num = url.split("/")[3:7]
            parts.append(f'p{i}: repository(owner: "{owner}", name: "{repo}") {{ pullRequest(number: {int(num)}) {{ {PR_FIELDS} }} }}')
        out = run(["gh", "api", "graphql", "-f", "query=query {" + "\n".join(parts) + "}"], timeout=30)
        data = json.loads(out).get("data") or {}
        for i in range(len(parts)):
            pr = (data.get(f"p{i}") or {}).get("pullRequest")
            if pr:
                prs.append(pr_status(pr))
    return {"prs": prs, "tasks": background(entries, since), "ticketHint": ticket_hint(entries, prs)}


def ticket_hint(entries, prs):
    """A ticket id from the session's name, else from a linked PR's title."""
    names = [e.get("customTitle") for e in entries if e.get("type") == "custom-title"]
    for text in names[-1:] + [p["title"] for p in prs]:
        m = re.search(r"\b([A-Za-z]{2,6}-\d+)\b", text or "")
        if m:
            return m.group(1).upper()
    return None


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    if mode == "sessions":
        print(json.dumps(sessions()))
    elif mode == "here":
        print(json.dumps(here(sys.argv[2], "--no-prs" not in sys.argv)))
    else:
        print(json.dumps(github()))
