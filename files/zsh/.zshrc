export ZSH="/root/.oh-my-zsh"
export EDITOR=vim
export VISUAL=vim
export PATH=$PATH:/root/bin
export DOCKER_API_VERSION=1.52

ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

alias grep="grep --color"
alias ip="ip -c"

# Kot's HDD aliases
alias hddlist='printf "/dev/%s\n" $(lsblk -J -o name,rota | jq -r ".blockdevices[] | select(.rota).name")'
alias hddstate='hdparm -C $(hddlist)'
alias hddstop='hdparm -y $(hddlist)'

diskid() {
  lsblk -JO | jq -r '.blockdevices[] | (if .hctl then (.hctl | split(":")[0] | tonumber | . + 1) else "-" end) as $bay | "\(.name) = \(.serial):\(.model) (WWN \(.wwn)) (BAY \($bay))"'
}
