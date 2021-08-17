#!/bin/bash

SDIR=/etc/letsencrypt/live/{{ hostname }}
DDIR=/etc/ssl/private

# reload nginx
service nginx reload
# sync cert with IPv4 proxy
scp -q $SDIR/fullchain.pem root@dawnflash.cz:$DDIR/{{ hostname }}.pem
scp -q $SDIR/privkey.pem root@dawnflash.cz:$DDIR/{{ hostname }}.key

ssh root@dawnflash.cz "apache2ctl -k graceful"
