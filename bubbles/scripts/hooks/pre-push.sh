#!/usr/bin/env bash
#
# Bubbles source-repo pre-push hook (v5.0.1).
#
# Installed by `bash bubbles/scripts/install-bubbles-hooks.sh` for
# framework maintainers. Runs framework-validate + release-check
# before any push to origin. NO bypass flags.
#
# This is the framework eating its own dog food: the framework's
# release process refuses pushes that would ship framework drift.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/bubbles/scripts"

echo "🫧 bubbles pre-push: running framework validation..."

if [[ ! -x "$SCRIPT_DIR/framework-validate.sh" ]]; then
  echo "⚠️  framework-validate.sh not found or not executable; skipping"
  exit 0
fi

if ! bash "$SCRIPT_DIR/framework-validate.sh" >/tmp/bubbles-pre-push-validate.log 2>&1; then
  echo "❌ framework-validate failed. Full log: /tmp/bubbles-pre-push-validate.log"
  echo "    Tail:"
  tail -30 /tmp/bubbles-pre-push-validate.log | sed 's/^/      /'
  echo ""
  echo "    Fix the failures and retry the push. There is no bypass."
  exit 1
fi
echo "✅ framework-validate passed"

if [[ -x "$SCRIPT_DIR/release-check.sh" ]]; then
  echo "🫧 bubbles pre-push: running release-check..."
  if ! bash "$SCRIPT_DIR/release-check.sh" >/tmp/bubbles-pre-push-release.log 2>&1; then
    echo "❌ release-check failed. Full log: /tmp/bubbles-pre-push-release.log"
    echo "    Tail:"
    tail -30 /tmp/bubbles-pre-push-release.log | sed 's/^/      /'
    echo ""
    echo "    Fix the failures and retry the push. There is no bypass."
    exit 1
  fi
  echo "✅ release-check passed"
fi

exit 0
