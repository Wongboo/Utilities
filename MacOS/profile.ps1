#以上加载跨平台设置
. $HOME/.profile.ps1

#以下设置Host
$HostsFile = "/etc/hosts"
function Clear-DnsClientCache {
    zsh -c -f "sudo killall -HUP mDNSResponder"
}
function Get-BrewDeps {
    $s = brew deps --installed --formula
    $t = $s | ForEach-Object { $_.Split(':', 2)[0] }
    $l = $s | ForEach-Object { $_.Split(':', 2)[1].Split(' ') | ForEach-Object { $_ } } | Select-Object -Unique
    $t | ForEach-Object { if (-not $l.Contains($_)) { $_ } } 
}
function Update-All([switch]$Sudo){
    Write-Output "brew升级"
    brew upgrade
    Write-Output "pip升级"
    Update-Pip
    Write-Output "zsh升级"
    #env ZSH="$ZSH" sh "$ZSH/tools/upgrade.sh"
    git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull
    Write-Output "rust升级"
    rustup update
    Write-Output "pwsh module升级"
    Update-Module
    if ($Sudo) {
        Write-Output "tex升级"
        sudo tlmgr update --all --self
    }
}
function Update-tlmgr-fonts {
    sudo tlmgr conf texmf OSFONTDIR (Get-ChildItem (Get-Item /System/Library/Assets*) *Font*)
}

function Get-Elevate-Command ($Command){
    if ($env:USER -eq "root"){
        return $false
    }
    else{
        sudo pwsh-preview -c "$Command"
        return $true
    }
}