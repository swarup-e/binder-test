#!/bin/bash

token_result=$(curl --location --request POST 'http://10.104.235.97:8080/auth/realms/test/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'client_id=binder-oauth-client-public' \
--data-urlencode 'grant_type=refresh_token' \
--data-urlencode "refresh_token=$KC_REFRESH_TOKEN")

echo $token_result

access_token=$(echo $token_result| python3 -c \
    "import sys, json; print(json.load(sys.stdin)['access_token'])"
)

refresh_token=$(echo $token_result| python3 -c \
    "import sys, json; print(json.load(sys.stdin)['refresh_token'])"
)

/usr/bin/env NEW_ACCESS_TOKEN="${access_token}" ${*}

/usr/bin/env NEW_REFRESH_TOKEN="${refresh_token}" ${*}

/usr/bin/env LAST_TIME_RUN="$(date +%F_%H-%M-%S)"