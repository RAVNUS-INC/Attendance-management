#!/bin/bash

LDAP_URI="ldap://localhost"
BASE_DN="ou=users,dc=ravnus,dc=com"
BIND_DN="cn=admin,dc=ravnus,dc=com"
LDAP_PASS="비밀번호 여기에 입력"

CURRENT_UIDNUM=$(ldapsearch -x -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -b "$BASE_DN" "(uidNumber=*)" uidNumber 2>/dev/null \
  | grep uidNumber | awk '{print $2}' | sort -n | tail -n1)

ldapsearch -x -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS" -b "$BASE_DN" "(objectClass=posixAccount)" dn uid uidNumber gidNumber homeDirectory memberOf 2>/dev/null \
| awk -v max_uid="$CURRENT_UIDNUM" '
BEGIN { RS=""; FS="\n" }

{
  dn=""; uid=""; uidNumber=""; gidNumber=""; homeDirectory=""; memberOf=""; group_cn=""; group_gid=""

  for (i = 1; i <= NF; i++) {
    if ($i ~ /^dn: /) dn = substr($i, 5)
    if ($i ~ /^uid: /) uid = substr($i, 6)
    if ($i ~ /^uidNumber: /) uidNumber = substr($i, 12)
    if ($i ~ /^gidNumber: /) gidNumber = substr($i, 12)
    if ($i ~ /^homeDirectory: /) homeDirectory = substr($i, 17)
    if ($i ~ /^memberOf: /) memberOf = substr($i, 11)
  }

  # dn, uid 없으면 skip
  if (dn == "" || uid == "") next

  split(memberOf, parts, ",")
  for (j in parts) {
    if (parts[j] ~ /^cn=/) {
      group_cn = substr(parts[j], 4)
      break
    }
  }

  if (group_cn != "") {
    cmd = "ldapsearch -x -H " LDAP_URI " -D \"" BIND_DN "\" -w \"" LDAP_PASS "\" -b \"ou=groups,dc=ravnus,dc=com\" \"(cn=" group_cn ")\" gidNumber 2>/dev/null"
    while ((cmd | getline line) > 0) {
      if (line ~ /^gidNumber: /) {
        group_gid = substr(line, 12)
        break
      }
    }
    close(cmd)
  }

  new_uidNumber = (uidNumber == "" || uidNumber == "1000") ? ++max_uid : uidNumber
  new_gidNumber = (group_gid != "" && gidNumber != group_gid) ? group_gid : gidNumber
  new_home = (homeDirectory != "/home/" uid) ? "/home/" uid : homeDirectory

  # 수정할 항목이 있을 경우에만 출력
  if (new_uidNumber != uidNumber || (group_gid != "" && gidNumber != new_gidNumber) || new_home != homeDirectory) {
    print "dn: " dn
    print "changetype: modify"
    if (uidNumber != new_uidNumber) {
      print "replace: uidNumber\nuidNumber: " new_uidNumber "\n-"
    }
    if (group_gid != "" && gidNumber != new_gidNumber) {
      print "replace: gidNumber\ngidNumber: " new_gidNumber "\n-"
    }
    if (homeDirectory != new_home) {
      print "replace: homeDirectory\nhomeDirectory: " new_home "\n-"
    }
    print ""
    printf("✅ %s 수정됨: uidNumber=%s, gidNumber=%s, home=%s\n", uid, new_uidNumber, new_gidNumber, new_home) > "/dev/stderr"
  }
}' | ldapmodify -x -H "$LDAP_URI" -D "$BIND_DN" -w "$LDAP_PASS"
