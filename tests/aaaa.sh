# !/bin/bash

echo "Create aaaa record: aaaarecord.$TESTDOMAIN"
$PWD/rsdns aaaa -d $TESTDOMAIN -n aaaarecord.$TESTDOMAIN -i 4321:0:1:2:3:4:567:89aa
echo "Update aaaa record: aaaarecord.$TESTDOMAIN - 4321:0:1:2:3:4:567:89ab"
$PWD/rsdns aaaa -d $TESTDOMAIN -n aaaarecord.$TESTDOMAIN -i 4321:0:1:2:3:4:567:89ab -U
