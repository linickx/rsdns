# !/bin/bash

echo "Create a record: arecord.$TESTDOMAIN"
$PWD/rsdns a -d $TESTDOMAIN -n arecord.$TESTDOMAIN -i 1.2.3.4
echo "Update a record: arecord.$TESTDOMAIN - 1.2.3.3"
$PWD/rsdns a -d $TESTDOMAIN -n arecord.$TESTDOMAIN -i 1.2.3.3 -U
