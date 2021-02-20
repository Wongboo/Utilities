#不要用ShouldProcess
#设置python环境
Function Update-Pip {
    pip list --outdated | Select-Object -Skip 2 | ForEach-Object { pip install -U $_.Remove($_.IndexOf(' ')) }
}

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
Import-Module posh-git, oh-my-posh
Set-PoshPrompt jandedobbeleer

#设置PSreadline
Import-Module PSReadLine
#设置option是为了vi-mode
Function OnViModeChange {
    if ($args[0] -ceq 'Command') {
        #Set the cursor to a blinking block.
        Write-Host -NoNewline "`e[1 q"
    }
    else {
        #Set the cursor to a blinking line.
        Write-Host -NoNewline "`e[5 q"
    }
}
Set-PSReadLineOption -EditMode Vi -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Function Edit-Hosts {
    code $env:windir\System32\drivers\etc\hosts --wait && Clear-DnsClientCache | Out-Null
}
Function Update-All {
    Set-Proxy -ProxyType Unset
    Start-Job -Name "office升级" {
        &"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient" `
            /update user displaylevel=false forceappshutdown=true }
    Start-Process ms-settings:windowsupdate-action
    Start-Process ms-windows-store://downloadsandupdates
    Write-Host "powershell module升级"
    Update-Module -Proxy "http://127.0.0.1:1087"
    Write-Host "pip升级"
    Update-Pip
    if (Test-Path F:\) {
        Write-Host "vcpkg升级"
        git -C "F:\vcpkg\vcpkg" pull #| Out-Null
        vcpkg update
        Write-Host "texlive升级"
        tlmgr update --self --all
        Write-Host "WSL升级 ..."
        wsl update
    }
}
#MacOS残留的.DS_Store, ._*可以用该函数删除
Function Remove-DS-Store {
    Get-ChildItem -Recurse -Include ._*, .DS_Store -Force | Remove-Item @args
}
Function Calculator {
    ipython -i -c "from math import *; from numpy import *; from scipy import *; from sympy import *" @args
}
Function Set-Proxy {
    [CmdletBinding(DefaultParameterSetName = 'Server')]
    param (
        [Parameter(ParameterSetName = 'Server', Position = 0)]
        [string]$Server = "socks5://127.0.0.1:1086",

        [Parameter(Mandatory = $true, ParameterSetName = 'ProxyType')]
        [ValidateSet("SockS5", "HTTP", "Unset")]
        [string]$ProxyType
    )

    switch -Exact ($ProxyType) {
        "HTTP" { $Server = "http://127.0.0.1:1087" }
        "Unset" { $Server = "" }
    }
    $env:ALL_PROXY = $env:HTTP_PROXY = $env:HTTPS_PROXY = $Server
}
Function Get-GNU-Date {
    #需要中文locale
    $str = (Get-Date -Format "yyyy年MM月dd日 dddd HH时mm分ss秒 CST").ToCharArray()
    if ($str[5] -ceq '0') { $str[5] = ' ' }
    if ($str[8] -ceq '0') { $str[8] = ' ' }
    -join $str
}
Function Set-VC-env {
    Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell -VsInstallPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" `
        -DevCmdArguments "-arch=x64 -host_arch=x64" -SkipAutomaticLocation
}
#解决Get-Childitem不能获知文件夹大小的问题
Function Get-ChildSize {
    Get-ChildItem @args -Force |
    ForEach-Object -Parallel {
        #Onedrive为reparsepoint，却非symlink，若需改
        #改之为$_.Linktype -ceq "Junction","SymLink?"
        $LengthOrTarget = ""
        try {
            $LengthOrTarget = $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint ? $_.Target :
            -not ($_.Attributes -band [System.IO.FileAttributes]::Directory) ? $_.Length:
            (Get-ChildItem $_ -Recurse -Force -File -ErrorAction Stop | Measure-Object -Sum Length).Sum
        }
        catch [System.UnauthorizedAccessException] { $LengthOrTarget = "`e[31mAccess Denied" }
        
        $_ | Select-Object Mode, LastWriteTime, @{Name = "LengthOrTarget"; Expression = { $LengthOrTarget } }, Name
    }
}
Function Update-PowerShell {
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Preview"
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