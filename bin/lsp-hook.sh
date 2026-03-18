#!/bin/bash
# lsp-hook.sh - Wasabi hook to provide LSP diagnostics after file operations
# Trigger: postToolUse
# Matcher: WriteFile, GetFiles

# Get filepath(s) from hook input - handles both WriteFile and GetFiles
FILEPATHS=""

DEBUG_LOG="/tmp/lsp-hook-debug.log"
echo "=== $(date) ===" >> "$DEBUG_LOG"

echo "WASABI_HOOK_INPUT_FILE: ${WASABI_HOOK_INPUT_FILE:-unset}" >> "$DEBUG_LOG"

if [ -f "${WASABI_HOOK_INPUT_FILE:-}" ]; then
  # Dump input file content for debugging
  echo "Input content:" >> "$DEBUG_LOG"
  cat "$WASABI_HOOK_INPUT_FILE" >> "$DEBUG_LOG" 2>&1
  # Try WriteFile format (single filepath), then GetFiles format (array of filepaths)
  FILEPATHS=$(python3 -c "
import sys, json
d = json.load(sys.stdin)
tool_input = d.get('tool_input', {})
# WriteFile: single filepath in tool_input
fp = tool_input.get('filepath', '')
if fp:
    print(fp)
else:
    # GetFiles: array of filepaths in tool_input
    fps = tool_input.get('filepaths', [])
    # Limit to first 3 files to avoid too much output
    for f in fps[:3]:
        print(f)
" < "$WASABI_HOOK_INPUT_FILE" 2>/dev/null)
else
  echo "Input file not found or not set" >> "$DEBUG_LOG"
fi

echo "FILEPATHS: $FILEPATHS" >> "$DEBUG_LOG"

# Skip if no filepaths
if [ -z "$FILEPATHS" ]; then
  echo "Skipping: no filepaths" >> "$DEBUG_LOG"
  exit 0
fi

# Function to check if file should be skipped (blocklist)
should_skip() {
  case "$1" in
    # Binary/compiled files
    *.png|*.jpg|*.jpeg|*.gif|*.ico|*.webp|*.svg|*.bmp|*.tiff) return 0 ;;
    *.pdf|*.doc|*.docx|*.xls|*.xlsx|*.ppt|*.pptx) return 0 ;;
    *.zip|*.tar|*.gz|*.bz2|*.xz|*.7z|*.rar) return 0 ;;
    *.exe|*.dll|*.so|*.dylib|*.a|*.o|*.class|*.pyc|*.pyo) return 0 ;;
    *.woff|*.woff2|*.ttf|*.eot|*.otf) return 0 ;;
    *.mp3|*.mp4|*.wav|*.avi|*.mov|*.mkv|*.webm) return 0 ;;
    # Lock files and generated
    *.lock|*-lock.json) return 0 ;;
    # Minified/bundled files
    *.min.js|*.min.css|*.bundle.js|*.bundle.css) return 0 ;;
    # Data files (usually large)
    *.csv|*.parquet|*.avro) return 0 ;;
    # Documentation (no LSP benefit)
    *.md|*.txt|*.log|*.rst) return 0 ;;
    *) return 1 ;;
  esac
}

# Process each filepath
BRIDGE="${HOME}/dddot_files/vendor/dot_files/bin/nvim-mcp-bridge"
if [ ! -x "$BRIDGE" ]; then
  exit 0
fi

# Process each filepath (use here-string to avoid subshell from pipe)
while IFS= read -r filepath; do
  [ -z "$filepath" ] && continue
  if should_skip "$filepath"; then
    echo "Skipping blocklisted: $filepath" >> "$DEBUG_LOG"
    continue
  fi

  echo "Processing: $filepath" >> "$DEBUG_LOG"
  # Get diagnostics for this file
  OUTPUT=$("$BRIDGE" --hook lsp_diagnostics --file "$filepath" 2>/dev/null)
  echo "Bridge output: $OUTPUT" >> "$DEBUG_LOG"
  if [ -n "$OUTPUT" ]; then
    echo "$OUTPUT"
  fi
done <<< "$FILEPATHS"

exit 0
