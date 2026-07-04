# Claude Code Cost Status

A single-line status bar for Claude Code showing model, directory, git branch, context window, session cost, and duration.


## What it shows

```
[Opus 4.6] 📁 account | 🌿 master | ▓▓░░░░░░░░ 84% Free | $0.61 | ⏱ 2m 27s
```

## Quick setup
1: Clone this repository to your local machine

2: Navigate to this project

3: chmod 755 status-command.sh

4: chmod 755 setup-status.sh

5: Start claude

```sh
sh setup-status.sh
```

Then restart Claude Code.

## Manual setup

1. Copy the script:

```sh
cp statusline-command.sh ~/.claude/status-command.sh
chmod +x ~/.claude/status-command.sh
```

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/status-command.sh"
  }
}
```

3. Restart Claude Code.

## Requirements

- `jq` (for JSON parsing) — `brew install jq`
- `git` (for branch display)
