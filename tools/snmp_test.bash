#!/bin/bash

# snmp_test.bash
# This script prepares the environment for SNMP tests on Check Point Gaia.
# Currently it supports only SNMPv3.

# ------ Configuration ------

# These OID will be tested with snmpwalk.
snmpwalk_test_oids=(
    "SNMPv2-MIB::sysName"
    "IF-MIB::ifDescr"
    "NET-SNMP-EXTEND-MIB::nsExtendOutput2Table"
)

# SNMPv3 options for the testing user.
security_level="authPriv"
privacy_protocol="AES"
authentication_protocol="SHA-256"

# Generate a random username and password for the testing user.
username="snmp_test_$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 4)"
# The generated password must be at least 8 and at most 128 characters long.
# Tested on Gaia R81.10.
password="$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 50)"

# Non-zero value enables debug output.
_debug=0

# ------ End of Configuration ------


# Check if the clish lock is held by another session. If so, override it.
clish_take_lock () {
    if clish -c 'show config-lock' | grep -q -F CLINFR0771 ; then
        # If show config-lock returns:
        # CLINFR0771  Config lock is owned by ... We know that other session has the lock.
        if [ "$_debug" -gt 0 ] ; then
            printf 'Overriding clish lock.\n'
        fi
        clish -c 'lock database override' | grep -v -F CLINFR0771
        # Note: The command shows CLINFR0771  Config lock is owned by ...
        # but it helps to override the lock.
    fi
}

authentication_protocol_clish="$(printf %s "$authentication_protocol" | tr -d - )"

mkdir -vp ~/.snmp/mibs/
if [ ! -e ~/.snmp/mibs/chkpnt.mib ] ; then
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

clish_add_snmp_usm_user=\
"add snmp usm user $username security-level $security_level \
auth-pass-phrase $password privacy-pass-phrase $password \
authentication-protocol $authentication_protocol_clish privacy-protocol $privacy_protocol"

if [ "$_debug" -gt 0 ] ; then
    printf 'Generated username: %s\n' "$username"
    printf 'Generated password: %s\n' "$password"
    printf 'Command length: %d\n' "${#clish_add_snmp_usm_user}"
    # printf 'Command: %s\n' "$clish_add_snmp_usm_user"
fi

# Remove the temporary testing user before exiting.
cleanup () {
    clish -c "delete snmp usm user $username"
    if [ "$_debug" -gt 0 ] ; then
        printf 'Removed temporary testing user %s\n' "$username"
    fi
}

clish_take_lock
trap cleanup EXIT

clish -c "$clish_add_snmp_usm_user"

# Options in snmp.conf:
# -v3 -l authPriv -a "$authentication_protocol" -x "$privacy_protocol"

printf 'Testing snmpwalk on localhost with temporary user %s\n\n' "$username"

for oid in "${snmpwalk_test_oids[@]}" ; do
    printf -- '--- snmpwalk %s ---\n' "$oid"
    snmpwalk -u "$username" -A "$password" -X "$password" localhost "$oid"
    printf \\n
done

# If we did not exit yet, perform the cleanup explicitly.

cleanup
trap - EXIT
