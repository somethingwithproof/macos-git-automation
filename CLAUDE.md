# CLAUDE.md

macOS scripts for cloning Git repos from clipboard with Automator integration.

## Stack
- Bash
- AppleScript
- JavaScript for Automation (JXA)

## Lint & Test
```bash
# Shell validation
./test.sh

# Shellcheck
shellcheck dist/*.sh

# AppleScript compilation
osacompile -o /tmp/test.scpt dist/GitCloneFromClipboard.applescript

# E2E tests
./test-e2e.sh
```

## Docker Test
```bash
docker-compose up test
```
