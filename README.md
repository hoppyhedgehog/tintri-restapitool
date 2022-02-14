# tintri-webapitest
A public tool using the REST-API for Tintri VMStore Storage Arrays

```
# chmod 755 webapitest
```

Now we view the script usage:
```
USAGE
[197][root@ben-c7-vm]# ./webapitest
================================================================
# SCRIPT TO TEST THE REST-API AND RETURN DATA. Ver:1.8
================================================================
# webapitest [args]
================================================================
       -c            Clear saved cookie (/tmp/.webapitest.cookie.txt) & saved user info
       -u <user>    User  (default admin) [cached after 1st iteration]
       -p <pass>    User  (default tintri99) [cached after 1st iteration]
       -v <vmstore> [IF NOT on a VMStore] then specify IP or FQDN of VMStore [cached after 1st iteration]
       -i            Display brief appliance (vmstore) info
       -a            Display appliance (vmstore) info
       -h            Display HypervisorConfig Info
       -d            Display VMStore datastore properties
       -l            Log Output to file /tmp/ben-c7-vm_rest-api_output.log
       -r            Obtain VMStore computeResource info
       -A            Display REST-API-INF
       -n            Display Notification Policy
       -g            Display all Service Group Info
       -1            List all userAccounts
       -s            Display all Snapshots
       -S            Display all Active Sessions
       -C            Display all Current Sessions
       -H            DO NOT Format JSON Output to make it human readable
       -E <num>     Encryption Cypher Type
                     0  - Query (View the Current Encryption Type. Default is RC4)
                     4  - Set RC4 (Default)
                     8  - AES128
                     16 - AES256
                     28 - RC4, AES128 & AES256
       -L            Display all License info
       -T            Display all sessions for user=tintricenter
       -F <file>    Use Input File for multiple VMStores
                     FILE FORMAT:
                           username     password     vmstore_ip(or name)
                     EXAMPLE: Filename :/tmp/inputfile
                           admin        mypass99     10.122.20.27
                           admin        mypass99     10.122.21.20
       -P            Change User Password
       -U <user>    User Name to Change when -P option is specified
       -P "<pass>"  User Password to Change when -P option is specified
       -N            Obtain VMStore Notification Properties
       -Q            Strip quotes and commas in output
       -R "<role>"  User role (admin user is 'ADMIN')
       -V            Display all VM info
       -U            Display VMStore StatSummary Output
       -x            Verbose output
       -X            Debug (set -x) output
================================================================
``` 

# EXAMPLE: Now we establish the web 'cookie' and then we display the VMStore host information
```
# webapitest -u admin -p mypass1 -v 10.122.20.27 -i
[2022-02-14T11:45:30] [10.122.20.27]  Writing Encrypted Password [U2FsdGVkX1//oLK1myWFdF7vdfn5veKee9aojuQ9Brc=]--> /tmp/.webapitest.encrypted_password_cache.dat
[2022-02-14T11:45:30] [10.122.20.27]  Setting Cookie for 10.122.20.27 using user admin
[2022-02-14T11:45:31] [10.122.20.27]  Obtaining BASIC Appliance info --> v310/appliance/default/info
vi{
    currentCapacityGiB: 30004.499574548565
    expansionSupported: true
    filesystemId: c2d4435a-ef7a-13f0-8f4c-b6cd88a510d3
    isAdminPasswordSyncRequired: false
    isAllFlash: true
    isExpandable: false
    isFipsEncryptionEnabled: false
    modelName: T7080
    osVersion: 5.2.0.1-11342.55846.24813
    outOfBoxCompleted: true
    productId: ZC5
    serialNumber: 0428-2108-147
    typeId: com.tintri.api.rest.v310.dto.domain.beans.hardware.ApplianceInfo
}
```


# EXAMPLE: Displaying VMStore Appliance Info on multiple VMStore hosts
``` 
# cat inputfile
admin  mypass1    10.122.25.45
admin  mypass1    10.122.25.47
```

Now we execute against the inputfile and log the output
```
# webapitest -i -F inputfile
[2022-02-04T15:56:49] [10.122.25.45]  Setting Cookie for 10.122.25.45 using user admin
[2022-02-04T15:56:49] [10.122.25.45]  Obtaining BASIC Appliance info --> v310/appliance/default/info
[2022-02-04T15:56:50] [10.122.25.45]  Writing results to /tmp/webapitest.10.122.25.45_rest-api.output.log
[2022-02-04T15:56:50] [10.122.25.47]  Setting Cookie for 10.122.25.47 using user admin
[2022-02-04T15:56:50] [10.122.25.47]  Obtaining BASIC Appliance info --> v310/appliance/default/info
[2022-02-04T15:56:51] [10.122.25.47]  Writing results to /tmp/webapitest.10.122.25.47_rest-api.output.log
```

Viewing the log output via the results in JSON output
```
# cat /tmp/webapitest.10.122.25.475_rest-api.output.log
{
    currentCapacityGiB: 30004.499574548565
    expansionSupported: true
    filesystemId: c2d4435a-ef7a-13f0-8f4c-b6cd88a510d3
    isAdminPasswordSyncRequired: false
    isAllFlash: true
    isExpandable: false
    isFipsEncryptionEnabled: false
    modelName: T7080
    osVersion: 5.2.0.1-11342.55846.24813
    outOfBoxCompleted: true
    productId: ZC5
    serialNumber: 0428-2108-147
    typeId: com.tintri.api.rest.v310.dto.domain.beans.hardware.ApplianceInfo
}
``` 
 

 
In the following example, let's assume the 'admin' password is mypass1  and we are testing with vmstore vmstore.acme.com
 
Create User Cookie AND execute -E to set the AES encryption to 256
``` 
# webapitest -u admin -p mypass1 -E 28 vmstore.acme.com
 
[2022-02-04T16:02:40] [vmstore.acme.com]  Setting Cookie for t7080 using user admin
[2022-02-04T16:02:41] [vmstore.acme.com]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:41] [vmstore.acme.com]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [vmstore.acme.com]  Writing results to /tmp/webapitest.vmstore.acme.com_rest-api.output.log
```
 
If the above is successful, now let's try it again on multiple VMStores using the input file with entries
 ```
# cat inputfile
admin        mypass1     10.122.10.15
admin        mypass1     10.122.10.25
```

Now we execute with the '-E 28' option
```
# webapitest -E 28 -F inputfile
[2022-02-04T16:02:40] [10.122.10.15]  Setting Cookie for 10.122.10.15 using user admin
[2022-02-04T16:02:41] [10.122.10.15]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:41] [10.122.10.15]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [10.122.10.15]  Writing results to /tmp/webapitest.10.122.10.15_rest-api.output.log
[2022-02-04T16:02:42] [10.122.10.25]  Setting Cookie for 10.122.10.25 using user admin
[2022-02-04T16:02:42] [10.122.10.25]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:42] [10.122.10.25]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [10.122.10.25]  Writing results to /tmp/webapitest.10.122.10.25_rest-api.output.log
```
 

