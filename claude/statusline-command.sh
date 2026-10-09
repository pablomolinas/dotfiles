#!/bin/bash
input=$(cat)

IFS=$'\t' read -r MODEL DIR DIRNAME SESSION_ID PCT < <(node -e '
let s = "";
process.stdin.on("data", d => s += d);
process.stdin.on("end", () => {
  const j = JSON.parse(s);
  const model = (j.model && j.model.display_name) || "";
  const dir = (j.workspace && j.workspace.current_dir) || j.cwd || "";
  const sid = j.session_id || "";
  let pct = 0;
  try {
    if (j.transcript_path) {
      const fs = require("fs");
      const lines = fs.readFileSync(j.transcript_path, "utf8").trim().split("\n");
      for (let i = lines.length - 1; i >= 0; i--) {
        try {
          const e = JSON.parse(lines[i]);
          const u = e && e.message && e.message.usage;
          if (u) {
            const tot = (u.input_tokens || 0) + (u.cache_read_input_tokens || 0) + (u.cache_creation_input_tokens || 0);
            pct = Math.round((tot / 200000) * 100);
            break;
          }
        } catch {}
      }
    }
  } catch {}
  const basename = dir.replace(/[/\\]+$/, "").replace(/.*[/\\]/, "");
  process.stdout.write([model, dir, basename, sid, pct].join("\t"));
});
' <<< "$input")

CACHE_FILE="/tmp/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
    if (cd "$DIR" 2>/dev/null && git rev-parse --git-dir > /dev/null 2>&1); then
        BRANCH=$(cd "$DIR" && git branch --show-current 2>/dev/null)
        STAGED=$(cd "$DIR" && git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(cd "$DIR" && git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
    else
        echo "||" > "$CACHE_FILE"
    fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

if [ -n "$BRANCH" ]; then
    printf "[$MODEL] 📁 $DIRNAME | ctx $PCT%% | 🌿 $BRANCH +$STAGED ~$MODIFIED\n"
else
    echo "[$MODEL] 📁 $DIRNAME | ctx $PCT%"
fi
