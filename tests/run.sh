#!/bin/bash

if [ -z $MYDOMAIN ]
then
    echo "No Test DOMAIN Set"
    exit 400
fi

if [ -z $TRAVIS_OS_NAME ]
then
	TESTDOMAIN="$MYDOMAIN"
else
    TESTDOMAIN="$TRAVIS_OS_NAME-travis-$MYDOMAIN"
fi


echo "Begining Tests for Domain: $TESTDOMAIN"

# Setup the config file
if [ ! -f ~/.rsdns_config ]; then
    echo "RSUSER=$RSUSER" > ~/.rsdns_config
    echo "RSAPIKEY=$RSAPIKEY" >> ~/.rsdns_config
    echo "RSPATH=$PWD" >> ~/.rsdns_config
    echo "UKAUTH=$UKAUTH" >> ~/.rsdns_config 
fi

# Start tests

## Create a Test Domain
./rsdns domain -d $TESTDOMAIN -e travis@$TESTDOMAIN -t 600

RESULT=`rsdns list | grep $TESTDOMAIN | awk -F ' | ' '{ print $3 }'`
if [ "$RESULT" != "$TESTDOMAIN" ]
then
    echo "Domain $TESTDOMAIN not found"
    exit 404
fi

## Execute A record tests
. tests/a.sh
## Execute AAAA record tests
. tests/aaaa.sh
## Execute CNAME record tests
. tests/cn.sh

## list
./rsdns list -d $TESTDOMAIN

## Dynamic Clients
./rsdns-dc.sh -n arecord.$TESTDOMAIN
./rsdns-dc6.sh -n aaaarecord.$TESTDOMAIN


## Clean up (Has to be LAST)
. tests/delete.sh