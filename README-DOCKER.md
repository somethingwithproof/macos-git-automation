# Docker Testing Guide

This repository includes Docker support for running tests in a containerized environment.

## Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Quick Start

### Run all tests
```bash
docker-compose up test
```

### Run tests with verbose output
```bash
docker-compose up test-verbose
```

### Run shellcheck only
```bash
docker-compose up shellcheck
```

### Run all linters
```bash
docker-compose up lint
```

## Building the Docker Image

```bash
docker build -t git-automator:latest .
```

## Running Tests Manually

```bash
# Run the test container
docker run --rm -v $(pwd):/app git-automator:latest

# Run with custom command
docker run --rm -v $(pwd):/app git-automator:latest ./test-e2e.sh
```

## Important Notes

1. **macOS-Specific Features**: The Docker container runs Ubuntu Linux and can only test:
   - Bash script syntax and logic
   - Shell script linting (shellcheck)
   - YAML validation
   - File structure

2. **Cannot Test in Docker**:
   - AppleScript execution
   - JavaScript for Automation (JXA)
   - Automator workflows
   - macOS-specific features (Finder, notifications, etc.)

3. **Full Testing**: For complete end-to-end testing including macOS-specific features, use:
   - GitHub Actions (includes macOS runners)
   - Jenkins with macOS agents
   - Local macOS machine

## CI/CD Integration

The Docker setup is primarily for:
- Quick local validation
- Cross-platform shell script testing
- Pre-commit checks

For production testing, use the GitHub Actions workflow which includes:
- Multiple macOS versions (12, 13, 14, latest)
- Full feature testing
- Security scanning
