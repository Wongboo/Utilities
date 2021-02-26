#不要用shouldprocess
#设置python环境
Function Update-Pip {
    pip list --outdated | Select-Object -Skip 2 | ForEach-Object { pip install -U $_.Remove($_.IndexOf(' ')) }
}

#设置自动补全
$env:PSModulePath += ":$env:OLDPWD/Documents/PowerShell/Modules"
Import-Module posh-git, oh-my-posh
Set-PoshPrompt jandedobbeleer

#设置PSreadline
Import-Module PSReadLine
Function OnViModeChange {
    if ($args[0] -ceq 'Command') {
        # set the cursor to a blinking block.
        Write-Host -NoNewline "`e[1 q"
    }
    else {
        # set the cursor to a blinking line.
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
    Start-Job -Name "office升级" {
        &"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient" `
            /update user displaylevel=false forceappshutdown=true }
    Start-Process ms-settings:windowsupdate-action
    Start-Process ms-windows-store://downloadsandupdates
    Write-Output "powershell module升级"
    Update-Module
    Write-Output "pip升级"
    Update-Pip
    if (Test-Path F:\) {
        Write-Output "vcpkg升级"
        git -C "F:\vcpkg\vcpkg" pull #| Out-Null
        vcpkg update
        Write-Output "texlive升级"
        tlmgr update --self --all
    }
}
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
Function Get-ChildSize {
    Get-ChildItem @args -Force |
    ForEach-Object -Parallel {
        #Onedrive为reparsepoint，却非symlink，若需改
        #改之为$_.Linktype -ceq "Junction","SymLink?"
        try {
            $LengthOrTarget = $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint ? $_.Target :
            -not ($_.Attributes -band [System.IO.FileAttributes]::Directory) ? $_.Length:
            (Get-ChildItem $_ -Recurse -Force -File -ErrorAction Stop | Measure-Object -Sum Length).Sum
        }
        catch [System.UnauthorizedAccessException] { $LengthOrTarget = "`e[31mAccess Denied" }
        $_ | Select-Object Mode, LastWriteTime, @{Name = "LengthOrTarget"; Expression = { $LengthOrTarget } }, Name
    }
}

Function Enable-Root{
    #?
}
New-Alias sudo Enable-Root
