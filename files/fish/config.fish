if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias bat=batcat
# Kot's HDD aliases
alias hddlist='printf "/dev/%s\n" $(lsblk -J -o name,rota | jq -r ".blockdevices[] | select(.rota).name")'
alias hddstate='hdparm -C $(hddlist)'
alias hddstop='hdparm -y $(hddlist)'

set -gx EDITOR hx
set -gx VISUAL hx
set -gx DOCKER_API_VERSION 1.52

fish_add_path -gP ~/bin

function diskid
    lsblk -JO | jq -r '.blockdevices[] | (if .hctl then (.hctl | split(":")[0] | tonumber | . + 1) else "-" end) as $bay | "\(.name) = \(.serial):\(.model) (WWN \(.wwn)) (BAY \($bay))"'
end
