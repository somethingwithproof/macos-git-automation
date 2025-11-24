# Dockerfile for testing Git Clone Automator scripts
# Note: This is for basic shell script testing only.
# macOS-specific features (AppleScript, Automator, JXA) require actual macOS.

FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    wget \
    shellcheck \
    yamllint \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy repository files
COPY . .

# Make scripts executable
RUN chmod +x test.sh test-e2e.sh install.sh || true
RUN chmod +x dist/*.sh 2>/dev/null || true

# Default command runs tests
CMD ["./test.sh"]
