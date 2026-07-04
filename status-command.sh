#!/bin/sh
# Automated setup for Claude Code custom status line
# Usage: sh setup-status.sh

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_NAME="status-command.sh"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$CLAUDE_DIR/$SCRIPT_NAME"
SETTINGS="$CLAUDE_DIR/settings.json"

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Copy the statusline script
cp "$SOURCE_DIR/$SCRIPT_NAME" "$DEST"
chmod +x "$DEST"
echo "Copied $SCRIPT_NAME to $DEST"

# Update settings.json with statusLine config
if [ -f "$SETTINGS" ]; then
  # Check if jq is available
  if ! command -v jq >/dev/null 2>&1; then
    echo ""
    echo "jq is required but not installed. Install it with: brew install jq"
    echo ""
    echo "Then manually add this to $SETTINGS:"
    echo '  "statusLine": { "type": "command", "command": "bash '"$DEST"'" }'
    exit 1
  fi

  # Add or update statusLine in existing settings
  tmp=$(mktemp)
  jq --arg cmd "bash $DEST" '.statusLine = { "type": "command", "command": $cmd }' "$SETTINGS" > "$tmp"
  mv "$tmp" "$SETTINGS"
  echo "Updated statusLine in $SETTINGS"
else
  # Create new settings.json with statusLine
  cat > "$SETTINGS" <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "bash $DEST"
  }
}
EOF
  echo "Created $SETTINGS with statusLine config"
fi

echo ""
echo "Done! Restart Claude Code to see the new status line:"
echo "  [Opus 4.6] 📁 my-app | 🌿 main | ▓▓░░░░░░░░ 84% Free | \$0.61 | ⏱ 2m 27s"
