import sys, os, hashlib, hmac ,base64, requests, time
from dotenv import load_dotenv

load_dotenv()

timestamp = int(time.time() * 1000)
timestamp = str(timestamp)

def	make_signature():
  access_key = os.environ.get("access_key")
  secret_key = os.environ.get("secret_key")
  secret_key = bytes(secret_key, 'UTF-8')
  method = "POST"
  uri = "https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/e065a8c6-2ab5-41a7-a4de-bf70c9a08142/timeclock/check"

  message = method + " " + uri + "\n" + timestamp + "\n" + access_key
  message = bytes(message, 'UTF-8')
  signingKey = base64.b64encode(hmac.new(secret_key, message, digestmod=hashlib.sha256).digest())
  return signingKey

def	leave_work():  
  uri = "https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/e065a8c6-2ab5-41a7-a4de-bf70c9a08142/timeclock/check"
  http_header = {
    'Content-Type': 'application/json',
    'x-ncp-apigw-api-key': os.environ.get("API-key"),
    'x-ncp-apigw-timestamp': timestamp,
    'x-ncp-iam-access-key': os.environ.get("access_key"),
    'x-ncp-apigw-signature-v2': make_signature(),
    }
  content = {
    "locale": "ko_KR",
    "commuteType": "off",
    "companyId": "e065a8c6-2ab5-41a7-a4de-bf70c9a08142",
    "emailId": "stopdragon@ravnus.com",
    "basicYmd": "20231006",
    "onYmdhm": "202310062139"  
  }
  response = requests.post(uri, headers=http_header, data=content)

  print(response.json())
  print("response: ", response)
  print("response.text: ", response.text)
