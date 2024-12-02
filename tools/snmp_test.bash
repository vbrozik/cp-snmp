#!/bin/bash

# snmp_test.bash
# This script prepares the environment for SNMP tests on Check Point Gaia.
# Currently it supports only SNMPv3.


snmpwalk_test_oids=(
    "SNMPv2-MIB::sysName"
    "IF-MIB::ifDescr"
    "NET-SNMP-EXTEND-MIB::nsExtendOutput2Table"
)

security_level="authPriv"
privacy_protocol="AES"
authentication_protocol="SHA-256"

random_username="snmp_test_$(tr -dc A-Za-z0-9 </dev/urandom | head -c 4)"
random_password="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 10)"

# Use credentials from the environment if available
: "${username:=$random_username}"
: "${password:=$random_password}"

# ------------------------------

authentication_protocol_clish="$(printf %s "$authentication_protocol" | tr -d - )"

mkdir -vp ~/.snmp/mibs/
if [ ! -e ~/.snmp/mibs/chkpnt.mib ]; then
    ln -vs "$CPDIR/lib/snmp/chkpnt.mib" ~/.snmp/mibs/
fi
cat > ~/.snmp/snmp.conf << +++END+++
defVersion              3
defSecurityLevel        $security_level
defAuthType             $authentication_protocol
defPrivType             $privacy_protocol
+++END+++

# Other possible options:
# defSecurityName         $username
# defPassphrase           $password

# Expected SNMP agent configuration:
# clish -c "set snmp agent on"
# clish -c "set snmp agent-version v3"

clish -c \
    "add snmp usm user $username security-level $security_level \
    auth-pass-phrase $password privacy-pass-phrase $password \
    privacy-protocol $privacy_protocol authentication-protocol $authentication_protocol_clish"

# Options in snmp.conf:
# -v3 -l authPriv -a "$authentication_protocol" -x "$privacy_protocol"

printf %s\\n\\n "Testing snmpwalk on localhost with temporary user $username"

for oid in "${snmpwalk_test_oids[@]}"; do
    printf %s\\n "--- snmpwalk $oid ---"
    snmpwalk -u "$username" -A "$password" -X "$password" localhost "$oid"
    printf \\n
done

clish -c "delete snmp usm user $username"
