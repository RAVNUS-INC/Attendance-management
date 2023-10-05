POST https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/5b8530ef-75fb-4bd1-aed4-7bba5a3f9c75/timeclock/check


/* 1회체크, 출퇴근 예시 */
POST https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/f3cf9659-782c-4508-bef9-f34c93f446df/timeclock/check
HHOST: workplace.apigw.ntruss.com
 Content-Type: application/json
 x-ncp-apigw-timestamp: 1505290625682
 x-ncp-apigw-api-key: DUxjP4HYTP8V7khBkgywdDHQjKuaYWGrppHKpvdv
 x-ncp-iam-access-key: D78BB444D6D3C84CA38A
 x-ncp-apigw-signature-v1: WTPItrmMIfLUk/UyUIyoQbA/z5hq9o3G8eQMolUzTEo=
{
  "locale": "ko_KR",
  "commuteType": "onoff",
  "companyId": "fe5f8382-aae3-4746-8d6e-f9d0545c5a9b",
  "emailId": "1year1@naver.com",
  "basicYmd": "20190918",
  "onYmdhm": "201909181559",
  "breakList":[
    {
      "startYmdhm":"201909181100",
      "endYmdhm":"201909181130"
    }
  ],
  "outWorkList":[
    {
      "startYmdhm":"201909181000",
      "endYmdhm":"201909181330"
    }
  ]
}

/* 2회체크, 출근 예시 */
POST https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/f3cf9659-782c-4508-bef9-f34c93f446df/timeclock/check
HHOST: workplace.apigw.ntruss.com
 Content-Type: application/json
 x-ncp-apigw-timestamp: 1505290625682
 x-ncp-apigw-api-key: DUxjP4HYTP8V7khBkgywdDHQjKuaYWGrppHKpvdv
 x-ncp-iam-access-key: D78BB444D6D3C84CA38A
 x-ncp-apigw-signature-v1: WTPItrmMIfLUk/UyUIyoQbA/z5hq9o3G8eQMolUzTEo=
{
  "locale": "ko_KR",
  "commuteType": "on",
  "companyId": "fe5f8382-aae3-4746-8d6e-f9d0545c5a9b",
  "emailId": "green@naver.com",
  "empExternalKey": "",
  "basicYmd": "20190918",
  "onYmdhm": "201909180855"
}

/* 2회체크, 퇴근 예시 */
POST https://workplace.apigw.ntruss.com/timeclock/apigw/v1/company/f3cf9659-782c-4508-bef9-f34c93f446df/timeclock/check
HHOST: workplace.apigw.ntruss.com
 Content-Type: application/json
 x-ncp-apigw-timestamp: 1505290625682
 x-ncp-apigw-api-key: DUxjP4HYTP8V7khBkgywdDHQjKuaYWGrppHKpvdv
 x-ncp-iam-access-key: D78BB444D6D3C84CA38A
 x-ncp-apigw-signature-v2: WTPItrmMIfLUk/UyUIyoQbA/z5hq9o3G8eQMolUzTEo=
{
  "locale": "ko_KR",
  "commuteType": "off",
  "companyId": "fe5f8382-aae3-4746-8d6e-f9d0545c5a9b",
  "emailId": "green@naver.com",
  "empExternalKey": "",
  "basicYmd": "20190918",
  "offYmdhm": "201909181803"
}