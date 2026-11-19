#!/bin/sh
tar -czf /opt/backups/site-$(date +%s).tar.gz /var/www/html
