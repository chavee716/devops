#!/bin/sh

# Start nginx in the background
nginx -g 'daemon off;' &

# Start auth service
cd /app/auth-service && npm start 