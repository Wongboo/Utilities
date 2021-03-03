echo apt update ...
sudo apt update && sudo apt upgrade
echo rust update ...
rustup self update && rustup update
echo pip update ...
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
echo zsh upgrade ...
git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull