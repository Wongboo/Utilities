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
if [ -n "$1" ] || [ "$1" != "notex" ]; then
    echo brew upgrade ...
    brew upgrade
    echo pip upgrade ...
    pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
    if [ "$2" != "notex" ]; then
        echo tex upgrade ...
        sudo tlmgr update --all
    fi
    echo oh-my-zsh upgrade ...
    env ZSH="$ZSH" sh "$ZSH/tools/upgrade.sh"
    echo mac app store upgrade ...
    mas outdated && mas upgrade
    echo microsoft update ...
    '/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/msupdate' -i
fi

# update
# update download
# update all
# update notex
# update download notex
# update all notex