#!/bin/bash

{% for stack in docker.stacks %}
cd '{{ conf_directory }}/docker/{{ stack }}'
echo Upgrading stack {{ stack }}

docker compose pull
docker compose up -d
docker image prune -f

{% endfor %}
