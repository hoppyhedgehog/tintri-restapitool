# tintri-restapitool
A public tool using the REST-API for Tintri VMStore Storage Arrays or Tintri Global Center (TGC)

```
# chmod 755 restapitool
```

Now we view the script usage:
```
USAGE
# ./restapitool
================================================================
> TTNTRI SUPPORT TOOL
> A WRAPPER FOR EXECUTING REST-API COMMANDS AGAINST (VMSTORE/TGC)
================================================================
# restapitool [arguments]
================================================================
        -u <user>       User  (default admin) [cached after 1st iteration]
        -p <pass>       User  (default mypa$$1) [cached after 1st iteration]
        -h <host>       VMStore or TGC [IF NOT on a (VMSTORE/TGC)] then specify IP or FQDN of (VMSTORE/TGC) [cached after 1st iteration]
================================================================
[ARGUMENTS & OPTIONS]
================================================================
        -a              Display All VMStore Current Appliance Details
        -c              Clear saved cookie (/tmp/restapitool_data/.restapitool.cookie.txt) & cached host & encrypted password info
        -clean          Strip quotes and commas in output
        -cred           View current credentials (user|pass|host) from cache
        -date           Obtain VMStore date and time settings
        -denc           Get Disk Encryption Information
        -dns            Obtain VMStore DNS settings
        -dp             Display (VMSTORE/TGC) datastore properties
        -e <num>        Get or Set VMStore Environmental Properties
                        0  - DNS, IP and Interface Configuration
                        1  - Disk Encryption Information
                        2  - Display VMStore System Properties
                        3  - Display VMStore Temperature Information
                        4  - Display VMStore Date and Time
                        5  - Display VMStore Autosupport Settings
                        6  - Display Hypervisor Configuration Information
                        7  - Display IPMI Configuration
                        8  - Display LACP Configuration
                        9  - Display VMStore Upgrade information
                        10 - Display VMStore Cluster Configuration
                        11 - Display VMStore Replication Configuration
                        12 - Display VMStore SMB Settings
                        13 - Display Hypervisor Refresh Interval
                        14 - Decrease [vcentercache.refresh.interval] to 600000[10min]
        -enc <num>      Encryption Cypher Type
                        0  - Query (View the Current Encryption Type. Default is RC4)
                        4  - Set RC4 (Default)
                        8  - AES128
                        16 - AES256
                        28 - RC4, AES128 & AES256
        -f <file>       Use Input File for multiple (VMSTORE/TGC)
                        FILE FORMAT:
                                username        password        vmstore_ip(or name)
                        EXAMPLE: Filename :/tmp/inputfile
                                admin           mypa$$1 10.122.20.45
                                admin           mypa$$1 10.122.20.46
        -failover       Initiate a Controller Failover (Prompted)
        -i or -info     Display brief VMStore Appliance info
        -lic            Display list of License
        -lldp           Get LLDP information from both controllers
        -m <arg>        View or change vCenter Multiplexor Refresh Interval
                        0  - View/Display vCenter Multiplexor Refresh Interval
                        X  - Set Refresh Interval to X
        -n              Display Notification Policy
        -nj             NO JSON Format (Human Readable)
        -nfs            Display NFS ACLs
        -np             Obtain (VMSTORE/TGC) Notification Properties
        -op             Display VMStore current Operational Status
        -q              QUIET: ONLY Log Output to file:/tmp/benvm1_rest-api_output.log
        -r <num>        Obtain VMStore Host & Hypervisor Resource Information
                        0 - Display all Host resources, resource pool, cluster,etc
                        1 - Display VMStore Host Resources
                        2 - Display all Hypervisor Datastores
                        3 - Display all Hypervisor Manager Configuration
        -reauth         Use current cached user/pass to re-authenticate
        -reboot         Reboot the VMStore
        -rebootsec      Reboot the VMStore Secondary Controller
        -rep            Get replication properties
        -reppath        Get replication Paths
        -rest           Display REST-API-INF
        -role "<role>"  User role (admin user is 'ADMIN')
        -rt             Restart Tomcat Webserver
        -ra             Restart Authd Authentication Service
        -s              Display all Snapshots
        -sb             Generate a Support Bundle
                        0  - Generate a 'nightly' support bundle(smaller)
                        1  - Generate a support bundle (full)
        -sess <num>     Display UI Session Information
                        0 - Display ALL Active Sessions
                        1 - Display all sessions for user=tintricenter
                        2 - Display Current Sessions
        -sg             Display all Service Group Info
        -shutdown       Perform a full Shutdown of the VMStore
        -snapd <arg>    Modify Snapshot Deletion
                        0  -  Disable Snapshot Deletion
                        1  -  Re-enable Snapshot Deletion
        -snapdc <arg>   Modify CLOUD Snapshot Deletion
                        0  -  Disable CLOUD Snapshot Deletion
                        1  -  Re-enable CLOUD Snapshot Deletion
        -rsnmp          Restart SNMP Agent
        -stat <num>     Display VMStore Statistic information
                        0  - Display VMStore Historic StatSummary Datastore performance info
                        1  - Display VMStore real-time data store performance data
        -tls <opts>     View or set TLS Configuration
                        0   - View current TLS configuration
                        1.0 - Include TLS 1.0 Support
                        1.1 - Include TLS 1.1 Support
                        1.2 - Include TLS 1.2 Support
                        1.3 - Include TLS 1.3 Support
                        reset - Reset to default
        -tgcst          View TGC Session timeout for exernal users
        -users          Get a list of all Users
        -vm             Display all VM info
        -smb            Display all SMB fileShares and properties
                        OPTIONAL
                        <arg1>  dnsAuthenticationDomain
                        <arg2>  smbDataPathHostname
        -verbose        Verbose output
        -debug          Debug (set -x) output
================================================================
ADDITIONAL ARGS
================================================================
        -P              Change User Password
        -U <user>       User Name to Change when -P option is specified
        -P "<pass>"     User Password to Change when -P option is specified
================================================================
EXAMPLES
================================================================
        EXAMPLE(1):   (Query VMStore First Iteration):
                # restapitool -u admin -p mypa$$1 -h vmstore.acme.com -i

        EXAMPLE(2):   (If using same VMStore the user/pass is cached)
                # restapitool -a

        EXAMPLE(3):   (Using input file to batch gather Vmstore info (-i))
                # restapitool -F /tmp/inputfile -i
================================================================

``` 

