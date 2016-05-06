# !/bin/bash

echo "Create TXT record for $TESTDOMAIN"
$PWD/rsdns txt -d $TESTDOMAIN -n $TESTDOMAIN -D "v=spf1 a:arecord.$TESTDOMAIN ~all"