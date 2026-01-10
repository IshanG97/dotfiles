#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy to to_share/nov_14
# @raycast.mode silent
# @raycast.packageName File Utils
# @raycast.description Copy Finder selection (or front Preview doc) to ~/Downloads/to_share/nov_14 with auto-rename.

set -euo pipefail

DEST="$HOME/Downloads/to_share/nov_14"
mkdir -p "$DEST"

# --- Helpers ---

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

  # ditto is robust on macOS (metadata, packages, etc.)
  ditto "$src" "$target"
}

get_finder_selection() {
  osascript <<'APPLESCRIPT'
tell application "Finder"
  set sel to selection
  if sel is {} then return ""
  set out to {}
  repeat with f in sel
    try
      set end of out to POSIX path of (f as alias)
    end try
  end repeat
  return out as string
end tell
APPLESCRIPT
}

get_preview_front_doc() {
  osascript <<'APPLESCRIPT'
tell application "Preview"
  if not (exists front document) then return ""
  try
    set p to (path of front document)
    if p is missing value then return ""
    return POSIX path of p
  on error
    return ""
  end try
end tell
APPLESCRIPT
}

# --- Main ---

# Finder selection comes back as a comma-separated AppleScript string; we’ll parse safely by re-querying as list via shell.
# Easiest: ask AppleScript to return one path per line instead.
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

if [ -n "${finder_paths}" ]; then
  # Read newline-separated paths
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    if [ -e "$p" ]; then
      copy_with_rename "$p"
      copied=$((copied+1))
    fi
  done <<< "$finder_paths"
else
  # Fallback: front Preview document
  preview_path="$(get_preview_front_doc)"
  if [ -n "${preview_path}" ] && [ -e "${preview_path}" ]; then
    copy_with_rename "$preview_path"
    copied=$((copied+1))
  else
    osascript -e 'display notification "No Finder selection, and no Preview document path found." with title "Copy to nov_14"'
    exit 0
  fi
fi

open "$DEST"
osascript -e "display notification \"Copied: $copied → ~/Downloads/to_share/nov_14\" with title \"Copy to nov_14\""