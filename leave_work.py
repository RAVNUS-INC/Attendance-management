import time, requests, hashlib, hmac, base64, os, sys

from dotenv import load_dotenv
load_dotenv()

def make_signature():
    nl = '\n'

    timestamp = str(int(time.time() * 1000))
    access_key = os.environ.get("access_key")
    secret_key = os.environ.get("secret_key")
    method = "POST"
    uri = "/timeclock/apigw/v1/company/e065a8c6-2ab5-41a7-a4de-bf70c9a08142/timeclock/check"

    signature = f"{method} {uri}{nl}{timestamp}{nl}{access_key}"

    signature_bytes = signature.encode('utf-8')
    secret_key_bytes = secret_key.encode('utf-8')
    hashed = hmac.new(secret_key_bytes, signature_bytes, hashlib.sha256).digest()
    signature_base64 = base64.b64encode(hashed).decode('utf-8')

    return timestamp, access_key, signature_base64

timestamp, access_key, signature = make_signature()

url = 'https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/e065a8c6-2ab5-41a7-a4de-bf70c9a08142/timeclock/check'
headers = {
    'x-ncp-apigw-api-key': os.environ.get("API-key"),
    'x-ncp-apigw-timestamp': timestamp,
    'x-ncp-iam-access-key': access_key,
    'x-ncp-apigw-signature-v2': signature,
    'Content-Type': 'application/json',
}

data = {
    "locale": "ko_KR",
    "commuteType": "on",
    "companyId": "e065a8c6-2ab5-41a7-a4de-bf70c9a08142",
    "emailId": "stopdragon@ravnus.com",
    "basicYmd": "20231012",
    "onYmdhm": "202310120906"
}

response = requests.post(url, headers=headers, json=data)

print(response.status_code)
print(response.text)
