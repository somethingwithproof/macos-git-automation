#!/bin/bash
#
# Install Git Clone Automator scripts
#
# This script installs the Git Clone Automator scripts
# and creates an Automator application for easy access.
#

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if this is a CI environment
if [ -n "$CI" ]; then
  echo "CI environment detected, running in validation mode only"
  exit 0
fi

echo -e "${GREEN}=== Git Clone Automator Installation ===${NC}"

# Check for GitHub CLI
if ! command -v gh >/dev/null; then
  echo -e "${YELLOW}GitHub CLI (gh) not found. Installing with Homebrew...${NC}"
  
  # Check for Homebrew
  if ! command -v brew >/dev/null; then
    echo -e "${RED}Homebrew not found. Please install Homebrew first:${NC}"
    echo -e "${YELLOW}  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
    exit 1
  fi
  
  # Install GitHub CLI
  brew install gh
  
  # Check if installation was successful
  if ! command -v gh >/dev/null; then
    echo -e "${RED}Failed to install GitHub CLI. Please install it manually.${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}GitHub CLI installed successfully.${NC}"
fi

# Check GitHub authentication
if ! gh auth status &>/dev/null; then
  echo -e "${YELLOW}GitHub CLI not authenticated. Please authenticate:${NC}"
  gh auth login
  
  # Check if authentication was successful
  if ! gh auth status &>/dev/null; then
    echo -e "${RED}GitHub CLI authentication failed. Please try again manually.${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}GitHub CLI authenticated successfully.${NC}"
fi

# Check if dist directory exists
if [ ! -d "dist" ]; then
  echo -e "${RED}Error: dist directory not found.${NC}"
  echo -e "${YELLOW}Please ensure you're running this script from the repository root.${NC}"
  echo -e "${YELLOW}The dist/ directory should contain:${NC}"
  echo -e "  - git-clone-automator.sh"
  echo -e "  - GitCloneFromClipboard.applescript"
  echo -e "  - CloneGitRepoJXA.js"
  exit 1
fi

# Verify required files exist
REQUIRED_FILES=(
  "dist/git-clone-automator.sh"
  "dist/GitCloneFromClipboard.applescript"
  "dist/CloneGitRepoJXA.js"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo -e "${RED}Error: Required file not found: $file${NC}"
    echo -e "${YELLOW}Please ensure all script files are present in the dist/ directory.${NC}"
    exit 1
  fi
done

echo -e "${GREEN}All required files found.${NC}"

# Create applications directory if it doesn't exist
APPS_DIR="${HOME}/Applications/GitAutomation"
mkdir -p "$APPS_DIR"
echo -e "${GREEN}Created applications directory at $APPS_DIR${NC}"

# Copy scripts to applications directory
cp -f dist/GitCloneFromClipboard.applescript "$APPS_DIR/"
cp -f dist/CloneGitRepoJXA.js "$APPS_DIR/"
cp -f dist/git-clone-automator.sh "$APPS_DIR/"
chmod +x "$APPS_DIR/git-clone-automator.sh"
chmod +x "$APPS_DIR/CloneGitRepoJXA.js"
echo -e "${GREEN}Copied scripts to $APPS_DIR${NC}"

# Create AppleScript application
echo -e "${YELLOW}Creating AppleScript application...${NC}"
if osacompile -o "$APPS_DIR/Git Clone.app" dist/GitCloneFromClipboard.applescript; then
  echo -e "${GREEN}AppleScript application created successfully.${NC}"
else
  echo -e "${RED}Warning: Failed to create AppleScript application.${NC}"
  echo -e "${YELLOW}You can still use the scripts directly.${NC}"
fi

# Success message
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo -e "Scripts installed to: ${YELLOW}$APPS_DIR${NC}"
echo -e "Application created: ${YELLOW}$APPS_DIR/Git Clone.app${NC}"
echo
echo -e "${YELLOW}Usage:${NC}"
echo -e "  1. Copy a Git repository URL to your clipboard"
echo -e "  2. Run ${YELLOW}$APPS_DIR/Git Clone.app${NC} or use one of the scripts:"
echo -e "     - ${YELLOW}$APPS_DIR/git-clone-automator.sh${NC}"
echo -e "     - ${YELLOW}osascript $APPS_DIR/GitCloneFromClipboard.applescript${NC}"
echo -e "     - ${YELLOW}osascript -l JavaScript $APPS_DIR/CloneGitRepoJXA.js${NC}"
echo
echo -e "You can also add the application to your Dock for easier access."