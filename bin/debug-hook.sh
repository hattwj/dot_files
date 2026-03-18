#!/bin/bash
# debug-hook.sh - Debug hook using nvim-mcp-bridge hook mode

LOG="/tmp/wasabi-hook-debug.log"

{
  echo "=== Hook Run: $(date) ==="
  echo "NVIM_PARENT_PID: ${NVIM_PARENT_PID:-not set}"
  echo "WASABI_TOOL_NAME: ${WASABI_TOOL_NAME:-not set}"
  echo ""

  # Get filepath from hook input
  FILEPATH=""
  if [ -f "${WASABI_HOOK_INPUT_FILE:-}" ]; then
    FILEPATH=$(cat "$WASABI_HOOK_INPUT_FILE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('filepath',''))" 2>/dev/null)
  fi
  echo "Filepath: $FILEPATH"
  echo ""

  # Test nvim-mcp-bridge hook mode
  BRIDGE="$HOME/dddot_files/vendor/dot_files/bin/nvim-mcp-bridge"
  echo "Testing nvim-mcp-bridge --hook lsp_diagnostics..."

  if [ -n "$FILEPATH" ]; then
    timeout 4 "$BRIDGE" --hook lsp_diagnostics --file "$FILEPATH" 2>&1
    echo "Exit code: $?"
  else
    echo "No filepath, skipping"
  fi

  echo ""
  echo "=== End ==="
} >> "$LOG" 2>&1

# Output for hook feedback
echo "## Hook Debug"
echo "See: /tmp/wasabi-hook-debug.log"
tail -15 "$LOG"

exit 0
