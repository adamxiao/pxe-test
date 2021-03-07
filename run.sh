#!/usr/bin/env bash

docker create \
  --name=netbootxyz \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 3000:3000 \
  -p 69:69/udp \
  -p 8080:80 \
  --restart unless-stopped \
  linuxserver/netbootxyz
