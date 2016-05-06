#!/bin/bash

TESTDOMAIN="$TRAVIS_OS_NAME-travis-rsdns.linickx.co.uk"

echo $TESTDOMAIN

echo "NBTESTVAR=$NBTESTVAR" > ~/.rsdns_config
cat ~/.rsdns_config

# Setup the config file
echo "RSUSER=$RSUSER" > ~/.rsdns_config
echo "RSAPIKEY=$RSAPIKEY" >> ~/.rsdns_config
echo "RSPATH=$RSPATH" >> ~/.rsdns_config
echo "UKAUTH=$UKAUTH" >> ~/.rsdns_config 

# Exit Codes
## Standard
# 0 = ok
# 1 = Input/Var Missing
# 
## Custom
# 102 = API Status Exception
# 101 = API Status ERROR
# 100 = API Authentication Failure (Key)
# 98 = API Authentication Failure (Token)
# 97 = API Authentication Failure (Management Server)
# 96 = Record (to update) not found
# 95 = Failed to load auth.sh
# 94 = Failed to auth func.sh
# 93 = Domain not found
# 92 = Record not found
#
# 50 = Missing dependency

# Start tests

. tests/a.sh