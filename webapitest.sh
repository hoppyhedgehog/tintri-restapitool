#!/bin/bash
###################################################################
#LAST MODIFIED: 2022-02-14 11:49:23
###################################################################
PS4='${LINENO}: '
###################################################################
###################################################################
# Script by Ben Patridge (bpatridge@tintri.com) to quickly
# test the WEB API on a VMstore(locally)
###################################################################
# THIS IS A USE AT YOUR OWN DESCRETION EXAMPLE SCRIPT USING THE
# REST-API. OFFICIAL DOCUMENTATION IS ON 
# https://support.tintri.com/download/ 
# (look for Developer Documentation --> Tintri REST API Documentation)
###################################################################
# GLOBAL VARIABLES
###################################################################
export PATH=$PATH:/usr/tintri/bin:/usr/local/tintri/bin:/opt/tintri
VER=2.2
SCRIPT=$(basename ${BASH_SOURCE[0]})
cookie=/tmp/.${SCRIPT}.cookie.txt
VMSTORE=
api="api/v310"
dbase="$api/datastore/default"
user_cache=/tmp/.${SCRIPT}.user_cache.dat
host_cache=/tmp/.${SCRIPT}.host_cache.dat
PASSFILE=/tmp/.${SCRIPT}.encrypted_password_cache.dat
TMP_INPUTFILE=/tmp/.${SCRIPT}.inputfile.dat
stub=/tmp/.${SCRIPT}.stub
human=1
line="================================================================"
###################################################################
# TESTING TO SEE IF THIS SCRIPT IS BEING RUN ON A VMSTORE, OR A 
# LINUX/MAC/Windows(Cygwin) Client
###################################################################
if [ -f /usr/local/tintri/bin/product-serial ] &&  [  -f /var/lock/subsys/platform ]; then
	serial=$(product-serial)
else
	not_vmstore=1
	serial=$(hostname)
fi
###################################################################
###################################################################
###################################################################


###################################################################
# FUNCTIONS
###################################################################
clear_data() {
	for file in "$cookie" $host_cache $user_cache $PASSFILE $stub $TMP_INPUTFILE; do
		rm -f $file 2>/dev/null
	done
}
############################################################
get_serial() {
	if [ ! -z $not_vmstore ]; then
		serial=$(hostname)
		if [ -z $VMSTORE ]; then
			VMSTORE=$serial
		fi
		cont=0
		logfile=/tmp/${SCRIPT}.${serial}_rest-api.output.log
	else
		VMSTORE="localhost"
		serial=$(grep PRODUCT_SERIAL /var/lock/subsys/platform|cut -d= -f2)
		if [ -z "$serial" ]; then
			local serial=$(product-serial)
		fi
		logfile=/tmp/${SCRIPT}.${serial}_rest-api.output.log
		case $(controller-id) in
			"0")      cont="a";;
			"1")      cont="b";;
		esac
	fi
}
############################################################
encrypt_password(){
        PASS=`echo $1|openssl enc -aes-128-cbc -a -salt -pass pass:IPAMaster`
        echo $PASS
}
############################################################
decrypt_password() {
        if [ -f $PASSFILE ]; then
                local ENCRYPTED=$(cat $PASSFILE)
                echo -e $ENCRYPTED|openssl enc -aes-128-cbc -a -d -salt -pass pass:IPAMaster
        else
                writelog "ERROR: unable to find Password Hash in $PASSFILE"
                exit 1
        fi
}
############################################################
setpass() {
        local pass="$1"
        local temp_pass=$(echo -e $pass|sed 's/^[ \t]*//;s/[ \t]*$//')
        ENCRYPTED_PASSWORD=$(encrypt_password $temp_pass)
        writelog "Writing Encrypted Password [$ENCRYPTED_PASSWORD]--> $PASSFILE" 1
        printf $ENCRYPTED_PASSWORD >$PASSFILE
}
############################################################
writelog() {
        REAL_DATETIME=`date '+%Y-%m-%dT%H:%M:%S'`
	if [ -z $not_vmstore ]; then
		ct="[$cont]"
	else
		local ct=
	fi
        dt="[$REAL_DATETIME] [$VMSTORE] $ct"
	echo "$dt $1 "
}
############################################################
check_sed() {
	PRE_SED="sed -e '1,/^Server:/d'|sed '/^$/d'"
        if [ !  -z $noquote ]; then
                POST_SED='sed "s:\x1B\\\[\[0-9;\]\*[a-zA-Z]::g"'
	else
                POST_SED='sed "s:\x1B\\\[\[0-9;\]\*[a-zA-Z]::g"|sed "s/\x22//g;s/,//g"'
        fi
}

