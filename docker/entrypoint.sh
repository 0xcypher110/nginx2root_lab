#!/bin/sh
crond -l 2 &
exec /usr/local/nginx/sbin/nginx -g "daemon off;"
