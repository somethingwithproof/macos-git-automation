-- Git Clone From Clipboard - AppleScript
--
-- Clones a Git repository from a URL in the clipboard to ~/Documents
--

on run
    -- Get clipboard content
    set clipboardContent to the clipboard as text
    
    -- Validate clipboard content
    if clipboardContent is "" then
        display notification "Clipboard is empty" with title "Git Clone Error" sound name "Basso"
        error "Clipboard is empty"
    end if
    
    -- Check if it's a valid Git URL
    if not isValidGitURL(clipboardContent) then
        display notification "Invalid Git URL in clipboard" with title "Git Clone Error" sound name "Basso"
        error "Invalid Git URL: " & clipboardContent
    end if
    
    -- Extract repository name
    set repoName to extractRepoName(clipboardContent)
    
    if repoName is "" then
        display notification "Could not extract repository name" with title "Git Clone Error" sound name "Basso"
        error "Could not extract repository name from URL"
    end if
    
    -- Set target directory
    set targetDir to (path to documents folder as text) & repoName & ":"
    
    -- Check if directory already exists
    try
        tell application "System Events"
            if exists folder targetDir then
                display notification "Directory already exists: " & repoName with title "Git Clone Error" sound name "Basso"
                error "Directory already exists"
            end if
        end tell
    end try
    
    -- Clone repository
    try
        set targetPath to POSIX path of (path to documents folder) & repoName
        
        -- Use gh cli for GitHub repos, git for others
        if clipboardContent contains "github.com" then
            set cloneCommand to "gh repo clone " & quoted form of clipboardContent & " " & quoted form of targetPath
        else
            set cloneCommand to "git clone " & quoted form of clipboardContent & " " & quoted form of targetPath
        end if
        
        do shell script cloneCommand
        
        -- Open in Finder
        tell application "Finder"
            open folder targetDir
            activate
        end tell
        
        -- Success notification
        display notification "Successfully cloned " & repoName with title "Git Clone Success" sound name "Glass"
        
    on error errMsg
        display notification "Failed to clone repository: " & errMsg with title "Git Clone Error" sound name "Basso"
        error "Clone failed: " & errMsg
    end try
end run

-- Validate Git URL
on isValidGitURL(url)
    -- Check for common Git URL patterns
    if url starts with "https://github.com/" then
        return true
    else if url starts with "http://github.com/" then
        return true
    else if url starts with "git@github.com:" then
        return true
    else if url starts with "https://" and url contains ".git" then
        return true
    else if url starts with "git@" and url contains ".git" then
        return true
    else
        return false
    end if
end isValidGitURL

-- Extract repository name from URL
on extractRepoName(url)
    set AppleScript's text item delimiters to "/"

    -- Copy URL to local variable
    set cleanUrl to url

    -- Remove trailing slash if present
    if cleanUrl ends with "/" then
        set cleanUrl to text 1 thru -2 of cleanUrl
    end if

    -- Get last component
    set urlParts to text items of cleanUrl
    set repoName to last item of urlParts

    -- Remove .git extension if present
    if repoName ends with ".git" then
        set repoName to text 1 thru -5 of repoName
    end if

    set AppleScript's text item delimiters to ""

    return repoName
end extractRepoName
