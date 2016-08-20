#!/bin/bash

if [ -z $MYDOMAIN ]
then
    echo "No Test DOMAIN Set"
    exit 40
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
$PWD/rsdns version

## Create a Test Domain
$PWD/rsdns domain -d $TESTDOMAIN -e travis@$TESTDOMAIN -t 600

RESULT=`$PWD/rsdns list | grep $TESTDOMAIN | awk -F ' | ' '{ print $3 }'`
if [ "$RESULT" != "$TESTDOMAIN" ]
then
    echo "Domain $TESTDOMAIN not found"
    exit 44
fi

## A record tests
. tests/a.sh
## AAAA record tests
. tests/aaaa.sh
## CNAME record tests
. tests/cn.sh
## MX record tests
. tests/mx.sh
## SRV record tests
. tests/srv.sh
## TXT record tests
. tests/txt.sh

## NS Update
echo "Updating NS record from dns1.stabletransit.com to ns1.$TESTDOMAIN"
./rsdns ns -d $TESTDOMAIN -s dns1.stabletransit.com -S ns1.$TESTDOMAIN

## Export
echo "Exporting $TESTDOMAIN in bind format "
./rsdns export -d $TESTDOMAIN
echo " --- "

## list
echo "Listing..."
./rsdns list -d $TESTDOMAIN
echo " --- "
echo

## Dynamic Clients
echo "DC - IPv4"
./rsdns-dc.sh -n arecord.$TESTDOMAIN
echo "DC - IPv6"
./rsdns-dc6.sh -n aaaarecord.$TESTDOMAIN
echo " --- "
echo

## Delete by ID
# 

## Clean up (Has to be LAST)
. tests/delete.sh