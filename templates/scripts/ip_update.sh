#!/bin/bash

# Updates public IP wherever necessary if it changes

CF_ZONE={{ cloudflare.zone }}
CF_TOKEN={{ cloudflare.token }}
HOSTNAME={{ hostname }}

INTF={{ network.uplink }}
IP6_SFX="::abcd"
PLAN=/etc/netplan/{{ network.netplan }}

tg_notify () {
  echo Sending TG notification
  MSG="*\[NAS Networking\]* IP changed: $OLD_ADDR \-\> $NEW_ADDR"
  telegram-send "$MSG"
}

cf_update() {
  echo Updating Cloudflare AAAA record
  ZID=$(cf_request GET "zones?name=$CF_ZONE" | jq -r '.result[0].id')
  RIDS=$(cf_request GET "zones/$ZID/dns_records?type=AAAA&content=$OLD_ADDR" | jq -r '.result[].id')
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

check_ipv6() {
  PFX=$(ip -6 addr show $INTF scope global | egrep -o 'inet6.*/64' | egrep -o '\s[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*' | tr -d ' ' | head -1)
  if [ -z $PFX ]; then
    echo Failed to acquire /64 prefix
    return
  fi
  NEW_ADDR=${PFX}${IP6_SFX}
  OLD_ADDR=$(egrep -o "\S+$IP6_SFX" $PLAN)
  OLD_PFX=$(sed "s/$IP6_SFX//" <<< $OLD_ADDR)

  [ $NEW_ADDR = $OLD_ADDR ] && return

  echo "Replacing IPv6: $OLD_ADDR -> $NEW_ADDR"
  sed -i "s/$OLD_ADDR/$NEW_ADDR/" $PLAN
  netplan apply
  sleep 60
  cf_update
  tg_notify
}

check_ipv4() {
  NEW_ADDR=$(dig +short txt ch whoami.cloudflare @1.1.1.1 | tr -d \")
  ZID=$(cf_request GET "zones?name=$CF_ZONE" | jq -r '.result[0].id')
  CHANGE=0
  cf_request GET "zones/$ZID/dns_records?type=A" | jq -r --arg host $HOSTNAME '.result[] | select(.name | endswith($host)) | .id' | while read RID; do
    OLD_ADDR=$(cf_request GET "zones/$ZID/dns_records/$RID" | jq -r .result.content)
    [ $OLD_ADDR = $NEW_ADDR ] && continue
    CHANGE=1
    cf_request PATCH "zones/$ZID/dns_records/$RID" "{\"content\":\"$NEW_ADDR\"}" | jq -r '.result.name + ": " + (.success | tostring)'
  done
  [ $CHANGE -eq 1 ] && tg_notify
}

while true; do
  check_ipv6
  check_ipv4

  sleep 300
done
