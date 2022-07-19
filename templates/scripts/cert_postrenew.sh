#!/bin/bash

set -e

SDIR=/etc/letsencrypt/live/{{ hostname }}
DDIR=/etc/ssl/private
# Proxy host
HOST=root@playground.dawnflash.cz

# reload nginx
nginx -s reload
# sync cert with IPv4 proxy
scp -q $SDIR/fullchain.pem $HOST:$DDIR/{{ hostname }}.pem
scp -q $SDIR/privkey.pem $HOST:$DDIR/{{ hostname }}.key

ssh $HOST "nginx -t && nginx -s reload"
