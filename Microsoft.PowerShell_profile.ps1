# Inits
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/RaoulBivolaru/win-conf/main/omp.json' | Invoke-Expression
$env:POSH_GIT_ENABLED = $true
Import-Module -Name Terminal-Icons
Enable-PowerType
Import-Module PSFzf
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -EditMode Windows -HistorySearchCursorMovesToEnd

# Shortcuts
Set-PsFzfOption -PSReadLineChordProvider 'Ctrl+f' -PSReadLineChordReverseHistory 'Ctrl+r' -TabExpansion
Set-PSReadLineKeyHandler -Key Shift+Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardWord

Set-Alias grep findstr

function Yarn-Install { yarn install }
New-Alias yi Yarn-Install
function Yarn-Build { yarn build }
New-Alias yb Yarn-Build
function Yarn-Start { yarn start }
New-Alias ys Yarn-Start
function Yarn-StartAll { yarn start:all }
New-Alias ysa Yarn-StartAll

function Invoke-Maven-Command {
    param (
        [string]$goal,     # The main Maven goal, like 'clean install'
        [string]$profile = '', # Optional Maven profile, like '-PautoInstallPackage'
        [string]$settings = '', # Optional Maven settings file
        [string]$properties = '' # Optional Maven system properties
    )

    # Build the base command
    $cmd = "mvn $goal"

    # Add the profile if provided
    if ($profile) {
        $cmd += " $profile"
    }

    # Add the settings file if provided
    if ($settings) {
        $cmd += " -s $settings"
    }

    # Add system properties if provided
    if ($properties) {
        $cmd += " -D$properties"
    }

    # Execute the final command
    Invoke-Expression $cmd
}

# Maven Aliases using the helper function
function Maven-Clean-Install {
    param (
        [string]$settings = '',
        [string]$properties = ''
    )
    Invoke-Maven-Command -goal 'clean install' -settings $settings -properties $properties
}
New-Alias mci Maven-Clean-Install

function Maven-Clean-Install-Package {
    param (
        [string]$settings = '',
        [string]$properties = ''
    )
    Invoke-Maven-Command -goal 'clean install' -profile '-PautoInstallPackage' -settings $settings -properties $properties
}
New-Alias mcip Maven-Clean-Install-Package

function Maven-Clean-Install-Package-Publish {
    param (
        [string]$settings = '',
        [string]$properties = ''
    )
    Invoke-Maven-Command -goal 'clean install' -profile '-PautoInstallPackagePublish' -settings $settings -properties $properties
}
New-Alias mcipp Maven-Clean-Install-Package-Publish

function Maven-Clean-Install-Bundle {
    param (
        [string]$settings = '',
        [string]$properties = ''
    )
    Invoke-Maven-Command -goal 'clean install' -profile '-PautoInstallBundle' -settings $settings -properties $properties
}
New-Alias mcib Maven-Clean-Install-Bundle

function Maven-Clean-Install-Bundle-Publish {
    param (
        [string]$settings = '',
        [string]$properties = ''
    )
    Invoke-Maven-Command -goal 'clean install' -profile '-PautoInstallBundlePublish' -settings $settings -properties $properties
}
New-Alias mcibp Maven-Clean-Install-Bundle-Publish

Set-PSReadLineKeyHandler -Key Ctrl+B `
-BriefDescription BuildCurrentDirectory `
-LongDescription "Build the current directory" `
-ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet build")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key F1 `
                         -BriefDescription CommandHelp `
                         -LongDescription "Open the help window for the current command" `
                         -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $commandAst = $ast.FindAll( {
        $node = $args[0]
        $node -is [CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
        }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null)
    {
        $commandName = $commandAst.GetCommandName()
        if ($commandName -ne $null)
        {
            $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
            if ($command -is [AliasInfo])
            {
                $commandName = $command.ResolvedCommandName
            }

            if ($commandName -ne $null)
            {
                Get-Help $commandName -ShowWindow
            }
        }
    }
}
