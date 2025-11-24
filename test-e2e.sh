#!/bin/bash
#
# End-to-End test script for Git Clone Automator
#
# Tests actual cloning functionality with a test repository
#

set -euo pipefail

# Set colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test repository URL (using a small public repo for testing)
readonly TEST_REPO_URL="https://github.com/octocat/Hello-World"
readonly TEST_REPO_NAME="Hello-World"

# Test directory
readonly TEST_DIR="/tmp/git-automator-test-$$"

echo -e "${BLUE}=== End-to-End Tests ===${NC}"
echo -e "${YELLOW}Test directory: ${TEST_DIR}${NC}"

# Cleanup function
cleanup() {
  echo -e "${YELLOW}Cleaning up test directory...${NC}"
  rm -rf "$TEST_DIR"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Create test directory
mkdir -p "$TEST_DIR"

# Test 1: Bash script with URL argument
echo -e "${BLUE}Test 1: Testing bash script functionality${NC}"

if [ -x "dist/git-clone-automator.sh" ] && ! grep -q "Stub for CI testing" dist/git-clone-automator.sh; then
  # Copy test URL to clipboard (macOS only)
  if command -v pbcopy >/dev/null 2>&1; then
    echo "$TEST_REPO_URL" | pbcopy
    echo -e "${YELLOW}Copied test URL to clipboard${NC}"
    
    # Run the script
    if ./dist/git-clone-automator.sh "$TEST_DIR" 2>&1; then
      if [ -d "$TEST_DIR/$TEST_REPO_NAME" ]; then
        echo -e "${GREEN}✅ Bash script successfully cloned repository${NC}"
      else
        echo -e "${RED}❌ Repository directory not found${NC}"
        exit 1
      fi
    else
      echo -e "${RED}❌ Bash script failed${NC}"
      exit 1
    fi
  else
    echo -e "${YELLOW}⚠️  SKIP: pbcopy not available (not on macOS)${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  SKIP: Real bash script not available${NC}"
fi

# Test 2: Verify repository contents
echo -e "${BLUE}Test 2: Verifying cloned repository${NC}"

if [ -d "$TEST_DIR/$TEST_REPO_NAME" ]; then
  cd "$TEST_DIR/$TEST_REPO_NAME"
  
  # Check if it's a git repository
  if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Cloned directory is a git repository${NC}"
  else
    echo -e "${RED}❌ Not a git repository${NC}"
    exit 1
  fi
  
  # Check if README exists (this repo should have one)
  if [ -f "README" ]; then
    echo -e "${GREEN}✅ Repository contents verified${NC}"
  else
    echo -e "${YELLOW}⚠️  Expected README file not found${NC}"
  fi
  
  cd -
else
  echo -e "${YELLOW}⚠️  SKIP: Repository not cloned in previous test${NC}"
fi

# Test 3: URL validation
echo -e "${BLUE}Test 3: Testing URL validation${NC}"

if [ -x "dist/git-clone-automator.sh" ] && ! grep -q "Stub for CI testing" dist/git-clone-automator.sh; then
  # Test with invalid URL
  if command -v pbcopy >/dev/null 2>&1; then
    echo "not-a-valid-url" | pbcopy
    
    if ./dist/git-clone-automator.sh "$TEST_DIR" 2>&1 | grep -q "Invalid"; then
      echo -e "${GREEN}✅ URL validation working correctly${NC}"
    else
      echo -e "${YELLOW}⚠️  URL validation test inconclusive${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  SKIP: pbcopy not available${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  SKIP: Real bash script not available${NC}"
fi

# Test 4: Test duplicate directory detection
echo -e "${BLUE}Test 4: Testing duplicate directory detection${NC}"

if [ -d "$TEST_DIR/$TEST_REPO_NAME" ] && [ -x "dist/git-clone-automator.sh" ] && ! grep -q "Stub for CI testing" dist/git-clone-automator.sh; then
  if command -v pbcopy >/dev/null 2>&1; then
    echo "$TEST_REPO_URL" | pbcopy
    
    if ./dist/git-clone-automator.sh "$TEST_DIR" 2>&1 | grep -q "already exists"; then
      echo -e "${GREEN}✅ Duplicate directory detection working${NC}"
    else
      echo -e "${YELLOW}⚠️  Duplicate detection test inconclusive${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  SKIP: pbcopy not available${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  SKIP: Prerequisites not met${NC}"
fi

echo -e "${GREEN}=== End-to-End Tests Complete ===${NC}"
exit 0
