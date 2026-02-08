#!/bin/bash
echo "Configuring web server at $(date)" >> /var/log/contoso-config.log
nginx -v >> /var/log/contoso-config.log
