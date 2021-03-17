if [ "$1" != "download" ]; then
    echo brew update ...
    brew update
    echo pip update ...
    pip3 list --outdated
    if [ "$1" != "notex" ]  && [ "$2" != "notex" ]; then
        echo tex update ...
        sudo tlmgr update --list
    fi
fi
if [ -n "$1" ] && [ "$1" != "notex" ]; then
    echo brew upgrade ...
    brew upgrade
    echo pip upgrade ...
    pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
    if [ "$2" != "notex" ]; then
        echo tex upgrade ...
        sudo tlmgr update --all --self
    fi
    echo zsh upgrade ...
    #env ZSH="$ZSH" sh "$ZSH/tools/upgrade.sh"
    git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull
    echo rust upgrade ...
    rustup update
    echo pwsh module upgrade ...
    pwsh-preview -c "Update-Module"
fi

# update
# update download
# update all
# update notex
# update download notex
# update all notex