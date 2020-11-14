#Edit Hosts
Function Edit-Hosts {
    Start-Process code -ArgumentList $env:windir\System32\drivers\etc\hosts -Wait
    ipconfig /flushdns | Out-Null
}

function update-all {
    Start-Job {
        &"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" update `
            --quiet --installpath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" }
    Start-Job {
        &"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" `
            /update user displaylevel=false forceappshutdown=true }
    Start-Job { 
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
}

function Remove-DS-Store {
       Get-ChildItem . -r -include ._* -force | remove-item -r -force
       Get-ChildItem . -r -include .DS_Store -force | remove-item -r -force
   Write-Output "Delete success"
}





