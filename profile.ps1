# This PowerShell profile customizes the shell environment, providing convenient
# paths, shortcuts, vi key bindings, terminal appearance, and useful module imports.

# Installation Instructions:
# Copy this file to one of the following locations:
#   C:\Users\razva\OneDrive\Documents\PowerShell\profile.ps1
#   C:\Users\razva\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Or to the appropriate PowerShell profile location for your setup

# Prerequisites - Other developer tools that should be installed:
# - aichat: AI chat tool
# - meld: Visual diff and merge tool
# - posh-git: Git integration in PowerShell
# - Terminal-Icons: File and folder icons in terminal output
# - oh-my-posh: Prompt theme engine for PowerShell
# - cursor: Code editor
# - nodist: Node.js and npm version manager
# - gemini: AI chat cli
# - git: Version control system
# - gh: GitHub CLI
# - microsoft/inshellisense: IntelliSense for PowerShell
# - npm: Node.js package manager

# Import posh-git module for Git integration in PowerShell
# This module provides Git status information directly in the PowerShell prompt.
# Must first install with: Install-Module posh-git -Scope CurrentUser
Write-Host "Loading posh-git module..." -ForegroundColor Cyan
Import-Module posh-git

# Install @microsoft/inshellisense for IntelliSense
is -s pwsh
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing @microsoft/inshellisense..." -ForegroundColor Cyan
    npm install -g @microsoft/inshellisense
}


# Recommended git configurations
# For more information, see: https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration
# - git config --global user.name "John Doe"
# - git config --global user.email "john.doe@example.com"
# - git config --global core.editor "cursor --wait"
# - git config --global diff.tool meld
# - git config --global merge.tool meld
# - git config --global difftool.prompt false

# Configure vi-style key bindings for PowerShell command line editing
# This enables vim-like navigation and editing in the PowerShell prompt
Write-Host "Configuring vi key bindings..." -ForegroundColor Cyan
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Script

# Configure cursor appearance based on vi mode:
# - Insert mode: bar cursor (|) for text insertion
# - Command mode: block cursor (█) for command navigation
Set-PSReadLineOption -ViModeChangeHandler {
    param($mode)

    $esc = [char]27
    switch ($mode) {
        'Insert'  { Write-Host -NoNewline "$esc[6 q" } # bar cursor
        'Command' { Write-Host -NoNewline "$esc[2 q" } # block cursor
    }
}

# Configure custom key bindings for vi mode:
# - 'j,*' (j followed by any key): Clear the default handler to allow custom behavior
# - 'j,j' (double j): Switch from Insert mode to Command mode (acts like Escape)
Set-PSReadLineKeyHandler -Chord 'j,*' -ScriptBlock {}
Set-PSReadLineKeyHandler -Chord 'j,j' -ViMode Insert -Function ViCommandMode

# Workaround to allow typing 'jk' and other 'j' sequences when 'jj' is bound to Escape
# This handler intercepts 'j' followed by any character (except another 'j') and
# inserts both characters normally, allowing words like "just" or "json" to be typed
Write-Host "Setting up custom 'jj' key binding workaround..." -ForegroundColor Cyan
$letters = 'abcdefghijklmnopqrstuvwxyz'
$digits  = '0123456789'
$symbols = '-_=+[]{};:''",.<>/?\|`~!@#$%^&*()'

foreach ($c in ($letters + $digits + $symbols).ToCharArray()) {
    if ($c -ne 'j') {
        Set-PSReadLineKeyHandler -Chord "j,$c" -ScriptBlock {
            param($key, $arg)
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert('j')
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.keyChar)
        }
    }
}

# Add Vim executable directory to PATH for easy access to vim commands
Write-Host "Adding Vim to PATH..." -ForegroundColor Cyan
$env:Path += ";C:\Program Files\Vim\vim91"
# Alternative: Permanently add to user PATH (uncomment to use):
# [System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::User)

# Configure oh-my-posh for custom PowerShell prompt themes
# Prerequisites:
#   1. Install oh-my-posh: winget install JanDeDobbeleer.OhMyPosh
#   2. Install a Nerd Font: oh-my-posh font install
#   3. Update Windows Terminal font:
#      - Open Windows Terminal Settings (Ctrl + ,)
#      - Go to Profiles > PowerShell > Appearance
#      - Change Font face to the Nerd Font you installed (e.g., MesloLGM Nerd Font)
# Find available theme names here: https://ohmyposh.dev/docs/themes
Write-Host "Initializing oh-my-posh with 'zash' theme..." -ForegroundColor Cyan
oh-my-posh init pwsh --config "zash" | Invoke-Expression

# Import Terminal-Icons module for file and folder icons in terminal output
# Install first with: Install-Module -Name Terminal-Icons -Repository PSGallery
Write-Host "Loading Terminal-Icons module..." -ForegroundColor Cyan
Import-Module -Name Terminal-Icons

# Define functions for quick git operations.
Write-Host "Defining git helper functions..." -ForegroundColor Cyan
function gdt {
    git difftool --dir-diff $args
}
function gmt {
    git mergetool --dir-diff $args
}
function gcam {
    git commit -am $args
}
function glo {
    git log --oneline $args
}
function gco {
    git checkout $args
}
function gd {
    git diff $args
}
function gdf {
    git diff --stat --name-only $args
}
function gca {
    git commit -a $args
}

Write-Host "PowerShell profile loaded successfully!" -ForegroundColor Green