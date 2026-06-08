#!/usr/bin/env bash
#
# Convenience launcher for local development.
#
#   ./run.sh            -> runs the app in Chrome (web)
#   ./run.sh chrome     -> same as above, explicit
#   ./run.sh macos      -> runs the macOS desktop build
#   ./run.sh <deviceId> -> runs on a specific device (see: flutter devices)
#
# Flutter is invoked by absolute path because it is not on the global PATH.

set -euo pipefail

FLUTTER="$HOME/development/flutter/bin/flutter"
DEVICE="${1:-chrome}"

if [[ ! -x "$FLUTTER" ]]; then
  echo "Flutter not found at $FLUTTER" >&2
  echo "Edit the FLUTTER path in run.sh to point at your Flutter install." >&2
  exit 1
fi

echo "Fetching dependencies..."
"$FLUTTER" pub get

echo "Launching on: $DEVICE"
exec "$FLUTTER" run -d "$DEVICE"
