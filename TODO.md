# TODO

* `cert_info`
  * Change the meaning of the third argument (now conversion) to a generic parameter.
    * For `expiration` it will be the date / time format as now.
    * For `expires` (now `expNmonths`) it will be a number of months (?) for the expiration check.
* `snmp_test.bash`
  * Use `clish -c 'show config-lock'` to decide if to run `clish -c 'lock database override'`.
