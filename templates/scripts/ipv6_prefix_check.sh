#!/bin/bash

CF_ZONE={{ cloudflare.zone }}
TG_CHAT={{ telegram.chat }}
TG_TOKEN={{ telegram.token }}

TG_BASE="https://api.telegram.org/bot${TG_TOKEN}"
DKR_CONFIG=/etc/docker/daemon.json
INTF={{ network.uplink }}
SFX="::abcd"
PLAN=/etc/netplan/{{ network.netplan }}
SEL='\s[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*'

tg_notify () {
  echo Sending TG notification
  MSG="[NAS Networking] IPv6 changed: $OLD_ADDR -> $NEW_ADDR\nPlease update Ansible configuration."
  curl -s "$TG_BASE/sendMessage" -d "chat_id=$TG_CHAT" -d "text=$MSG"
}

dkr_update () {
  echo Updating Docker config
  sed -i "s/$OLD_PFX/$PFX/" $DKR_CONFIG
  systemctl restart docker
}

cf_update() {
  echo Updating Cloudflare AAAA record
  ZID=$(cf_request GET "zones?name=$CF_ZONE" | jq -r .result[0].id)
  RIDS=$(cf_request GET "zones/$ZID/dns_records?type=AAAA&content=$OLD_ADDR" | jq -r .result[].id)
  for RID in $RIDS; do
    cf_request PATCH "zones/$ZID/dns_records/$RID" "{\"content\":\"$NEW_ADDR\"}" | jq -r '.result.name + ": " + (.success | tostring)'
  done
}

cf_request() {
  curl -X $1 -s "https://api.cloudflare.com/client/v4/$2" \
    -H "Content-Type:application/json" \
    -H "Authorization: Bearer $CF_TOKEN" \
    -d ${3:-"{}"}
}

while true; do
  PFX=$(ip -6 addr show $INTF scope global | egrep -o 'inet6.*/64' | egrep -o $SEL | tr -d ' ' | head -1)
  if [ -z $PFX ]; then
    echo Failed to acquire /64 prefix
    sleep 60
    continue
  fi
  NEW_ADDR=${PFX}${SFX}
  OLD_ADDR=$(egrep -o "\S+$SFX" $PLAN)
  OLD_PFX=$(sed "s/$SFX//" <<< $OLD_ADDR)

  if [ $NEW_ADDR = $OLD_ADDR ]; then
    sleep 60
    continue
  fi

  echo "Replacing IPv6: $OLD_ADDR -> $NEW_ADDR"
  sed -i "s/$OLD_ADDR/$NEW_ADDR/" $PLAN
  netplan apply
  sleep 5
  dkr_update
  cf_update
  tg_notify

  sleep 60
done
