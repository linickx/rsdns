# !/bin/bash

echo "Create CNAME record: cn.$TESTDOMAIN"
$PWD/rsdns cn -d $TESTDOMAIN -n cn.$TESTDOMAIN -r arecord.$TESTDOMAIN
echo "Update CNAME record: cn.$TESTDOMAIN - aaaarecord"
$PWD/rsdns cn -d $TESTDOMAIN -n cn.$TESTDOMAIN -r aaaarecord.$TESTDOMAIN -U
