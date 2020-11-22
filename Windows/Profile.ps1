#Set VC env
#Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
#Enter-VsDevShell -VsInstallPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" `
#-DevCmdArguments "-arch=x64 -host_arch=x64" -SkipAutomaticLocation | Out-Null
foreach($_ in Get-Content -Path C:\Users\90834\Documents\env.txt) 
{ if ($_ -match '^([^=]+)=(.*)') 
{ [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2]) } }

#set python env
New-Alias -Name python3 -Value py.exe
New-Alias -Name python -Value py.exe

#Set autocompletion
Import-Module PSReadLine
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt jandedobbeleer
#Set-PoshPrompt aliens

#Set-PSReadlineOption -EditMode vi
Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

#Edit Hosts
Function Edit-Hosts {
    Start-Process code -ArgumentList $env:windir\System32\drivers\etc\hosts -Wait
    ipconfig /flushdns | Out-Null
}

function Update-All {
    Start-Job -Name "Visual Studio update"{
        &"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer" update `
            --quiet --installpath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" }
    Start-Job -Name "office update"{
        &"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient" `
            /update user displaylevel=false forceappshutdown=true }
    Start-Job -Name "vcpkg update"{ 
        if (Set-Location "F:\vcpkg\vcpkg") {
            git pull | Out-Null
            vcpkg update
        } }
    Start-Process ms-settings:windowsupdate-action
    Start-Process ms-windows-store://downloadsandupdates
    Write-Output "WSL update ..."
    wsl sudo apt update '&&' sudo apt upgrade
    Write-Output "Git update ..."
    git update-git-for-windows
    Write-Output "Powershell module update"
    Update-Module
    Write-Output "pip update"
    $a = pip list --outdated
    $num_package = $a.Length - 2
    for ($i = 0; $i -lt $num_package; $i++) {
        $tmp = ($a[2 + $i].Split(" "))[0]
        pip install -U $tmp
    }
}

function Remove-DS-Store {
       Get-ChildItem . -r -include ._* -force | remove-item -r -force
       Get-ChildItem . -r -include .DS_Store -force | remove-item -r -force
   Write-Output "Delete success"
}

function Update-PowerShell {
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
}

function calculator {
    ipython -c "from math import *; from numpy import *; from scipy import *; from sympy import *"
}

functi