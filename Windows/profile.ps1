#以上加载跨平台设置
. $HOME\.profile.ps1

#设置自动补全
#以下用于winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
#以下用于vcpkg
if (Test-Path F:\) { Import-Module 'F:\vcpkg\vcpkg\scripts\posh-vcpkg' }

#以下设置WSL
function trans { wsl trans @args }
#以下设置Host
$HostsFile = "$env:windir\System32\drivers\etc\hosts"

Function Update-All {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Set-Proxy -ProxyType Unset
    Start-Job -Name "office升级" {
        &"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient" `
            /update user displaylevel=false forceappshutdown=true }
    Start-Process ms-settings:windowsupdate-action
    Start-Process ms-windows-store://downloadsandupdates
    Write-Output "powershell module升级"
    Update-Module -Proxy "http://127.0.0.1:1087"
    Write-Output "pip升级"
    Update-Pip
    Write-Output "winget升级"
    winget upgrade
    $SpecialApps = @("Git.Git", "EpicGames.EpicGamesLauncher", "Python.Python.3", "Microsoft.dotnet")
    winget upgrade | Select-Object -Skip 4 | ForEach-Object {
        $App = $_.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[-4]  
        if ($SpecialApps -notcontains $App -and $PSCmdlet.ShouldProcess($App, "winget upgrade")) {
            winget upgrade $App
        }
    }
    if (Test-Path F:\) {
        Write-Output "vcpkg升级"
        git -C "F:\vcpkg\vcpkg" pull #| Out-Null
        vcpkg update
        Write-Output "texlive升级"
        tlmgr update --self --all
        Write-Output "rust升级"
        $env:RUSTUP_DIST_SERVER = "https://mirrors.ustc.edu.cn/rust-static"
        $env:RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup"
        rustup self update && rustup update
        Write-Output "WSL升级 ..."
        wsl update
    }
}
Function Set-VC-env {
    Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell -VsInstallPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" `
        -DevCmdArguments "-arch=x64 -host_arch=x64" -SkipAutomaticLocation
}
Function Get-Elevate-Command ($Command) {
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $false
    }
    else {
        Start-Process pwsh -Verb RunAs -ArgumentList "-Command "".$PROFILE.CurrentUserAllHosts $Command"" "
        return $true
    }
}
<#
Function Update-VC-env {
    Start-Process pwsh.exe -UseNewEnvironment -Wait -NoNewWindow `
        -ArgumentList "-NoProfile -File $HOME\Documents\Utilities\Windows\Update-VC-env.ps1"
    .$Psfile
    #cmd /c " @call `"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat`" && SET" |
    #Where-Object {($_ -match '^([^=]+)=(.*)') -and ([System.Environment]::GetEnvironmentVariable($matches[1]) -ne $matches[2])}|
    #Out-File -FilePath ~\Documents\env.txt
}
Function Update-Visual-Studio {
    Start-Job -Name "Visual Studio update" {
        & $env:VSINSTALLDIR\..\..\Installer\vs_installer.exe update `
            --installpath $env:VSINSTALLDIR }
}
foreach ($_ in Get-Content -Path $HOME\Documents\env.txt) {
    if ($_ -match '^([^=]+)=(.*)')
    { [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2]) }
}
    Write-Host "Git升级 ..."
    git update-git-for-windows
    Write-Host "Rust升级"
    rustup self update && rustup update
#>