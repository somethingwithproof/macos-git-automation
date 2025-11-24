#!/usr/bin/env osascript -l JavaScript

/**
 * Git Clone From Clipboard - JavaScript for Automation (JXA)
 *
 * Clones a Git repository from a URL in the clipboard to ~/Documents
 */

ObjC.import('AppKit');
ObjC.import('Foundation');

/**
 * Get clipboard content
 * @returns {string} The clipboard text content
 */
function getClipboard() {
    const pasteboard = $.NSPasteboard.generalPasteboard;
    const content = pasteboard.stringForType($.NSPasteboardTypeString);
    return ObjC.unwrap(content) || '';
}

/**
 * Validate if string is a valid Git URL
 * @param {string} url - The URL to validate
 * @returns {boolean} True if valid Git URL
 */
function isValidGitURL(url) {
    const patterns = [
        /^https?:\/\/github\.com\/[^/]+\/[^/]+\/?$/,
        /^git@github\.com:[^/]+\/[^/]+\.git$/,
        /^https?:\/\/[^/]+\/[^/]+\/[^/]+\/?$/,
        /^git@[^:]+:[^/]+\/[^/]+\.git$/
    ];
    
    return patterns.some(pattern => pattern.test(url));
}

/**
 * Extract repository name from Git URL
 * @param {string} url - The Git URL
 * @returns {string} The repository name
 */
function extractRepoName(url) {
    // Remove trailing slash
    url = url.replace(/\/$/, '');
    
    // Remove .git extension
    url = url.replace(/\.git$/, '');
    
    // Extract last component
    const parts = url.split('/');
    const repoName = parts[parts.length - 1];
    
    // For SSH URLs, handle colon separator
    if (repoName.includes(':')) {
        const sshParts = repoName.split(':');
        return sshParts[sshParts.length - 1];
    }
    
    return repoName;
}

/**
 * Show system notification
 * @param {string} title - Notification title
 * @param {string} message - Notification message
 * @param {string} sound - Sound name (optional)
 */
function showNotification(title, message, sound = 'Glass') {
    const app = Application.currentApplication();
    app.includeStandardAdditions = true;
    
    try {
        app.displayNotification(message, {
            withTitle: title,
            soundName: sound
        });
    } catch (e) {
        console.log(`${title}: ${message}`);
    }
}

/**
 * Execute shell command
 * @param {string} command - The command to execute
 * @returns {string} The command output
 */
function runCommand(command) {
    const app = Application.currentApplication();
    app.includeStandardAdditions = true;
    
    try {
        return app.doShellScript(command);
    } catch (e) {
        throw new Error(`Command failed: ${e.message}`);
    }
}

/**
 * Check if directory exists
 * @param {string} path - The directory path
 * @returns {boolean} True if directory exists
 */
function directoryExists(path) {
    const fileManager = $.NSFileManager.defaultManager;
    const fileURL = $.NSURL.fileURLWithPath(path);
    return fileManager.fileExistsAtPath(fileURL.path);
}

/**
 * Open directory in Finder
 * @param {string} path - The directory path
 */
function openInFinder(path) {
    const finder = Application('Finder');
    finder.activate();
    
    const posixFile = Path(path);
    finder.open(posixFile);
}

/**
 * Main function
 */
function run() {
    const app = Application.currentApplication();
    app.includeStandardAdditions = true;
    
    try {
        // Get clipboard content
        const clipboardContent = getClipboard();
        
        if (!clipboardContent) {
            showNotification('Git Clone Error', 'Clipboard is empty', 'Basso');
            throw new Error('Clipboard is empty');
        }
        
        console.log(`Clipboard content: ${clipboardContent}`);
        
        // Validate Git URL
        if (!isValidGitURL(clipboardContent)) {
            showNotification('Git Clone Error', 'Invalid Git URL in clipboard', 'Basso');
            throw new Error(`Invalid Git URL: ${clipboardContent}`);
        }
        
        // Extract repository name
        const repoName = extractRepoName(clipboardContent);
        
        if (!repoName) {
            showNotification('Git Clone Error', 'Could not extract repository name', 'Basso');
            throw new Error('Could not extract repository name from URL');
        }
        
        console.log(`Repository name: ${repoName}`);
        
        // Set target directory
        const documentsPath = app.pathTo('documents folder', {as: 'string'})
            .toString()
            .replace(/^.*:/, '')
            .replace(/:/g, '/');
        const targetPath = `${documentsPath}/${repoName}`;
        
        // Check if directory already exists
        if (directoryExists(targetPath)) {
            showNotification('Git Clone Error', `Directory already exists: ${repoName}`, 'Basso');
            throw new Error('Directory already exists');
        }
        
        console.log(`Cloning to: ${targetPath}`);
        
        // Clone repository
        let cloneCommand;
        if (clipboardContent.includes('github.com')) {
            cloneCommand = `gh repo clone '${clipboardContent}' '${targetPath}'`;
        } else {
            cloneCommand = `git clone '${clipboardContent}' '${targetPath}'`;
        }
        
        runCommand(cloneCommand);
        
        // Open in Finder
        openInFinder(targetPath);
        
        // Success notification
        showNotification('Git Clone Success', `Successfully cloned ${repoName}`, 'Glass');
        
        console.log(`Successfully cloned ${repoName}`);
        
    } catch (e) {
        console.error(`Error: ${e.message}`);
        showNotification('Git Clone Error', e.message, 'Basso');
        throw e;
    }
}
