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

# pure prompt
set -U pure_show_jobs true
set -U pure_color_primary cyan
set -U pure_show_system_time true
set -U pure_show_exit_status true
set -U pure_convert_exit_status_to_signal true
set -U pure_show_prefix_root_prompt true
set -U pure_show_subsecond_command_duration true
set -U pure_threshold_command_duration 1

function diskid
    lsblk -JO | jq -r '.blockdevices[] | (if .hctl then (.hctl | split(":")[0] | tonumber | . + 1) else "-" end) as $bay | "\(.name) = \(.serial):\(.model) (WWN \(.wwn)) (BAY \($bay))"'
end
