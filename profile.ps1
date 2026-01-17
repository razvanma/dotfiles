# Display a message when the profile is loaded
write-host Profile Loaded.

# PowerShell profile with convenient paths, shortcuts, and customizations
# This profile configures vi key bindings, terminal appearance, and useful modules

# Installation Instructions:
# Copy this file to one of the following locations:
#   C:\Users\razva\OneDrive\Documents\PowerShell\profile.ps1
#   C:\Users\razva\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Or to the appropriate PowerShell profile location for your setup

# Prerequisites - Other tools that should be installed:
# - aichat: AI chat tool
# - meld: Visual diff and merge tool
# - oh-my-posh: Prompt theme engine for PowerShell

# Import posh-git module for Git integration in PowerShell
# Must first install with: Install-Module posh-git -Scope CurrentUser
Import-Module posh-git

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
oh-my-posh init pwsh --config "zash" | Invoke-Expression

# Import Terminal-Icons module for file and folder icons in terminal output
# Install first with: Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons

