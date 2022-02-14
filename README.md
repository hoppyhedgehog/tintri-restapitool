# tintri-webapitest
A public tool using the REST-API for Tintri VMStore Storage Arrays


*(Assuming you already copied the script to a linux/mac/cywgin box AND chmod 755 <webapitest>)*
 
In the following example, let's assume the 'admin' password is tintri99 and we are testing with vmstore vmstore.acme.com
 
1. Create User Cookie AND test it on one VMstore
``` 
# webapitest -u admin -p mypassword -E 28 vmstore.acme.com
 
[2022-02-04T16:02:40] [t7080]  Setting Cookie for t7080 using user admin
[2022-02-04T16:02:41] [t7080]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:41] [t7080]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [t7080]  Writing results to /tmp/webapitest.t7080_rest-api.output.log
```
 
2. IF the above is successful, lets try it using the input file with entries
 ```
# cat inputfile
admin        mypass1     10.122.10.15
admin        mypass1     10.122.10.25
```

  Now we execute
```
# webapitest -E 28 -F inputfile
[2022-02-04T16:02:40] [t7080]  Setting Cookie for t7080 using user admin
[2022-02-04T16:02:41] [t7080]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:41] [t7080]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [t7080]  Writing results to /tmp/webapitest.t7080_rest-api.output.log
[2022-02-04T16:02:42] [t880]  Setting Cookie for t880 using user admin
[2022-02-04T16:02:42] [t880]  Setting the AES Enctyption Type to 28 --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=28&persist=true
[2022-02-04T16:02:42] [t880]  Checking the AES Enctyption Type --> v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type
Encryption Type     28
[2022-02-04T16:02:42] [t880]  Writing results to /tmp/webapitest.t880_rest-api.output.log
```
 
![image](https://user-images.githubusercontent.com/36774738/153922679-87dc233a-8f72-4073-a028-8cc6543c2b64.png)
