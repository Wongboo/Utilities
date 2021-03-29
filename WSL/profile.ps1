#以上加载跨平台设置
$env:PSModulePath += ":$env:OLDPWD/Documents/PowerShell/Modules"
. $env:OLDPWD/.profile.ps1

#以下设置Host
$HostsFile = "/etc/hosts"
function Clear-DnsClientCache{
    /etc/init.d/network restart
}
