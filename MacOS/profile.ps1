#以上加载跨平台设置
. $HOME/.profile.ps1

#以下设置Host
$HostsFile = "/etc/hosts"
Function Clear-DnsClientCache {
    zsh -c -f "sudo killall -HUP mDNSResponder"
}
Function Get-BrewDeps {
    $s = brew deps --installed --formula
    $t = $s | ForEach-Object { $_.Split(':', 2)[0] }
    $l = $s | ForEach-Object { $_.Split(':', 2)[1].Split(' ') | ForEach-Object { $_ } } | Select-Object -Unique
    $t | ForEach-Object { if (-not $l.Contains($_)) { $_ } } 
}
Function Update-All([switch]$NoDownload, [switch]$NoSudo){
    Write-Output "brew升级"
    brew update 
}
Function Update-tlmgr-fonts {
    sudo tlmgr conf texmf OSFONTDIR (Get-ChildItem (Get-Item /System/Library/Assets*) *Font*)
}

Function Get-Elevate-Command ($Command){
    if ($env:USER -eq "root"){
        return $false
    }
    else{
        sudo pwsh-preview -c "$Command"
        return $true
    }
}