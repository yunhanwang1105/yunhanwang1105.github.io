#!/usr/bin/env bash
# Local dev server for this Jekyll site on macOS.
#
# Why this script exists (avoid re-debugging):
#   1. `jekyll serve` uses WEBrick, which on recent macOS + Ruby 3.3
#      fails with `Errno::EPERM: Operation not permitted - sendfile`
#      when streaming binary files (images). => images appear broken.
#      Fix: build with Jekyll, serve static files via Python.
#   2. The Primer theme's SCSS contains non-ASCII characters. Without
#      a UTF-8 locale, Sass raises `Invalid US-ASCII character "\xE2"`.
#      Fix: export LANG/LC_ALL=en_US.UTF-8.
#   3. macOS FSEvents sometimes fails to deliver change notifications
#      here, so `jekyll build --watch` silently stops rebuilding.
#      Fix: use `--force_polling`.
#
# Usage:
#   ./scripts/serve.sh                 # default port 4000
#   ./scripts/serve.sh 4001            # custom port
#
# Then open: http://127.0.0.1:<port>/
# Stop with Ctrl+C. Hard-reload the page (Cmd+Shift+R) after edits.

set -euo pipefail

PORT="${1:-4000}"
HOST="127.0.0.1"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

BUILD_PID=""
SERVE_PID=""

cleanup() {
    echo ""
    echo "Stopping dev server..."
    [[ -n "$BUILD_PID" ]] && kill "$BUILD_PID" 2>/dev/null || true
    [[ -n "$SERVE_PID" ]] && kill "$SERVE_PID" 2>/dev/null || true
    wait 2>/dev/null || true
    echo "Stopped."
}
trap cleanup EXIT INT TERM

if lsof -i ":$PORT" -t >/dev/null 2>&1; then
    echo "Error: port $PORT is already in use." >&2
    echo "       Kill it with: lsof -i :$PORT -t | xargs kill -9" >&2
    exit 1
fi

echo "==> Building site..."
bundle exec jekyll build

echo "==> Starting file watcher (polling)..."
bundle exec jekyll build --watch --force_polling >/dev/null 2>&1 &
BUILD_PID=$!

echo "==> Serving _site/ at http://$HOST:$PORT/"
echo "    (Ctrl+C to stop; Cmd+Shift+R to hard-reload the browser after edits)"
echo ""
cd "$ROOT/_site"
python3 -m http.server "$PORT" --bind "$HOST" &
SERVE_PID=$!

wait "$SERVE_PID"
