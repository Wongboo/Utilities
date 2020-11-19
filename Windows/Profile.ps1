Import-Module PSReadLine
Import-Module posh-git
Import-Module oh-my-posh
Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell fffa5013 | Out-Null
Set-Theme Paradox

# 设置 tab 为菜单补全和 Intellisense
Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete

# 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward

# 设置向下键为前向搜索历史纪录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

#Edit Hosts
Function Edit-Hosts {
    Start-Process code -ArgumentList $env:windir\System32\drivers\etc\hosts -Wait
    ipconfig /flushdns | Out-Null
}

function Update-All {
    Start-Job -Name "Visual Studio update"{
        &"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" update `
            --quiet --installpath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" }
    Start-Job -Name "office update"{
        &"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" `
            /update user displaylevel=false forceappshutdown=true }
    Start-Job -Name "vcpkg update"{ 
        if (Set-Location "F:\vcpkg\vcpkg") {
            git pull | Out-Null
            vcpkg update
        } }
    Start-Process ms-settings:windowsupdate-action
    Start-Process ms-windows-store://downloadsandupdates
    Write-Output "WSL update ..."
    wsl sudo apt update && wsl sudo apt upgrade
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





