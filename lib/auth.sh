#!/bin/bash
#
# Authenication Functions
#
# Pated from https://github.com/jsquared/rscurl
#

#Authenticates to the Rackspace Service and sets up the Authentication Token and Managment server
#REQUIRES: 1=AuthUser 2=API_Key
function get_auth () {

	if [ -z $RSUSER ]
	then
     	printf "\n"
     	printf "Username Not Set."
     	printf "\n"
		usage
		exit 1
	fi

	if [ -z $RSAPIKEY ]
	then
     	printf "\n"
     	printf "API Key Not Set."
     	printf "\n"
		usage
		exit 1
	fi

	if [ -n "$RSPATH" ]
	then
	  AUTHFILE="$RSPATH/.rsdns_auth.json"
	else
	  AUTHFILE="$HOME/.rsdns_auth.json"
	fi

	if [[ $UKAUTH -eq 1 ]]; then
		AUTHSVR="https://lon.identity.api.rackspacecloud.com/v2.0/tokens"
		DNSSVR="https://lon.dns.api.rackspacecloud.com/v1.0"
	else
		AUTHSVR="https://identity.api.rackspacecloud.com/v2.0/tokens"
		DNSSVR="https://dns.api.rackspacecloud.com/v1.0"
	fi

	if [ -e $AUTHFILE ]
	then
		TOKENEXPIRES=`jq -r '.access.token.expires' $AUTHFILE`
		NOW=`date +%Y-%m-%dT%H:%M:%S`

		# Match Yr
		if [ "${NOW:0:4}" == "${TOKENEXPIRES:0:4}" ]
		then
			# Match Month
			if [ "${NOW:5:2}" == "${TOKENEXPIRES:5:2}" ]
			then
				# Match Day
				if [ "${NOW:8:2}" -le "${TOKENEXPIRES:8:2}" ]
				then
					# Hour must be less than Token - I don't care about minutes/seconds ;-)
					if [ "${NOW:11:2}" -lt "${TOKENEXPIRES:11:2}" ]
					then
						read_token
					else
						curl_auth
					fi
				else
					curl_auth
				fi
			else
				curl_auth
			fi
		else
			curl_auth
		fi
	else
		curl_auth
	fi


}

function curl_auth() {

	# Clean up anything
	if [ -e $AUTHFILE ]
	then
		rm -f $AUTHFILE
	fi

	# http://stackoverflow.com/questions/2220301/how-to-evaluate-http-response-codes-from-bash-shell-script
	AUTH=`curl --write-out %{http_code} -s -o $AUTHFILE -H "Content-Type: application/json" -d "{ \"auth\": { \"RAX-KSKEY:apiKeyCredentials\": { \"username\":\"$RSUSER\",\"apiKey\":\"$RSAPIKEY\" } } }" $AUTHSVR`

	chmod 600 $AUTHFILE

	if [[ $AUTH == "200" ]]; then
		read_token
	else
		if [[ $QUIET -eq 1 ]]; then
			exit $EC
		fi
		echo "Authentication Failed ($AUTH)"
		exit $EC
	fi
}

function read_token() {
	TOKEN=`jq -r '.access.token.id' $AUTHFILE`
	USERID=`jq -r '.access.token.tenant.id' $AUTHFILE`
	MGMTSVR=`jq -r '.access.serviceCatalog[] | select(.name == "cloudServersOpenStack") | .endpoints[].publicURL' $AUTHFILE`
	#DNSSVR=`jq '.access.serviceCatalog[] | select(.name == "cloudDNS") | .endpoints[].publicURL' ~/.rsdns_auth.json`
}

function http_code_eval () {
	if [ $QUIET -eq 1 ]
		then
		case $1 in
			202 ) exit 0 ;;
			204	) exit 0 ;;
			* ) exit $1 ;;
		esac
	else
		case $1 in
			202	) echo "Action request successful." ; exit 0;;
			204	) echo "Action request successful." ; exit 0;;
			401 ) echo "Request Unauthorized.  Is your username and api key correct?"; exit $1;;
			404	) echo "Server ID not found."; exit $1;;
			409	) echo "Server is currently being built, please wait and retry."; exit $1;;
			413	) echo "API Request limit reached, please wait and retry."; exit $1;;
			422	) echo "Unprocessable Entity, cannot resize while a backup is in progress."; exit $1;;
			503	) echo "Rackspace Cloud service unavailable, please check and then retry."; exit $1;;
			*	) echo "An unknown error has occured. ($RC)"; exit 99;;
		esac
	fi
}
# Variable Defaults
if [ -z $QUIET ]
then
  QUIET=0
fi

if [ -z $UKAUTH ]
then
  UKAUTH=0
fi
