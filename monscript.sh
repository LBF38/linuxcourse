#!/usr/bin/env bash
echo "coucou"

sudo tar -c /etc/ssh/ -f /root/configs_server.tar
sudo tar -r /etc/nginx -f /root/configs_server.tar
sudo tar -r /var/spool/cron/crontabs -f /root/configs_server.tar