# !/bin/bash

echo "Create MX record for $TESTDOMAIN"
$PWD/rsdns mx -d $TESTDOMAIN -n $TESTDOMAIN -D arecord.$TESTDOMAIN -p 5