#!/bin/bash

LDAP_URI="ldap://localhost"
BASE_DN="ou=users,dc=ravnus,dc=com"
GROUP_DN="ou=groups,dc=ravnus,dc=com"
BIND_DN="cn=admin,dc=ravnus,dc=com"
LDAP_PASS="VdpTjb0Ak1N7r6Xk"

# 현재 최대 uidNumber 확인
CURRENT_UIDNUM=$(ldapsearch -x -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -b "$BASE_DN" "(uidNumber=*)" uidNumber |
  grep "^uidNumber" | awk '{print $2}' | sort -n | tail -n1)
NEW_UIDNUM=$((CURRENT_UIDNUM + 1))

ldapsearch -x -LLL -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -b "$BASE_DN" "(objectClass=posixAccount)" dn uid uidNumber gidNumber homeDirectory cn |
while IFS= read -r line; do
  if [[ $line == dn:* ]]; then
    USER_DN="${line#dn: }"
    USERNAME=$(echo "$USER_DN" | cut -d',' -f1 | cut -d'=' -f2)
    CURRENT_UIDNUM_FOR_USER=""
    CURRENT_GIDNUM_FOR_USER=""
    CURRENT_HOME=""
    CURRENT_CN=""
    MODIFY_NEEDED=false
    MOD_TEXT=""
  elif [[ $line == uidNumber:* ]]; then
    CURRENT_UIDNUM_FOR_USER="${line#uidNumber: }"
  elif [[ $line == gidNumber:* ]]; then
    CURRENT_GIDNUM_FOR_USER="${line#gidNumber: }"
  elif [[ $line == homeDirectory:* ]]; then
    CURRENT_HOME="${line#homeDirectory: }"
  elif [[ $line == cn:* ]]; then
    CURRENT_CN="${line#cn: }"
  elif [[ -z $line ]]; then
    # 가장 낮은 gidNumber 찾기
    LOWEST_GID=$(ldapsearch -x -LLL -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -b "$GROUP_DN" "(&(objectClass=posixGroup)(memberUid=$USERNAME))" gidNumber |
      grep "^gidNumber" | awk '{print $2}' | sort -n | head -n1)

    # sn, givenName 가져오기 (Base64 또는 일반값 모두 처리)
    SN=$(ldapsearch -x -LLL -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -b "$USER_DN" sn |
      awk '{ if ($1 == "sn::") { print $2 | "base64 -d" } else if ($1 == "sn:") { print $2 } }')
    GIVEN=$(ldapsearch -x -LLL -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -b "$USER_DN" givenName |
      awk '{ if ($1 == "givenName::") { print $2 | "base64 -d" } else if ($1 == "givenName:") { print $2 } }')

    EXPECTED_UIDNUM="$CURRENT_UIDNUM_FOR_USER"
    if [[ -z "$CURRENT_UIDNUM_FOR_USER" || "$CURRENT_UIDNUM_FOR_USER" == "1000" ]]; then
      EXPECTED_UIDNUM="$NEW_UIDNUM"
      NEW_UIDNUM=$((NEW_UIDNUM + 1))
    fi

    EXPECTED_GIDNUM="$LOWEST_GID"
    EXPECTED_HOME="/home/$USERNAME"
    EXPECTED_CN="${SN}${GIVEN}"

    if [[ "$CURRENT_UIDNUM_FOR_USER" != "$EXPECTED_UIDNUM" ]]; then
      MODIFY_NEEDED=true
      MOD_TEXT+=$'\nreplace: uidNumber\nuidNumber: '"$EXPECTED_UIDNUM"$'\n-'
    fi

    if [[ "$CURRENT_GIDNUM_FOR_USER" != "$EXPECTED_GIDNUM" && -n "$EXPECTED_GIDNUM" ]]; then
      MODIFY_NEEDED=true
      MOD_TEXT+=$'\nreplace: gidNumber\ngidNumber: '"$EXPECTED_GIDNUM"$'\n-'
    fi

    if [[ "$CURRENT_HOME" != "$EXPECTED_HOME" ]]; then
      MODIFY_NEEDED=true
      MOD_TEXT+=$'\nreplace: homeDirectory\nhomeDirectory: '"$EXPECTED_HOME"$'\n-'
    fi

    if [[ "$CURRENT_CN" != "$EXPECTED_CN" && -n "$EXPECTED_CN" ]]; then
      MODIFY_NEEDED=true
      MOD_TEXT+=$'\nreplace: cn\ncn: '"$EXPECTED_CN"$'\n-'
    fi

    if $MODIFY_NEEDED; then
      echo "dn: $USER_DN
changetype: modify$MOD_TEXT" > /tmp/ldapmod.ldif
      ldapmodify -x -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -f /tmp/ldapmod.ldif
      echo "✅ $USERNAME 수정 완료 → 🆙 uidNumber=$EXPECTED_UIDNUM 🛡 gidNumber=$EXPECTED_GIDNUM 🏠 home=$EXPECTED_HOME 🧾 cn=$EXPECTED_CN"
    fi
  fi
done
