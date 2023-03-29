#!/bin/sh
JSON_STRING='window.configs = { \
  "VUE_APP_AAS_SERVER_HOST":"'"${VUE_APP_AAS_SERVER_HOST}"'", \
  "VUE_APP_AAS_ID":"'"${VUE_APP_AAS_ID}"'", \
}'
sed -i "s@// CONFIGURATIONS_PLACEHOLDER@${JSON_STRING}@" /usr/share/nginx/html/index.html

echo "loading AAS Host: ${JSON_STRING}'"

# DEFAULT_URL="http://backend:8000/docs"

# # BACKEND_URL="${BACKEND_URL:-${DEFAULT_URL}}"
# if [ -z "${BACKEND_URL}" ]; then 
#     BACKEND_URL=${DEFAULT_URL}
#     echo "loaded variable BACKEND_URL from default: ${BACKEND_URL}'"
# else 
#     echo "loaded variable BACKEND_URL from environment: ${BACKEND_URL}'"
# fi

# # Wait until Backend is running
# until curl -m 5 -s --location --request GET "$BACKEND_URL" > /dev/null; do
#   echo "Backend is unavailable at '${BACKEND_URL}' -> sleeping"
#   sleep 1
# done

echo "Starting Nginx"
nginx -g 'daemon off;'
