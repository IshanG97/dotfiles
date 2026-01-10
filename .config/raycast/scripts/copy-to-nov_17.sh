#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Copy to to_share/nov_17
# @raycast.mode silent
# @raycast.packageName File Utils
# @raycast.description Copy Finder selection (or front Preview doc) to ~/Downloads/to_share/nov_17 with auto-rename.

set -euo pipefail

DEST="$HOME/Downloads/to_share/nov_17"
mkdir -p "$DEST"

copy_with_rename() {
  local src="$1"
  local base name ext target i

  base="$(basename "$src")"
  name="${base%.*}"
  ext="${base##*.}"
  if [ "$name" = "$ext" ]; then ext=""; fi

  target="$DEST/$base"
  i=1
  while [ -e "$target" ]; do
    if [ -n "$ext" ]; then
      target="$DEST/$name ($i).$ext"
    else
      target="$DEST/$name ($i)"
    fi
    i=$((i+1))
  done

  ditto "$src" "$target"
}

finder_paths="$(osascript <<'APPLESCRIPT'
tell application "Finder"
  set sel to selection
  if sel is {} then return ""
  set txt to ""
  repeat with f in sel
    try
      set txt to txt & (POSIX path of (f as alias)) & linefeed
    end try
  end repeat
  return txt
end tell
APPLESCRIPT
)"

copied=0

if [ -n "$finder_paths" ]; then
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    if [ -e "$p" ]; then
      copy_with_rename "$p"
      copied=$((copied+1))
    fi
  done <<< "$finder_paths"
else
  preview_path="$(osascript <<'APPLESCRIPT'
tell application "Preview"
  if not (exists front document) then return ""
  try
    return POSIX path of (path of front document)
  on error
    return ""
  end try
end tell
APPLESCRIPT
)"
  if [ -n "$preview_path" ] && [ -e "$preview_path" ]; then
    copy_with_rename "$preview_path"
    copied=1
  else
    osascript -e 'display notification "No Finder selection or Preview document found." with title "Copy to nov_17"'
    exit 0
  fi
fi

open "$DEST"
osascript -e "display notification \"Copied: $copied → ~/Downloads/to_share/nov_16\" with title \"Copy to nov_17\""