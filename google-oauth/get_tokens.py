#!/usr/bin/env python3

from google_auth_oauthlib.flow import InstalledAppFlow
import json

flow = InstalledAppFlow.from_client_secrets_file(
    'creds.json',
    scopes=['https://mail.google.com/'],
)

creds = flow.run_local_server(port=8080)

json_creds = {}
with open('creds.json', 'r') as f:
    json_content = json.load(f)
    json_creds = json_content.get('installed', {})
with open('gmail.env', 'w+') as f:
    f.write('__SMTP_SERVER___=smtp.gmail.com\n')
    f.write('__SMTP_TLS_PORT_=587\n')
    f.write('__SMTP_USER_ADDR=nas@klemm-dachau.de\n')
    f.write(f'__ACCESS_TOKEN__={ creds.token }\n')
    f.write(f'__REFRESH_TOKEN_={ creds.refresh_token }\n')
    f.write(f'__CLIENT_ID_____={ json_creds.get("client_id") }\n')
    f.write(f'__PROJECT_ID____={ json_creds.get("project_id") }\n')
    f.write(f'__CLIENT_SECRET_={ json_creds.get("client_secret") }\n')
    f.write('__MY_NETWORKS___=192.168.2.0/24,192.168.3.0/24,192.168.222.0/24,172.0.0.0/8,127.0.0.1/8\n')
    f.write('__RELAY_HOST____=smtp.gmail.com:587\n')
