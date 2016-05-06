# !/bin/bash

echo "Create CNAME record: cn.$TESTDOMAIN"
$PWD/rsdns a -d $TESTDOMAIN -n cn.$TESTDOMAIN -r arecord.$TESTDOMAIN
echo "Update CNAM record: cn.$TESTDOMAIN - aaaarecord"
$PWD/rsdns a -d $TESTDOMAIN -n cn.$TESTDOMAIN -r aaaarecord.$TESTDOMAIN -U
