# cp-snmp

This repository contains tools for Check Point (mainly Gaia) to work with SNMP and extend the built-in functionality.

The tools are sorted in directories:

## extend

This directory contains programs used to implement custom OIDs.

* `cert_info` - obtain information about ICA and SIC certificates, mainly expiration date
  * See examples in `userDefinedSettings_examples.conf`.
  * Info about certificates validity:
    * ICA - valid for 20+ years, but not over the Unix epoch 32-bit 2038-01-19 03:14:07 UTC
    * SIC - valid for 5 years
    * IKE - valid for 1 year

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

## Testing the deployment

For testing run the script `tools/snmp_test.bash`

It will add a temporary SNMP user, run `snmpwalk` on few usual OIDs and then run `snmpwalk`
on the custom OIDs. Check if there are the wanted OIDs with expected values.

If complaints about `configuration lock present` appear, run `clish -c 'lock database override'`
to override the lock.

### Preparing snmp tools

You can prepare the default parameters for the Net-snmp tools . The following settings were
tested on Check Point Gaia. The testing script (above) already makes this preparation except
for the username and password.

``` bash
mkdir -p ~/.snmp/mibs/
ln -s "$CPDIR/lib/snmp/chkpnt.mib" ~/.snmp/mibs/
cat > ~/.snmp/snmp.conf <<+++END
defVersion              3
defSecurityName         username
defSecurityLevel        authPriv

defAuthType             SHA-256
defPrivType             AES

defPassphrase           password
+++END
```
