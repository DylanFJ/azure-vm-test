#!/bin/bash
scp ./ubuntu-lts/files/dev/nginx/dev.site root@azure-vm:/tmp/
ssh root@azure-vm 'mv /tmp/dev.site /etc/nginx/sites-enabled/'
ssh root@azure-vm 'systemctl restart nginx'