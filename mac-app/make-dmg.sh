#!/bin/bash
# Build Undiscord.app and package it into a distributable Undiscord.dmg.
set -euo pipefail
cd "$(dirname "$0")"

./bundle.sh

APP="Undiscord.app"
DMG="Undiscord.dmg"
STAGE="dmg-stage"

echo "==> Packaging ${DMG} ..."
rm -rf "${STAGE}" "${DMG}"
mkdir -p "${STAGE}"
cp -R "${APP}" "${STAGE}/"
ln -s /Applications "${STAGE}/Applications"   # drag-to-install target

hdiutil create -volname "Undiscord" -srcfolder "${STAGE}" -ov -format UDZO "${DMG}" >/dev/null
rm -rf "${STAGE}"
echo "==> Done: $(pwd)/${DMG}"
