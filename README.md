# cp-snmp

This repository contains tools for Check Point (mainly Gaia) to work with SNMP and extend the built-in functionality.

The tools are sorted in directories:

## extend

This directory contains programs used to implement custom OIDs.

* `cert_info` - obtain information about ICA and SIC certificates, mainly expiration date
  * See examples in `userDefinedSettings_examples.conf`.

### Working with extend OIDs

1. Add `extend` directives to `/etc/snmp/userDefinedSettings.conf`
   Examples are in this repository in
   `extend/userDefinedSettings_examples.conf`
2. Restart snmp daemon:
   `clish -c 'set snmp agent off' && clish -c 'set snmp agent on'`
3. Test reading the OIDs:
``` bash
# Table showing first line of output of all extend custom OIDs:
snmptable localhost NET-SNMP-EXTEND-MIB::nsExtendOutput1Table
# Table showing all lines of output:
snmptable localhost NET-SNMP-EXTEND-MIB::nsExtendOutput2Table
# Showing values of all extended OIDs:
snmpwalk localhost NET-SNMP-EXTEND-MIB::nsExtendOutput1Line
# Showing value of single extended OID (double quotes are necessary):
snmpget localhost 'NET-SNMP-EXTEND-MIB::nsExtendOutput1Line."cert_ica_expi"'
# Parameters of the extended OIDs:
snmpwalk localhost NET-SNMP-EXTEND-MIB::nsExtendObjects
```

## Preparing snmp tools

``` bash
mkdir -p ~/.snmp/mibs/
ln -s "$CPDIR/lib/snmp/chkpnt.mib" ~/.snmp/mibs/
cat >~.snmp/snmp.conf <<+++END
defVersion              3
defSecurityName         username
defSecurityLevel        authPriv

defAuthType             SHA-256
defPrivType             AES

defPassphrase           password
+++END
```
