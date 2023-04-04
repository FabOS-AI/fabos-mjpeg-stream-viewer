#!/bin/sh
JSON_STRING='window.configs = { \
  "VUE_APP_AAS_REGISTRY_HOST":"'"${VUE_APP_AAS_REGISTRY_HOST}"'", \
  "VUE_APP_AAS_ID":"'"${VUE_APP_AAS_ID}"'", \
}'
sed -i "s@// CONFIGURATIONS_PLACEHOLDER@${JSON_STRING}@" /usr/share/nginx/html/index.html

echo "loading config: ${JSON_STRING}'"

echo "Starting Nginx"
nginx -g 'daemon off;'
