#!/bin/sh
# Claude Code status line — single line with model, dir, branch, context bar, cost, duration
# Setup: Run ../setup-statusline.sh or follow instructions in README.md

input=$(cat)

# Parse fields
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // 0')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Format cost to 2 decimal places
cost_fmt=$(printf "%.2f" "$cost")

# Format duration (ms -> Xm Ys)
duration_sec=$((duration_ms / 1000))
dur_min=$((duration_sec / 60))
dur_sec=$((duration_sec % 60))
if [ "$dur_min" -gt 0 ]; then
  duration_str="${dur_min}m ${dur_sec}s"
else
  duration_str="${dur_sec}s"
fi

# Git branch
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree --no-optional-locks >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Build context bar (10 chars wide)
used=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
bar_width=10
filled=$((used * bar_width / 100))
empty=$((bar_width - filled))
bar_filled=""
bar_empty=""
i=0; while [ "$i" -lt "$filled" ]; do bar_filled="${bar_filled}▓"; i=$((i + 1)); done
i=0; while [ "$i" -lt "$empty" ]; do bar_empty="${bar_empty}░"; i=$((i + 1)); done

# Colors
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
WHITE="\033[1;37m"
RESET="\033[0m"
DIM="\033[2m"

# Single line: [Model] 📁 dir | 🌿 branch | [bar] XX% Free | $X.XX | ⏱ Xm Ys
output=$(printf "${CYAN}[%s]${RESET} 📁 ${WHITE}%s${RESET}" "$model" "$dir")

if [ -n "$branch" ]; then
  output=$(printf "%s ${DIM}|${RESET} 🌿 ${WHITE}%s${RESET}" "$output" "$branch")
fi

output=$(printf "%s ${DIM}|${RESET} ${GREEN}%s${RESET}${DIM}%s${RESET} ${GREEN}%s%% Free${RESET} ${DIM}|${RESET} ${YELLOW}\$%s${RESET} ${DIM}|${RESET} ⏱  %s" \
  "$output" "$bar_filled" "$bar_empty" "$remaining" "$cost_fmt" "$duration_str")

printf "%s" "$output"
