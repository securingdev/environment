#!/bin/bash
set -euo pipefail

json=$(cat)

# ── Constants ──────────────────────────────────────
# ANSI escape codes for status line coloring.
GREY="\033[38;5;242m"   # neutral mid-gray
GREEN="\033[38;5;148m"  # Molokai #A6E22E — vivid yellow-green
RED="\033[38;5;197m"    # Molokai #F92672 — hot pink
MAGENTA="\033[38;5;141m" # Molokai #AE81FF — purple/magenta
ORANGE="\033[38;5;208m"  # Molokai #FD971F — orange
WHITE="\033[38;5;255m"   # Molokai #F8F8F2 — near-white foreground
YELLOW="\033[38;5;185m"  # Molokai #E6DB74 — muted yellow
RESET="\033[0m"

# ── Session info ───────────────────────────────────
# Extract model, cost, and line counts from the JSON
# status payload provided on stdin.
if command -v jq &> /dev/null; then
    model_name=$(echo "$json" | jq -r '.model.display_name // "Unknown Model"')
    cost=$(echo "$json" | jq -r '.cost.total_cost_usd // 0' | xargs printf "%.3f")
    lines_added=$(echo "$json" | jq -r '.cost.total_lines_added // 0')
    lines_removed=$(echo "$json" | jq -r '.cost.total_lines_removed // 0')
    current_dir=$(echo "$json" | jq -r '.workspace.current_dir // "unknown"')
else
    model_name=$(echo "$json" | grep -o '"display_name":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "Unknown Model")
    cost=$(echo "$json" | grep -o '"total_cost_usd":[0-9.]*' | cut -d: -f2 | xargs printf "%.3f" 2>/dev/null || echo "0")
    lines_added=$(echo "$json" | grep -o '"total_lines_added":[0-9]*' | cut -d: -f2 || echo "0")
    lines_removed=$(echo "$json" | grep -o '"total_lines_removed":[0-9]*' | cut -d: -f2 || echo "0")
    current_dir=$(echo "$json" | grep -o '"current_dir":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
fi

# ── Repository context ─────────────────────────────
# Derive branch name and a human-friendly display
# path from git metadata.
git_branch=$(git branch --show-current 2>/dev/null || echo "no-git")
git_root=$(git rev-parse --show-toplevel 2>/dev/null || true)

if [ -n "$git_root" ] && [ "$current_dir" = "$git_root" ]; then
    repo_path_display="[$(basename "$git_root")]"
elif [ -n "$git_root" ]; then
    repo_path_display="[$(basename "$git_root")]/${current_dir#"$git_root"/}"
else
    repo_path_display="$(basename "$current_dir")"
fi

# ── Effort level ──────────────────────────────────
# Try JSON payload first, fall back to settings.json.
if command -v jq &> /dev/null; then
    effort=$(echo "$json" | jq -r '.effortLevel // empty' 2>/dev/null || true)
    if [ -z "$effort" ]; then
        effort=$(jq -r '.effortLevel // "high"' ~/.claude/settings.json 2>/dev/null || echo "high")
    fi
else
    effort="high"
fi

# Gradient: max=white, high=orange, medium=yellow, low=grey
case "$effort" in
    max)    EFFORT_COLOR="$WHITE";  effort_label="Max"    ;;
    high)   EFFORT_COLOR="$ORANGE"; effort_label="High"   ;;
    medium) EFFORT_COLOR="$YELLOW"; effort_label="Medium" ;;
    low)    EFFORT_COLOR="$GREY";   effort_label="Low"    ;;
    *)      EFFORT_COLOR="$GREY";   effort_label="$effort" ;;
esac

# ── Output ─────────────────────────────────────────
# Pick model highlight color: Sonnet=green, Opus=magenta, other=grey
if echo "$model_name" | grep -qi "opus"; then
    MODEL_COLOR="$MAGENTA"
elif echo "$model_name" | grep -qi "sonnet"; then
    MODEL_COLOR="$ORANGE"
else
    MODEL_COLOR="$GREY"
fi

# Format: [Model $cost] [repo]/path (branch) +added/-removed
printf "${GREY}[${MODEL_COLOR}${model_name}${GREY} · ${EFFORT_COLOR}${effort_label}${GREY} · ${WHITE}\$${cost}${GREY}] ${repo_path_display} (${git_branch}) ${GREEN}+${lines_added}${GREY}/${RED}-${lines_removed}${RESET}"
