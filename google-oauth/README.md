# How to

1. Create Application: https://console.cloud.google.com/projectcreate
2. Create Client Creds: https://console.cloud.google.com/auth/clients/create (select "Desktop")
3. Download as JSON
4. Convert JSON for better readability `cat client*.json | jq > creds.json`
5. Adapt redirect_uri to http://localhost:8080 (as port 80 requires root)
6. Run get_tokens.py:
   ```
   python3 -m venv venv
   . venv/bin/activate
   pip install -r requirements.txt
   ./get_tokens.py
   ```
7. Build docker image
8. Create and run docker container with docker compose
9. After first start your connections might be rejected because of the container subnet address. Please adapt it in the env file and restart.

