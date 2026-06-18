#!/usr/bin/env bash
# Re-apply the permissionChannel patch to the installed discord channel plugin.
# The official `discord@claude-plugins-official` plugin doesn't accept this as an
# upstream PR (repo is Anthropic-team-only), and plugin updates overwrite the
# cache — so run this after any discord-plugin update to restore the feature.
#
# It copies the patched server.ts from this fork into whatever version of the
# discord plugin cache is currently installed. Idempotent.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/external_plugins/discord/server.ts"
CACHE_ROOT="$HOME/.claude/plugins/cache/claude-plugins-official/discord"

[ -f "$SRC" ] || { echo "patched source not found: $SRC" >&2; exit 1; }
[ -d "$CACHE_ROOT" ] || { echo "discord plugin not installed at $CACHE_ROOT" >&2; exit 1; }

applied=0
for dir in "$CACHE_ROOT"/*/; do
  dst="$dir/server.ts"
  [ -f "$dst" ] || continue
  if grep -q "permissionChannel" "$dst"; then
    echo "already patched: $dst"
  else
    cp "$SRC" "$dst"
    echo "patched: $dst"
  fi
  applied=1
done
[ "$applied" = 1 ] || { echo "no server.ts found under $CACHE_ROOT/*/" >&2; exit 1; }
echo "Done. Restart Claude Code with --channels for it to take effect."
