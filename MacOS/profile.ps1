#以上加载跨平台设置
. $HOME/.profile.ps1

#以下设置Host
$HostsFile = "/etc/hosts"
Function Clear-DnsClientCache{
    zsh -c -f "sudo killall -HUP mDNSResponder"
}