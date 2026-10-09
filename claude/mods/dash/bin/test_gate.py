import unittest

from gate import take


def fresh():
    return {"tripped": None, "events": [], "attempts": []}


class Gate(unittest.TestCase):
    def test_double_click_sends_once(self):
        s = fresh()
        self.assertEqual(take(s, "send", "session-a", 100.0)[0], 0)
        self.assertEqual(take(s, "send", "session-a", 100.2)[0], 1)
        self.assertIsNone(s["tripped"])

    def test_a_loop_retrying_a_refused_call_trips(self):
        s = fresh()
        take(s, "send", "session-a", 100.0)
        codes = [take(s, "send", "session-a", 100.0 + i / 100)[0] for i in range(1, 10)]
        self.assertEqual(codes[-1], 2)
        self.assertIsNotNone(s["tripped"])

    def test_model_burst_trips_within_a_second(self):
        s = fresh()
        self.assertEqual(take(s, "model", "a", 100.0)[0], 0)
        self.assertEqual(take(s, "model", "b", 100.1)[0], 0)
        self.assertEqual(take(s, "model", "c", 100.2)[0], 2)

    def test_trip_is_sticky(self):
        s = fresh()
        for i in range(3):
            take(s, "model", str(i), 100.0)
        self.assertEqual(take(s, "model", "later", 10_000.0)[0], 2)

    def test_steady_pace_never_trips(self):
        s = fresh()
        for i in range(19):
            self.assertEqual(take(s, "model", str(i), 100.0 + i * 3)[0], 0)
        self.assertIsNone(s["tripped"])


if __name__ == "__main__":
    unittest.main()


class EveryPathIsGated(unittest.TestCase):
    """The breaker only works if nothing can reach the model or a session
    without passing it. This fails if a new call site skips the gate."""

    def setUp(self):
        import os
        here = os.path.dirname(os.path.abspath(__file__))
        self.src = open(os.path.join(here, "..", "hooks", "register.tsx")).read()

    def gated_once(self, call, gate):
        self.assertEqual(self.src.count(call), 1, f"{call} must appear exactly once")
        before = self.src[: self.src.index(call)]
        fn = before[before.rindex("\nasync function ") :]
        self.assertIn(gate, fn, f"{call} must come after {gate} in the same function")

    def test_model_calls(self):
        self.gated_once("$.model.complete(", "await gate($, 'model'")

    def test_sends(self):
        self.gated_once("['cmux', 'send',", "await gate($, 'send'")
        self.assertEqual(self.src.count("'send-key'"), 1)


class ServerPathsAreGated(unittest.TestCase):
    def read(self, name):
        import os
        return open(os.path.join(os.path.dirname(os.path.abspath(__file__)), name)).read()

    def test_server_acts_only_through_actions(self):
        src = self.read("server.py")
        for forbidden in ('"cmux"', "'cmux'", '"gh"', "subprocess", "model"):
            if forbidden == "model":
                self.assertNotIn("claude", src.replace("~/.claude", ""), "the server must not call a model")
                continue
            self.assertNotIn(forbidden, src, f"server.py must not use {forbidden}; go through actions.py")

    def test_every_act_takes_the_gate_first(self):
        src = self.read("actions.py")
        for call in ('"send", "--surface"', '"gh", "pr", "ready"', '"gh", "pr", "edit"'):
            self.assertEqual(src.count(call), 1)
            before = src[: src.index(call)]
            fn = before[before.rindex("\ndef ") :]
            self.assertIn("take_locked(", fn, f"{call} must follow take_locked in its function")
