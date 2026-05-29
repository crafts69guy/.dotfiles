#!/bin/bash
input=$(cat)

# ── helpers ──────────────────────────────────────────────────────────────────
rgb()  { printf "\033[38;2;%d;%d;%dm" "$1" "$2" "$3"; }
bold() { printf "\033[1m"; }
dim()  { printf "\033[2m"; }
rst()  { printf "\033[0m"; }
PIPE="$(dim)$(rgb 90 90 90)|$(rst)"

# ── data from JSON ────────────────────────────────────────────────────────────
dir=$(echo "$input"   | jq -r '.workspace.current_dir // empty')
[ -z "$dir" ] && dir=$(pwd)

repo_name=$(echo "$input" | jq -r '.workspace.repo.name // empty')
[ -z "$repo_name" ] && repo_name=$(basename "$dir")

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

used_raw=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
used=0
[ -n "$used_raw" ] && used=$(printf "%.0f" "$used_raw")

# session cost — total_input_tokens + total_output_tokens as a rough proxy,
# displayed as token-thousands (no $ billing available in the JSON)
total_in=$(echo "$input"  | jq -r '.context_window.total_input_tokens  // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
total_tokens=$(( total_in + total_out ))
# format: show as k with one decimal if >= 1000
if [ "$total_tokens" -ge 1000 ]; then
  cost_str=$(awk "BEGIN{printf \"%.1fk\", $total_tokens/1000}")
else
  cost_str="${total_tokens}"
fi

# code velocity via git diff --stat on HEAD (lines added / removed since last commit)
vel_add=0; vel_del=0
if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
  stat=$(git -C "$dir" diff --no-lock-index --shortstat HEAD 2>/dev/null)
  if [ -n "$stat" ]; then
    vel_add=$(echo "$stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
    vel_del=$(echo "$stat" | grep -oE '[0-9]+ deletion'  | grep -oE '[0-9]+' || echo 0)
    [ -z "$vel_add" ] && vel_add=0
    [ -z "$vel_del" ] && vel_del=0
  fi
fi

# ── 1. Repo name — bold yellow ────────────────────────────────────────────────
printf "%s%s%s%s" "$(bold)" "$(rgb 255 210 0)" "$repo_name" "$(rst)"

# ── 2. Git branch — bold cyan in parens ──────────────────────────────────────
if [ -n "$branch" ]; then
  printf " %s" "$PIPE"
  printf " 🌿%s%s(%s)%s" "$(bold)" "$(rgb 0 220 220)" "$branch" "$(rst)"
fi

# ── 3. Context bar (20 blocks, 24-bit RGB gradient) + dynamic emoji + % ───────
printf " %s" "$PIPE"
filled=$(( used * 20 / 100 ))
[ "$filled" -gt 20 ] && filled=20
empty=$(( 20 - filled ))

# pick emoji and percentage color by usage level
if [ "$used" -lt 20 ]; then
  emoji="🟢"; pct_r=0;   pct_g=220; pct_b=80
elif [ "$used" -lt 70 ]; then
  emoji="⚡"; pct_r=220; pct_g=200; pct_b=0
elif [ "$used" -lt 90 ]; then
  emoji="🔥"; pct_r=220; pct_g=100; pct_b=0
else
  emoji="🚨"; pct_r=220; pct_g=40;  pct_b=20
fi

printf " "
# filled blocks with gradient green→yellow→red
i=0
while [ "$i" -lt "$filled" ]; do
  # interpolate: 0→green(0,200,80) 10→yellow(220,200,0) 20→red(220,40,20)
  if [ "$i" -le 10 ]; then
    r=$(( 0   + i * 22 ))
    g=$(( 200 ))
    b=$(( 80  - i * 8 ))
  else
    step=$(( i - 10 ))
    r=220
    g=$(( 200 - step * 16 ))
    b=$(( 0   + step * 2  ))
  fi
  [ "$g" -lt 0 ] && g=0
  [ "$b" -lt 0 ] && b=0
  printf "%s█" "$(rgb $r $g $b)"
  i=$(( i + 1 ))
done
# empty blocks — dark gray
if [ "$empty" -gt 0 ]; then
  printf "%s" "$(rgb 60 60 60)"
  e=0
  while [ "$e" -lt "$empty" ]; do
    printf "█"
    e=$(( e + 1 ))
  done
fi
printf "$(rst)"

# emoji + percentage
printf " %s %s%s%s%d%%%s" \
  "$emoji" \
  "$(rgb $pct_r $pct_g $pct_b)" "$(bold)" \
  "" "$used" "$(rst)"

# ── 4. Session tokens (yellow) ────────────────────────────────────────────────
printf " %s" "$PIPE"
printf " %s%s~%s tok%s" "$(rgb 255 210 0)" "$(bold)" "$cost_str" "$(rst)"

# ── 5. Code velocity ──────────────────────────────────────────────────────────
if [ "$vel_add" -gt 0 ] || [ "$vel_del" -gt 0 ]; then
  printf " %s" "$PIPE"
  printf " %s%s+%s%s" "$(rgb 0 220 80)"  "$(bold)" "$vel_add" "$(rst)"
  printf "%s%s-%s%s"  "$(rgb 220 60 40)" "$(bold)" "$vel_del" "$(rst)"
fi

# ── 6. Model name — magenta with cowboy ──────────────────────────────────────
printf " %s" "$PIPE"
printf " 🤠%s%s%s%s" "$(rgb 200 80 220)" "$(bold)" "$model" "$(rst)"

printf "\n"
