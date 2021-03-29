#不要用ShouldProcess
#设置python环境
Function Update-Pip {
    pip list --outdated | Select-Object -Skip 2 | ForEach-Object { pip install -U $_.Split([char]' ', 2)[0] }
}

Import-Module posh-git, oh-my-posh
Set-PoshPrompt -Theme $HOME\.oh-my-posh.omp.json

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
Write-Host -NoNewline "`e[5 q"
#.NET
# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Function Edit-Hosts {
    [ValidateSet("CommentAll", "UnCommentAll", "Normal")]
    [string]$CommentType = "Normal"
    switch -Exact ($CommentType) {
        "CommentAll" {}
        "UnCommentAll" {}
        "Normal" { code $HostsFile --wait }
    }
    Clear-DnsClientCache | Out-Null
}
function Get-Hosts ([string]$URL) {
    $HTML = (curl -L --silent "https://www.ipaddress.com/search/$URL") | Out-String
    if (-not $?) {
        throw "Curl错误"
    }
    $Start = $HTML.IndexOf("ipv4/") + 5
    $Length = $HTML.IndexOfAny([char[]]('\', '"'), $Start) - $Start
    return $HTML.Substring($Start, $Length)
}
Function Update-Hosts ([switch]$OutVariable) {
    #需要Administrator
    If (-not $OutVariable -and (Get-Elevate-Command "Update-Hosts")) {
        return
    }

    $Content = Get-Content $HostsFile | ForEach-Object {
        $Line = $_
        $SplitComment = $Line.Split([char]"#", 2)
        $URL = $SplitComment[0].Split([char[]](" ", "`t"), 2, [System.StringSplitOptions]::RemoveEmptyEntries)[1]
        if ($URL -and $URL -cnotmatch "host") {
            try {
                (Get-Hosts $URL).PadLeft(15) + "    " + $URL + ($SplitComment[1] ? " `t#" + $SplitComment[1] : "")
            }
            catch [System.Management.Automation.ErrorRecord] {
                Write-Output "Curl错误：$URL" ; $Line
            }
        }
        else {
            $Line
        }
    }

    if ($OutVariable) {
        return $Content
    }
    
    Set-Content $HostsFile $Content
    Clear-DnsClientCache | Out-Null
}
#MacOS残留的.DS_Store, ._*可以用该函数删除
Function Remove-DS-Store {
    Get-ChildItem -Recurse -Include ._*, .DS_Store -Force @args | Remove-Item -Force
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
        catch [System.UnauthorizedAccessException] {
            $LengthOrTarget = "`e[31mAccess Denied"
        }
        $_ | Select-Object Mode, LastWriteTime, @{Name = "LengthOrTarget"; Expression = { $LengthOrTarget } }, Name
    }
}
Function Update-PowerShell {
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -Preview$($IsWindows ? ' -UseMSI' : '')"
}
Function Remove-OutdatedModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Get-ChildItem $env:PSModulePath.Split([char]($IsWindows ? ';' : ':'), 2)[0] | ForEach-Object {
        Get-ChildItem $_ | Sort-Object { [version]$_.Name } -Descending | Select-Object -Skip 1 | Remove-Item -Force -Recurse
    }
}
Function Get-TS-Translated {
    param (
        [Parameter(Position = 0)]
        [string]$ts,
        [string]$lang="zh",
        [ValidateSet("google", "bing", "yandex", "apertium")] 
        [string]$engine = "bing"
    )
    lconvert -if ts -of po -o temp.po $ts
    $po = Get-Content temp.po
    for ($i = 0; $i -lt $po.Count; $i++) {
        if ($po[$i].StartsWith("msgid")) {
            $sentence = $po[$i].Split([char]'"', 3)[1]
            $translated = trans -brief """$sentence""" -e $engine -t $lang
            $translated
            while ($translated.StartsWith("Did you mean:")) {
                $translated = trans -brief """$($translated.Substring(13))""" 
            }
            $po[++$i] = "msgstr """ + $translated + """"
        }
    }
    Set-Content temp.po $po
    lconvert -if po -of ts -o $ts temp.po
    #Remove-Item ./temp.po
}