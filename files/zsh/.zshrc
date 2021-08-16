export ZSH="/root/.oh-my-zsh"
export EDITOR=vim
export VISUAL=vim
export PATH=$PATH:/root/bin

ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

alias grep="grep --color"
alias ip="ip -c"

# Kot's HDD aliases
alias hddlist='printf "/dev/%s\n" $(lsblk -J -o name,rota | jq -r ".blockdevices[] | select(.rota).name")'
alias hddstate='hdparm -C $(hddlist)'
alias hddstop='hdparm -y $(hddlist)'
alias diskid=$'lsblk -JO | jq -r \'.blockdevices[] | .name + " = " + .model + ":" + .serial + " (WWN: " + .wwn + ")"\''
