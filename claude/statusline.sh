#!/usr/bin/env bash
# Claude Code status line. Reads the session JSON on stdin, prints one line.
# Payload fields used (Claude Code >= 2.1): .model, .workspace, .context_window,
# .cost, .rate_limits. Anything missing is skipped rather than printed empty.
set -uo pipefail

input=$(cat)

branch=$(git -C "$(printf '%s' "$input" | jq -r '.workspace.current_dir // "."')" \
  branch --show-current 2>/dev/null)

printf '%s' "$input" | BRANCH="$branch" jq -r '
  def paint($code): "[" + $code + "m" + . + "[0m";
  def dim:   paint("2");
  def gray:  paint("90");
  def green: paint("32");
  def amber: paint("33");
  def red:   paint("31");
  def bold:  paint("1");

  # 1234 -> 1.2k, 1234567 -> 1.2M
  def human:
    if . >= 1000000 then ((. / 100000 | floor) / 10 | tostring) + "M"
    elif . >= 1000  then ((. / 100    | floor) / 10 | tostring) + "k"
    else (floor | tostring) end;

  def pct: floor | tostring | . + "%";
  def heat($p): if $p >= 85 then red elif $p >= 60 then amber else green end;

  # jq quirk: "x" * 0 is null, not "", so every repeat needs a guard.
  def rep($n): if $n > 0 then . * $n else "" end;

  # $w cells wide, resolved to eighths so small changes still move the bar.
  def bar($p; $w):
    (if $p < 0 then 0 elif $p > 100 then 100 else $p end) as $c
    | ($c / 100 * $w) as $cells
    | ($cells | floor) as $full
    | ((($cells - $full) * 8) | floor) as $part
    | ["", "\u258f", "\u258e", "\u258d", "\u258c", "\u258b", "\u258a", "\u2589"] as $eighths
    | ("\u2588" | rep($full))
      + $eighths[$part]
      + ("\u2591" | rep($w - $full - (if $part > 0 then 1 else 0 end)));

  def gauge($label; $p; $extra):
    $label + " " + bar($p; 8) + " " + ($p | pct) + $extra | heat($p);

  [
    # where
    ((.workspace.current_dir // "") | split("/") | last | select(. != null and . != "") | bold),
    (env.BRANCH | select(. != "") | gray),

    # what
    (.model.display_name | select(. != null) | gray),

    # context window
    (.context_window
      | select(. != null)
      | gauge("ctx";
              (.used_percentage // 0);
              " " + (.total_input_tokens + .total_output_tokens | human)
                + "/" + (.context_window_size | human))),

    # rate limits
    (.rate_limits.five_hour | select(. != null) | gauge("5h"; .used_percentage; "")),
    (.rate_limits.seven_day | select(. != null) | gauge("7d"; .used_percentage; "")),

    # money
    (.cost.total_cost_usd | select(. != null and . > 0)
      | "$" + (. * 100 | round / 100 | tostring) | dim)
  ]
  | join(" " + ("|" | gray) + " ")
'
