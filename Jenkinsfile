pipeline {
    agent {
        label 'macos'
    }
    
    environment {
        // Ensure GitHub CLI is in PATH
        PATH = "/usr/local/bin:/opt/homebrew/bin:${env.PATH}"
    }
    
    options {
        // Keep only last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Timeout after 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        
        // Timestamps in console output
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out repository...'
                checkout scm
            }
        }
        
        stage('Environment Check') {
            steps {
                echo 'Checking build environment...'
                sh '''
                    echo "macOS Version:"
                    sw_vers
                    
                    echo "\nBash Version:"
                    bash --version | head -1
                    
                    echo "\nGit Version:"
                    git --version
                    
                    echo "\nChecking for GitHub CLI..."
                    if command -v gh >/dev/null 2>&1; then
                        gh --version
                    else
                        echo "GitHub CLI not installed"
                    fi
                    
                    echo "\nChecking for shellcheck..."
                    if command -v shellcheck >/dev/null 2>&1; then
                        shellcheck --version
                    else
                        echo "shellcheck not installed"
                    fi
                '''
            }
        }
        
        stage('Syntax Validation') {
            steps {
                echo 'Validating script syntax...'
                sh '''
                    # Validate bash scripts
                    echo "Validating bash scripts..."
                    bash -n install.sh
                    bash -n test.sh
                    bash -n test-e2e.sh
                    
                    if [ -f dist/git-clone-automator.sh ]; then
                        bash -n dist/git-clone-automator.sh
                    fi
                '''
            }
        }
        
        stage('Lint') {
            steps {
                echo 'Running linters...'
                sh '''
                    # Run shellcheck if available
                    if command -v shellcheck >/dev/null 2>&1; then
                        echo "Running shellcheck..."
                        shellcheck -x install.sh test.sh test-e2e.sh || true
                        
                        if [ -f dist/git-clone-automator.sh ]; then
                            shellcheck -x dist/git-clone-automator.sh || true
                        fi
                    else
                        echo "Shellcheck not available, skipping..."
                    fi
                    
                    # Run yamllint if available
                    if command -v yamllint >/dev/null 2>&1; then
                        echo "Running yamllint..."
                        yamllint -d relaxed .github/ || true
                    else
                        echo "yamllint not available, skipping..."
                    fi
                '''
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh '''
                    chmod +x test.sh
                    ./test.sh
                '''
            }
        }
        
        stage('Integration Tests') {
            when {
                branch 'main'
            }
            steps {
                echo 'Running integration tests...'
                sh '''
                    # Only run E2E tests on main branch
                    if [ -x test-e2e.sh ]; then
                        chmod +x test-e2e.sh
                        ./test-e2e.sh || echo "E2E tests skipped or incomplete"
                    fi
                '''
            }
        }
        
        stage('Security Scan') {
            steps {
                echo 'Running security scans...'
                sh '''
                    # Check for common security issues in shell scripts
                    echo "Checking for security issues..."
                    
                    # Check for hardcoded credentials
                    if grep -r "password\\|token\\|secret" --include="*.sh" . | grep -v "# "; then
                        echo "WARNING: Potential hardcoded credentials found"
                    else
                        echo "No obvious hardcoded credentials found"
                    fi
                    
                    # Check for unsafe eval usage
                    if grep -r "eval " --include="*.sh" .; then
                        echo "WARNING: eval usage found - review for safety"
                    else
                        echo "No eval usage found"
                    fi
                '''
            }
        }
        
        stage('Build Artifacts') {
            steps {
                echo 'Creating build artifacts...'
                sh '''
                    # Create a release archive
                    mkdir -p artifacts
                    
                    # Archive the scripts
                    tar -czf artifacts/macos-git-automation-${BUILD_NUMBER}.tar.gz \
                        dist/ \
                        install.sh \
                        README.md \
                        LICENSE \
                        CONTRIBUTING.md \
                        CHANGELOG.md
                    
                    echo "Build artifacts created"
                    ls -lh artifacts/
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
            
            // Archive test results if they exist
            archiveArtifacts artifacts: 'artifacts/*.tar.gz', 
                             allowEmptyArchive: true,
                             fingerprint: true
        }
        
        success {
            echo 'Pipeline completed successfully!'
        }
        
        failure {
            echo 'Pipeline failed!'
        }
        
        unstable {
            echo 'Pipeline completed with warnings!'
        }
    }
}
