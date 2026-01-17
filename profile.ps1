write-host Profile Loaded.
# Powershell profile with convenient paths, shortcuts, etc

# Copy this to suitable location such as:
#   C:\Users\razva\OneDrive\Documents\PowerShell\profile.ps1
#   C:\Users\razva\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#   
# Or whatever...

# First install posh-git
Import-Module posh-git

# vi key bindings with custom key binding for 'jj' to Escape
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Script

# Block cursor for insert, bar cursor for comamnd mode
Set-PSReadLineOption -ViModeChangeHandler {
    param($mode)

    $esc = [char]27
    switch ($mode) {
        'Insert'  { Write-Host -NoNewline "$esc[6 q" } # bar cursor
        'Command' { Write-Host -NoNewline "$esc[2 q" } # block cursor
    }
}

Set-PSReadLineKeyHandler -Chord 'j,*' -ScriptBlock {}
Set-PSReadLineKeyHandler -Chord 'j,j' -ViMode Insert -Function ViCommandMode

# HACK HACK HACK but works -- lets us type 'jk' when jj is bound to vim
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

$env:Path += ";C:\Program Files\Vim\vim91"
# [System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::User)

# Make sure to run this first: oh-my-posh font install 
# Update Windows Terminal:
#   1. Open Windows Terminal Settings (Ctrl + ,).
#   2. Go to Profiles > PowerShell > Appearance.
#   3. Change Font face to the Nerd Font you just installed (e.g., MesloLGM Nerd Font).#

# Find theme names here: https://ohmyposh.dev/docs/themes 
oh-my-posh init pwsh --config "zash" | Invoke-Expression

# Run first:
#   Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons

