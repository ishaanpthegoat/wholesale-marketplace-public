#!/usr/bin/env bash
#
# Creates the GitHub repo and pushes. Could not run on 2026-08-11 — github.com
# was unreachable from that machine (DNS resolved, TCP 443 timed out). Run this
# once connectivity returns.
#
#   ./scripts/create-github-repo.sh
#
set -euo pipefail

REPO_NAME="wholesale-marketplace-public"
VISIBILITY="public"   # change to "private" before running if you'd rather it not be public
DESCRIPTION="Pallet — a wholesale liquidation marketplace built on one-shot offers."

cd "$(dirname "$0")/.."

echo "Repo:       $REPO_NAME"
echo "Visibility: $VISIBILITY"
echo "Path:       $(pwd)"
echo

if [ "$VISIBILITY" = "public" ]; then
  echo "⚠  This will publish the repository to the public internet."
fi
read -r -p "Create and push? [y/N] " reply
[[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

if ! gh auth status >/dev/null 2>&1; then
  echo "Not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Last check for secrets before anything leaves the machine.
if [ -f .env.local ] && git check-ignore -q .env.local; then
  echo "✓ .env.local is gitignored"
elif [ -f .env.local ]; then
  echo "✗ .env.local exists and is NOT ignored. Stopping." >&2
  exit 1
fi

gh repo create "$REPO_NAME" \
  --"$VISIBILITY" \
  --source=. \
  --remote=origin \
  --description "$DESCRIPTION" \
  --push

echo
echo "Done: $(gh repo view --json url --jq .url)"
