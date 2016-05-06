# !/bin/bash

echo "Create MX record for $TESTDOMAIN"
$PWD/rsdns a -d $TESTDOMAIN -n $TESTDOMAIN -D arecord.$TESTDOMAIN -p 5