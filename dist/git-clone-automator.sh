#!/bin/bash
#
# Git Clone Automator - Bash Script
#
# Clones a Git repository from a URL in the clipboard to a local directory
#
# Usage: ./git-clone-automator.sh [target_directory]
#

set -euo pipefail

# Set colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # No Color

# Default target directory
readonly DEFAULT_TARGET_DIR="${HOME}/Documents"

# Function to display error messages
error() {
  echo -e "${RED}Error: $1${NC}" >&2
  osascript -e "display notification \"$1\" with title \"Git Clone Error\" sound name \"Basso\"" 2>/dev/null || true
  exit 1
}

# Function to display success messages
success() {
  echo -e "${GREEN}$1${NC}"
  osascript -e "display notification \"$1\" with title \"Git Clone Success\" sound name \"Glass\"" 2>/dev/null || true
}

# Function to display info messages
info() {
  echo -e "${YELLOW}$1${NC}"
}

# Check if GitHub CLI is installed
check_gh_cli() {
  if ! command -v gh >/dev/null 2>&1; then
    error "GitHub CLI (gh) is not installed. Please install it first:\nbrew install gh"
  fi

  # Check if authenticated
  if ! gh auth status >/dev/null 2>&1; then
    error "GitHub CLI is not authenticated. Please run: gh auth login"
  fi
}

# Validate Git URL
validate_git_url() {
  local url="$1"

  # Check for common Git URL patterns
  if [[ "$url" =~ ^https?://github\.com/[^/]+/[^/]+/?$ ]] || \
     [[ "$url" =~ ^git@github\.com:[^/]+/[^/]+\.git$ ]] || \
     [[ "$url" =~ ^https?://[^/]+/[^/]+/[^/]+/?$ ]] || \
     [[ "$url" =~ ^git@[^:]+:[^/]+/[^/]+\.git$ ]]; then
    return 0
  fi

  return 1
}

# Extract repository name from URL
extract_repo_name() {
  local url="$1"
  local repo_name

  # Remove trailing slash
  url="${url%/}"

  # Remove .git extension
  url="${url%.git}"

  # Extract the last part of the URL (repository name)
  repo_name=$(basename "$url")

  echo "$repo_name"
}

# Clone repository
clone_repository() {
  local url="$1"
  local target_dir="$2"
  local repo_name="$3"
  local full_path="${target_dir}/${repo_name}"

  info "Cloning repository: $repo_name"
  info "Target directory: $full_path"

  # Check if directory already exists
  if [[ -d "$full_path" ]]; then
    error "Directory '$full_path' already exists"
  fi

  # Create target directory if it doesn't exist
  if [[ ! -d "$target_dir" ]]; then
    mkdir -p "$target_dir" || error "Failed to create target directory: $target_dir"
  fi

  # Clone the repository using gh cli or git
  if [[ "$url" =~ github\.com ]]; then
    gh repo clone "$url" "$full_path" 2>&1 || error "Failed to clone repository"
  else
    git clone "$url" "$full_path" 2>&1 || error "Failed to clone repository"
  fi

  echo "$full_path"
}

# Open directory in Finder
open_in_finder() {
  local path="$1"

  if [[ -d "$path" ]]; then
    open "$path"
  fi
}

# Main function
main() {
  local target_dir="${1:-$DEFAULT_TARGET_DIR}"
  local clipboard_content
  local repo_name
  local cloned_path

  info "=== Git Clone Automator ==="

  # Check prerequisites
  check_gh_cli

  # Get clipboard content
  clipboard_content=$(pbpaste)

  if [[ -z "$clipboard_content" ]]; then
    error "Clipboard is empty"
  fi

  info "Clipboard content: $clipboard_content"

  # Validate Git URL
  if ! validate_git_url "$clipboard_content"; then
    error "Invalid Git repository URL in clipboard: $clipboard_content"
  fi

  # Extract repository name
  repo_name=$(extract_repo_name "$clipboard_content")

  if [[ -z "$repo_name" ]]; then
    error "Could not extract repository name from URL"
  fi

  # Clone repository
  cloned_path=$(clone_repository "$clipboard_content" "$target_dir" "$repo_name")

  # Open in Finder
  open_in_finder "$cloned_path"

  # Success message
  success "Successfully cloned '$repo_name' to $cloned_path"
}

# Run main function
main "$@"
