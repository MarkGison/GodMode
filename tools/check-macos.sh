#!/bin/bash
# Compatibility entry point for automated macOS runners.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 tools/ci.py --suite full --package none
