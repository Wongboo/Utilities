$Psfile = "C:\Users\90834\Documents\PowerShell\Profile.ps1"
<#
Set VC env
Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell -VsInstallPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" `
-DevCmdArguments "-arch=x64 -host_arch=x64" -SkipAutomaticLocation | Out-Null
#>
foreach ($_ in Get-Content -Path C:\Users\90834\Documents\env.txt) {
    if ($_ -match '^([^=]+)=(.*)') 
    { [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2]) } 
}
if (Test-Path F:\) {
    Import-Module 'F:\vcpkg\vcpkg\scripts\posh-vcpkg'
}

#Set python env
Set-Alias -Name python3 -Value py.exe
Set-Alias -Name python -Value py.exe
Function pip { python -m pip $args }
Function ipython { python -c "from IPython import embed; embed()" }
Function Update-Pip {
    $a = pip list --outdated
    $num_package = $a.Length - 2
    for ($i = 0; $i -lt $num_package; $i++) {
        $tmp = ($a[2 + $i].Split(" "))[0]
        pip install -U $tmp
    }
} 

#Set winget autocompletion
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

#Set autocompletion
Import-Module PSReadLine
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt jandedobbeleer

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
#Edit Hosts
Function Edit-Hosts {
    Start-Process code -ArgumentList $env:windir\System32\drivers\etc\hosts -Wait -NoNewWindow
    ipconfig /flushdns | Out-Null
}
function Update-All {
    if ($args.Count -eq 0) {
        Start-Job -Name "Visual Studio update" {
            & $env:VSINSTALLDIR\..\..\Installer\vs_installer.exe update `
                --quiet --installpath $env:VSINSTALLDIR }
        Start-Job -Name "office update" {
            &"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient" `
                /update user displaylevel=false forceappshutdown=true }
    }
    if (Test-Path F:\) {
        git -C "F:\vcpkg\vcpkg" pull | Out-Null
        vcpkg update
    } 
    Start-Process ms-settings:windowsupdate-action
    Start-Process ms-windows-store://downloadsandupdates
    Write-Output "Powershell module update"
    Update-Module 
    Write-Output "pip update"
    Update-Pip
    <#
    Write-Output "WSL update ..."
    wsl sudo apt update '&&' sudo apt upgrade
    Write-Output "Git update ..."
    git update-git-for-windows
    Write-Output "Rust update"
    rustup self update && rustup update
    #>
}
function Remove-DS-Store {
    Get-ChildItem . -r -include ._* -force | remove-item -r -force
    Get-ChildItem . -r -include .DS_Store -force | remove-item -r -force
    Write-Output "Delete success"
}
<#
function Update-PowerShell {
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
}
#>
function Calculator {
    ipython -c "from math import *; from numpy import *; from scipy import *; from sympy import *"
}
function Update-VC-env {
    Start-Process powershell.exe -UseNewEnvironment -Wait -NoNewWindow `
      