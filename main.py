import os, requests
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

# 출근
POST https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/e065a8c6-2ab5-41a7-a4de-bf70c9a08142/timeclock/check
HHOST: workplace.apigw.ntruss.com
 Content-Type: application/json
 x-ncp-apigw-timestamp: datetime.datetime.now()
 x-ncp-apigw-api-key: os.environ.get("API-key")
 x-ncp-iam-access-key: os.environ.get("access-key")
 x-ncp-apigw-signature-v1: os.environ.get("secret-key")
{
  "locale": "ko_KR",
  "commuteType": "on",
  "companyId": "e065a8c6-2ab5-41a7-a4de-bf70c9a08142",
  "emailId": "stopdragon@ravnus.com",
  "basicYmd": "20231005",
  "onYmdhm": "202310050855"
}

# 퇴근
POST https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/e065a8c6-2ab5-41a7-a4de-bf70c9a08142/timeclock/check
HHOST: workplace.apigw.ntruss.com
 Content-Type: application/json
 x-ncp-apigw-timestamp: datetime.datetime.now()
 x-ncp-apigw-api-key: DUxjP4HYTP8V7khBkgywdDHQjKuaYWGrppHKpvdv
 x-ncp-iam-access-key: D78BB444D6D3C84CA38A
 x-ncp-apigw-signature-v2: WTPItrmMIfLUk/UyUIyoQbA/z5hq9o3G8eQMolUzTEo=
{
  "locale": "ko_KR",
  "commuteType": "off",
  "companyId": "e065a8c6-2ab5-41a7-a4de-bf70c9a08142",
  "emailId": "green@naver.com",
  "empExternalKey": "",
  "basicYmd": "20190918",
  "offYmdhm": "201909181803"
}


