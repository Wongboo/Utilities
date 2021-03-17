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