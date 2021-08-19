#!/bin/bash

{% for stack in docker.stacks %}
cd '{{ ssd_storage.root }}/docker/{{ stack }}'
echo Upgrading stack {{ stack }}

docker compose pull
docker compose up -d
docker image prune -f

{% endfor %}
