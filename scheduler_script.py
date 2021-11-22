#!/usr/bin/env python3

import os
import requests
import json
import time

url = "http://10.104.235.97:8080/auth/realms/test/protocol/openid-connect/token"

payload=f'client_id=binder-oauth-client-public&grant_type=refresh_token&refresh_token={os.environ["KC_REFRESH_TOKEN"]}'
headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
}

response = requests.request("POST", url, headers=headers, data=payload)

with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(json.loads(response.json()))

def run():
    while True:
        with open('data.json') as f:
            json_data = json.load(f)
            payload = f'client_id=binder-oauth-client-public&grant_type=refresh_token&refresh_token={json_data["refresh_token"]}'
        response = requests.request("POST", url, headers=headers, data=payload)
        with open('data.json', 'w', encoding='utf-8') as f:
            json.dump(json.loads(response.json()))
        time.sleep(120)

if __name__ == "__main__":
    run()