############################################################
usage(){
	get_serial
	if [ ! -z $err ]; then
		echo $line
		echo $1
	fi
	
	echo $line
	echo "# SCRIPT TO TEST THE REST-API AND RETURN DATA. Ver:$VER"
	echo $line
	echo "# $SCRIPT [args]"
	echo $line
	echo "	-c		Clear saved cookie ($cookie) & saved user info"
	echo "	-u <user>	User  (default admin) [cached after 1st iteration]"
	echo "	-p <pass>	User  (default tintri99) [cached after 1st iteration]"
	echo "	-v <vmstore>	[IF NOT on a VMStore] then specify IP or FQDN of VMStore [cached after 1st iteration]"
	echo "	-i		Display brief appliance (vmstore) info"
	echo "	-a		Display appliance (vmstore) info"
	echo "	-h		Display HypervisorConfig Info"
	echo "	-d		Display VMStore datastore properties"
	echo "	-l		Log Output to file /tmp/${serial}_rest-api_output.log"
	echo "	-r		Obtain VMStore computeResource info"
	echo "	-A		Display REST-API-INF"
	echo "	-n		Display Notification Policy"
	echo "	-g		Display all Service Group Info"
	echo "	-1		List all userAccounts"
	echo "	-s		Display all Snapshots"
	echo "	-S		Display all Active Sessions"
	echo "	-C		Display all Current Sessions"
	echo "	-H		DO NOT Format JSON Output to make it human readable"
	echo "	-E <num>	Encryption Cypher Type"
	echo "			0  - Query (View the Current Encryption Type. Default is RC4)"
	echo "			4  - Set RC4 (Default)"
	echo "			8  - AES128"
	echo "			16 - AES256"
	echo "			28 - RC4, AES128 & AES256"
	echo "	-L		Display all License info"
	echo "	-T		Display all sessions for user=tintricenter"
	echo "	-F <file>	Use Input File for multiple VMStores"
	echo "			FILE FORMAT:"
	echo "				username	password	vmstore_ip(or name)"
	echo "			EXAMPLE: Filename :/tmp/inputfile"
	echo "				admin		tintri99	10.136.40.27"
	echo "				admin		tintri99	172.16.236.17"
	echo "	-P		Change User Password"
	echo "	-U <user>	User Name to Change when -P option is specified"
	echo "	-P \"<pass>\"	User Password to Change when -P option is specified"
	echo "	-N 		Obtain VMStore Notification Properties"
	echo "	-Q 		Strip quotes and commas in output"
	echo "	-R \"<role>\"	User role (admin user is 'ADMIN')"
	echo "	-V		Display all VM info"
	echo "	-U		Display VMStore StatSummary Output"
	echo "	-x		Verbose output"
	echo "	-X		Debug (set -x) output"
	echo $line
	exit
}
############################################################
setcookie() {
	writelog "Setting Cookie for $VMSTORE using user $USERNAME"

	if [ -z $verbose ]; then
		(curl -i -k -X POST -H 'Content-Type: application/json' -d '{"username":"'$USERNAME'", "typeId":"com.tintri.api.rest.vcommon.dto.rbac.RestApiCredentials", "password":"'$DECRYPTED_PASSWORD'"}' https://$VMSTORE/${api}/session/login 2>/dev/null > $cookie) >/dev/null 2>&1
	else
		curl -i -k -X POST -H 'Content-Type: application/json' -d '{"username":"'$USERNAME'", "typeId":"com.tintri.api.rest.vcommon.dto.rbac.RestApiCredentials", "password":"'$DECRYPTED_PASSWORD'"}' https://$VMSTORE/${api}/session/login 2>/dev/null | tee -a $cookie
	fi
}
############################################################
put_query(){
        local url="$1"
        local message="$2"
        local human=$3
        writelog "$message --> $url"
        if  [ "x$human" == "x2" ]; then
                nosed=1
        fi

        check_sed

        if [ ! -z $verbose ]; then
                                echo curl -i -k -X PUT -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
        fi
        if [ ! -z $nosed ]; then
                if [ -z $logtofile ]; then
                        curl -i -k -X PUT -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null
                else
                        (curl -i -k -X PUT -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/nul ) >$logfile 2>&1
                fi
        elif [ ! -z $human ]; then
                if [ -z $logtofile ]; then

                        curl -i -k -X PUT -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
                else
                        (curl -i -k -X PUT -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null) >$logfile 2>&1
                fi
        else
                if [ -z $logtofile ]; then
                        curl -i -k -X PUT -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
                else
                        (curl -i -k -X PUT -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null ) >$logfile 2>&1
                fi
        fi

}
############################################################

get_query(){
	local url="$1" 
	local message="$2"
	local human=$3
	local arg=$4
	writelog "$message --> $url"
	if  [ "x$human" == "x2" ]; then
		nosed=1
	elif [ "x$human" == "x3" ]; then
		brief=1
	fi

	check_sed
	if [ ! -z $verbose ]; then
				echo curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
	fi
	if [ ! -z $nosed ]; then
		if [ -z $logtofile ]; then
        		curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null 
		else
        		(curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/nul ) >$logfile 2>&1
		fi
	elif [ ! -z $brief ]; then
        		curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED >$stub 2>&1
			if [ $(grep -q "[a-z0-9]" $stub; echo $?) == 0  ]; then
				if [ ! -z "$arg" ]; then
					printf "$arg\t" 
				fi
				cat $stub |python -m json.tool |eval $POST_SED 2>/dev/null |tee -a $logfile
			else
				echo "No Results Found" |tee -a $logfile
			fi
	elif [ ! -z $human ]; then
		if [ -z $logtofile ]; then

        		curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
		else
        		(curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null) >$logfile 2>&1
		fi
	else
		if [ -z $logtofile ]; then
        		curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
		else
			(curl -i -k -X GET -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null ) >$logfile 2>&1
		fi
	fi

}
############################################################
reset_query(){
	if [ ! -z $np ] && [ -z "$newpass" ]; then
		writelog "ERROR: Must specify a password with -P option"
		usage
	fi
	check_sed
	local url="$1" 
	local message="$2"
	local human=$3
	role=$(echo $role|tr "[:lower:]" "[:upper:]")
	rolel=$(echo $role|tr "[:upper:]" "[:lower:]")
	local ver="v310.121"
	writelog "$message --> $url"

	echo curl -k -i -X POST -H 'Content-Type: application/json' -b $cookie -d '{"typeId": "com.tintri.api.rest.vcommon.dto.rbac.RestApiCredentials","newPassword":"'$newpass'","password":"'$DECRYPTED_PASSWORD'","username":"'$USERNAME'","role":"'$rolel',"roleNames":"'$role'"}' https://$VMSTORE/$api/userAccount/resetPassword 2>/dev/null |eval $PRE_SED 2>/dev/null

	if [ -z $logtofile ]; then
	curl -k -i -X POST -H 'Content-Type: application/json' -b $cookie -d '{"typeId": "com.tintri.api.rest.vcommon.dto.rbac.RestApiCredentials","newPassword":"'$newpass'","password":"'$DECRYPTED_PASSWORD'","username":"'$USERNAME'","role":"'$rolel',"roleNames":"'$role'"}' https://$VMSTORE/$api/userAccount/resetPassword 2>/dev/null |eval $PRE_SED 2>/dev/null
	else
	(curl -k -i -X POST -H 'Content-Type: application/json' -b $cookie -d '{"typeId": "com.tintri.api.rest.vcommon.dto.rbac.RestApiCredentials","newPassword":"'$newpass'","password":"'$DECRYPTED_PASSWORD'","username":"'$USERNAME'","role":"'$rolel',"roleNames":"'$role'"}' https://$VMSTORE/$api/userAccount/resetPassword 2>/dev/null |eval $PRE_SED 2>/dev/null  )>$logfile 2>&1
	fi

	if [ $? != 0 ]; then
		writelog "ERROR Resetting Password.."
	fi
}
############################################################
post_query(){
	local url="$1" 
	local message="$2"
	local human=$3
	writelog "$message --> $url"
	if [ ! -z $human ]; then
		if [ -z $logtofile ]; then
        		curl -i -k -X POST -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
		else
        		(curl -i -k -X POST -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null ) >$logfile 2>&1
		fi
	else
		if [ -z $logtofile ]; then
      	  		curl -i -k -X POST -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null
		else
        		(curl -i -k -X POST -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED | python -m json.tool |eval $POST_SED 2>/dev/null ) >$logfile 2>&1
		fi
	fi

}
############################################################
build_array() {
	USERNAME_ARR+=($(echo $USERNAME))
	VMSTORE_ARR+=($(echo $VMSTORE))
	PASSWORD_ARR+=($(echo -e "$DECRYPTED_PASSWORD"))
}
############################################################
get_userdata() {
	USERNAME=$(cat $user_cache)
	VMSTORE=$(cat $host_cache)
	ENCRYPTED_PASSWORD=$(cat $PASSFILE)
}
############################################################
check_cache() {
	local c=0
	if [ -z $USERNAME ]; then
		echo "ERROR: User Name not specified or cache does not exist. "
		((c++))
	fi

	if [ -z $ENCRYPTED_PASSWORD ]; then
		echo "ERROR: User Password not specified or cache does not exist."
		((c++))
	fi

	if [ -z $VMSTORE ]; then
		echo "ERROR: VMstore not specified or cache does not exist."
		((c++))
	fi

	if [ $c -gt 0 ]; then
		usage
	fi
}
############################################################
check_user_data() {
	if [ ! -z $suser ]; then
		echo -e $USERNAME > $user_cache
	fi
	if [ ! -z $spass ]; then
		echo -e $USERNAME > $user_cache
		setpass "$DECRYPTED_PASSWORD"
	fi
	if [ ! -z $gethost ]; then
		echo -e $VMSTORE>$host_cache
	fi

	if [[ (  -f  $PASSFILE )   && (  -f  $host_cache )  && ( -f $user_cache)  ]]; then
		get_userdata
		DECRYPTED_PASSWORD=$(decrypt_password)
		check_cache
	else
		echo -e $USERNAME > $user_cache
		echo -e $VMSTORE > $host_cache
		setpass "$DECRYPTED_PASSWORD"
		check_cache
	fi
	build_array
}
############################################################
check_inputfile() {
		cp -pf $INPUTFILE $TMP_INPUTFILE 2>&1	
		sed -i 's/^[ \t]*//;s/[ \t]*$//'  $TMP_INPUTFILE

		while read user pass vmstore; do
			USERNAME_ARR+=($(echo $user))
			PASSWORD_ARR+=($(echo -e "$pass"))
			VMSTORE_ARR+=($(echo -e "$vmstore"))
		done<$TMP_INPUTFILE
}
############################################################
check_ha(){
		if [ $(hamoncmd -g|egrep "^NodeStatus|^NodeRole"|awk 'BEGIN{p=0;s=0}
		NR == 1 {
			if ($NF == "PRIMARY") {
				p=0
			}else{
				p++
			}
		}
		NR == 2 {
			if ($NF == "ACTIVE") {
				s=0
			}else{
				s++
			}
		}END {
			if (p != 0 || s != 0 ){
				print 1
			}else{
				print 0
			}
		}') != 0 ]; then
			usage "ERROR: Controller-$cont Not in Good ACTIVE HA state"
			usage
		else
			writelog "GOOD. Controller-$cont is in PRIMARY/ACTIVE state"
		fi

}
############################################################
do_logout(){
	check_sed
	local url="v310/session/logout"
	local message="Logging out.."
	local human=
	writelog "$message --> $url"
       	curl -i -k -X POST -H 'Content-Type: application/json' -b $cookie https://$VMSTORE/api/$url 2>/dev/null |eval $PRE_SED
	rm -f $cookie 2>/dev/null
	exit
}
###################################################################
if [ $# == 0 ]; then
	usage
fi


while getopts "qE:YMNWHQP:hUCSU:R:TXgdLsralAViv:F:xncZu:p:" OPT_NAME; do
   case $OPT_NAME in
        ("\?") usage;;
        ("X")  set -x;verbose=1;;
	("E") 	if [ "$OPTARG" == 0 ]; then
			getaes=1
		else
			case $OPTARG in
				("4"|"8"|"16"|"28") 	enctype=$OPTARG;;
				(*)	usage;;
			esac
			setaes=1
		fi
		;;
	("U") statsum=1;;
	("F")   if [ -f $OPTARG ]; then
			INPUTFILE=$OPTARG
		else
			usage
		fi
		ifile=1
		logtofile=1
		;;
	("W") smbt=1;;
	("N") notpol=1;;
        ("H") human=;;
        ("Q") noquote=1;;
        ("Z") space=1;;
        ("q") getuser=1;human=1;;
        ("T") tcenter=1;;
        ("s") getsnap=1;;
        ("C") csession=1;;
        ("S") session=1;;
	("v") 	VMSTORE=$OPTARG
		gethost=1
		;;
        ("g") sg=1;;
        ("P") resetpw=1;
	      newpass="$OPTARG";np=1;;
        ("R") role=$OPTARG;;
	("U")	username="$OPTARG";;
	("N")	newpass="$OPTARG";np=1;;
        ("r") compute=1;;
	("L") license=1;human=1;;
        ("d") dprop=1;;
        ("i") info=1;human=1;;
        ("n") notify=1;;
        ("A") api_info=1;;
        ("l") logtofile=1;;
        ("c") clear=1;;
        ("a") appliance=1;;
        ("x") verbose=1;;
        ("V") vm=1;;
        ("h") hconfig=1;;
        ("u")   if [ ! -z $OPTARG ]; then
			USERNAME="$OPTARG"
		else
			usage
		fi
		suser=1
		;;
        ("p")   if [ ! -z $OPTARG ]; then
			DECRYPTED_PASSWORD="$OPTARG"
		else
			usage
		fi
		spass=1
		;;
   	(*)	usage;;
    esac
done



if [ ! -z $clear ]; then
	get_serial
	writelog "Cleared any previous cached cookie, host and password information"
	clear_data
	if [ $# == 1 ]; then
		exit
	fi
fi

if [  -z $ifile ]; then
	check_user_data


	if [ ! -z $not_vmstore ] && [ -z $VMSTORE ]; then
		echo "ERROR: Must specify VMStore with -s option"
		usage
	fi

	if [ -z $not_vmstore ]; then
		check_ha
	fi

	if [ -f $logfile ]; then
		rm -f $logfile 2>/dev/null
	fi


else
	check_inputfile
fi
###################################################################
for i in "${!USERNAME_ARR[@]}"; do
	USERNAME=${USERNAME_ARR[$i]}
	DECRYPTED_PASSWORD=${PASSWORD_ARR[$i]}
	VMSTORE=${VMSTORE_ARR[$i]}
	if [ ! -z $ifile ]; then
		logfile=/tmp/${SCRIPT}.${VMSTORE}_rest-api.output.log
		rm -f $logfile 2>/dev/null
	fi
	if [ ! -z $verbose ]; then
		echo ${USERNAME_ARR[$i]} ${PASSWORD_ARR[$i]} ${VMSTORE_ARR[$i]}
	fi


	if [ ! -z $verbose ] && [ -z $ifile ]; then
		writelog "Using user=$ARR_USERNAME password_hash=$ENCRYPTED_PASSWORD password=$DECRYPTED_PASSWORD"
	fi

	if [ ! -z $ifile ] || [ ! -f $cookie ]; then
		setcookie
	fi

	if [ $(grep -q "^Set.*Http" $cookie; echo $?) != 0 ]; then
		writelog "Error. Cookie is invalid"
		setcookie
		if [ $(grep -q "^Set.*Http"; echo $?) != 0 ]; then
			writelog "Error. Problem obtaining cookie..."
			exit 1
		fi
	fi
###################################################################


	if [ ! -z $hconfig ]; then
		get_query "v310/datastore/default/hypervisorManagerConfig" "Querying HypervisorManagerConfig" $human
	fi

	if [ ! -z $appliance ]; then
		get_query "v310/appliance" "Obtaining Appliance info" $human
	fi

	if [ ! -z $vm ]; then
		get_query "v310/vm" "Obtaining VM info" $human
	fi

	if [ ! -z $info ]; then
		get_query "v310/appliance/default/info" "Obtaining BASIC Appliance info"  $human
	fi
	if [ ! -z $statsum ]; then
		get_query "v310/datastore/default/statsSummary" "Obtaining StatsSummary info"  $human
	fi

	if [ ! -z $api_info ]; then
		get_query "info" "Obtaining BASIC REST-API info"   $human
	fi

	if [ ! -z $notify ]; then
		get_query "v310/appliance/default/notificationPolicy" "Obtaining Notification Policy Info" $human
	fi

	if [ ! -z $compute ]; then
		get_query "v310/computeResource" "Obtaining VMStore ComputeResource Info"  $human
	fi

	if [ ! -z $dprop ]; then
		get_query "v310/datastore" "Obtaining VMStore Datastore Info" $human 
	fi

	if [ ! -z $license ]; then
		get_query "v310/license" "Obtaining VMStore License Info" $human
	fi

	if [ ! -z $session ]; then
		get_query "v310/session/active" "Obtaining VMStore Active Sessions" $human
	fi

	if [ ! -z $csession ]; then
		get_query "v310/session/current" "Obtaining CURRENT VMStore Active Sessions" $human
	fi

	if [ ! -z $tcenter ]; then
		get_query "v310/session/active" "Obtaining VMStore Active Sessions for user=tintricenter" $human
	fi


	if [ ! -z $sg ]; then
		get_query "v310/servicegroup" "Obtaining VMStore ServiceGroup Info" $human
	fi


	if [ ! -z $getsnap ]; then
		get_query "v310/snapshot" "Obtaining VMStore Snapshot Info" $human
	fi
	if [ ! -z $space ]; then
		get_query "v310/datastore/default/statsSummary" "Obtaining VMStore Stat Summary" $human
	fi
	if [ ! -z $resetpw ]; then
		reset_query "v310/userAccount/resetPassword" "Resetting Password" $human
		getuser=1;human=1;
	fi

	if [ ! -z $getuser ]; then
		get_query "v310/userAccount" "Obtaining List of User Accounts " $human
	fi


	if [ ! -z $notpol ]; then
		get_query "v310/appliance/default" "Returning all VMStores Notification Properties"
	fi

	if [ ! -z  $getaes ]; then
		get_query "v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type" "Checking the AES Enctyption Type" 3 "Encryption Type"
	fi
	if [ ! -z  $setaes ]; then
		put_query "v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type&value=$enctype&persist=true" "Setting the AES Enctyption Type to $enctype"
		get_query "v310/internal/admin/systemProperty?key=com.tintri.authd.encryption.type" "Checking the AES Enctyption Type" 3 "Encryption Type"
	fi

	if [ ! -z $smbt ]; then
		if [ ! -z $uuid ]; then
			get_query "v310/datastore/$uuid/smbSettings" "Returning all VMStores SMB Properties"
		fi
		
	fi
	writelog "Writing results to $logfile"
	if [ ! -z $logout ] || [ ! -z $ifile ]; then
		do_logout
	fi
done
###################################################################
#END
###################################################################