# Now we establish the web 'cookie' and then we display the VMStore host information
```
# restapitool -u admin -p mypass1 -v 10.122.20.27 -i
[2022-02-14T11:45:30] [10.122.20.27]  Writing Encrypted Password [U2FsdGVkX1//oLK1myWFdF7vdfn5veKee9aojuQ9Brc=]--> /tmp/.restapitool.encrypted_password_cache.dat
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


# Displaying VMStore Appliance Info on multiple VMStore hosts
``` 
# cat inputfile
admin  mypass1    10.122.25.45
admin  mypass1    10.122.25.47
```

Now we execute against the inputfile and log the output
```
# restapitool -i -F inputfile
[2022-02-04T15:56:49] [10.122.25.45]  Setting Cookie for 10.122.25.45 using user admin
[2022-02-04T15:56:49] [10.122.25.45]  Obtaining BASIC Appliance info --> v310/appliance/default/info
[2022-02-04T15:56:50] [10.122.25.45]  Writing results to /tmp/restapitool.10.122.25.45_rest-api.output.log
[2022-02-04T15:56:50] [10.122.25.47]  Setting Cookie for 10.122.25.47 using user admin
[2022-02-04T15:56:50] [10.122.25.47]  Obtaining BASIC Appliance info --> v310/appliance/default/info
[2022-02-04T15:56:51] [10.122.25.47]  Writing results to /tmp/restapitool.10.122.25.47_rest-api.output.log
```

Viewing the log output via the results in JSON output
```
# cat /tmp/restapitool.10.122.25.475_rest-api.output.log
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
# restapitool -u admin -p mypass1 -E 28 vmstore.acme.com
 
[2022-02-04T16:02:40] [vmstore.acme.com]  Setting Cookie for t7080 using user admin
[2022-02-04T16:02:41] [vmstore.acme.com]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:41] [vmstore.acme.com]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [vmstore.acme.com]  Writing results to /tmp/restapitool.vmstore.acme.com_rest-api.output.log
```
 
If the above is successful, now let's try it again on multiple VMStores using the input file with entries
 ```
# cat inputfile
admin        mypass1     10.122.10.15
admin        mypass1     10.122.10.25
```

Now we execute with the '-E 28' option
```
# restapitool -E 28 -F inputfile
[2022-02-04T16:02:40] [10.122.10.15]  Setting Cookie for 10.122.10.15 using user admin
[2022-02-04T16:02:41] [10.122.10.15]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:41] [10.122.10.15]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [10.122.10.15]  Writing results to /tmp/restapitool.10.122.10.15_rest-api.output.log
[2022-02-04T16:02:42] [10.122.10.25]  Setting Cookie for 10.122.10.25 using user admin
[2022-02-04T16:02:42] [10.122.10.25]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:42] [10.122.10.25]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [10.122.10.25]  Writing results to /tmp/restapitool.10.122.10.25_rest-api.output.log
```
 

# Displaying Tintri Global Center Session Timeout
```
# restapitool -u admin -p tintri99 -h 172.16.242.81 -tgcst
[2024-04-10T10:42:58] [BENVM1]  Writing Encrypted Password [U2FsdGVkX18++szh41+uRPsJuO90NIOujpManM206aQ=] --> /tmp/restapitool_data/.restapitool.encrypted_password_cache.dat
[2024-04-10T10:42:58] [BENVM1]  Displaying current TGC Session Timeout Values
900000
```

# Setting 

