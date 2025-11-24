<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>523</string>
    <key>AMApplicationVersion</key>
    <string>2.10</string>
    <key>AMDocumentVersion</key>
    <string>2</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMActionVersion</key>
                <string>1.0.2</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMParameterProperties</key>
                <dict>
                    <key>source</key>
                    <dict/>
                </dict>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.applescript.object</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run AppleScript.action</string>
                <key>ActionName</key>
                <string>Run AppleScript</string>
                <key>ActionParameters</key>
                <dict>
                    <key>source</key>
                    <string>on run {input, parameters}
    -- Get clipboard content
    set clipboardContent to the clipboard as text
    
    -- Validate clipboard content
    if clipboardContent is "" then
        display notification "Clipboard is empty" with title "Git Clone Error" sound name "Basso"
        return input
    end if
    
    -- Check if it's a valid Git URL
    if not (clipboardContent starts with "https://github.com/" or clipboardContent starts with "git@github.com:") then
        display notification "Invalid Git URL in clipboard" with title "Git Clone Error" sound name "Basso"
        return input
    end if
    
    -- Extract repository name
    set AppleScript's text item delimiters to "/"
    if clipboardContent ends with "/" then
        set clipboardContent to text 1 thru -2 of clipboardContent
    end if
    
    set urlParts to text items of clipboardContent
    set repoName to last item of urlParts
    
    if repoName ends with ".git" then
        set repoName to text 1 thru -5 of repoName
    end if
    
    set AppleScript's text item delimiters to ""
    
    -- Clone repository
    try
        set targetPath to POSIX path of (path to documents folder) & repoName
        
        if clipboardContent contains "github.com" then
            set cloneCommand to "gh repo clone " & quoted form of clipboardContent & " " & quoted form of targetPath
        else
            set cloneCommand to "git clone " & quoted form of clipboardContent & " " & quoted form of targetPath
        end if
        
        do shell script cloneCommand
        
        -- Open in Finder
        tell application "Finder"
            open POSIX file targetPath
            activate
        end tell
        
        display notification "Successfully cloned " & repoName with title "Git Clone Success" sound name "Glass"
        
    on error errMsg
        display notification "Failed to clone: " & errMsg with title "Git Clone Error" sound name "Basso"
    end try
    
    return input
end run
</string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.Automator.RunScript</string>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.application</string>
    </dict>
</dict>
</plist>
