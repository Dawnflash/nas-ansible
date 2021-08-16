#!/bin/bash

SDIR=/etc/letsencrypt/live/nas.dawnflash.cz
DDIR=/etc/ssl/private

# reload nginx
service nginx reload
# sync cert with IPv4 proxy
scp -q $SDIR/fullchain.pem root@dawnflash.cz:$DDIR/nas.dawnflash.cz.pem
scp -q $SDIR/privkey.pem root@dawnflash.cz:$DDIR/nas.dawnflash.cz.key

ssh root@dawnflash.cz "apache2ctl -k graceful"
