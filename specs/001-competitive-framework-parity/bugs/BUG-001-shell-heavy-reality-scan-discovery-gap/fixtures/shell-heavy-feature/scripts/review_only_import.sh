#!/usr/bin/env bash
set -euo pipefail

manifest_path="release/release-manifest.json"
registry_path="config/interop-registry.yaml"

printf 'review-only import uses %s and %s\n' "$manifest_path" "$registry_path"