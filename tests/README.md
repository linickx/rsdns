# RSDNS Tests

## Running the tests locally

To run the tests locally you need: 

1. To setup a `~/.rsdns_config` file with at least `$RSUSER`, `$RSAPIKEY` & `$RSPATH` set. 
2. To define a domain for the test script wi the  `$MYDOMAIN` variable. This has to be a new domain that can be created & deleted.

Then, just `./tests/run.sh`

## Running on Travis-CI

Replace the secure variables in `.travis.yml` with your own, for example.

```
$ travis encrypt RSUSER=rsdns
$ travis encrypt RSAPIKEY=abc123
$ travis encrypt UKAUTH=0
$ travis encrypt MYDOMAIN=rsdns.travis-ci.org
```

## Exit Codes

The following is a list of exit codes to describe build failure.

### Standard
* 0 = ok
* 1 = Input/Var Missing
 
### Custom from rsdns scipts
* 102 = API Status Exception
* 101 = API Status ERROR
* 100 = API Authentication Failure (Key)
* 98 = API Authentication Failure (Token)
* 97 = API Authentication Failure (Management Server)
* 96 = Record (to update) not found
* 95 = Failed to load auth.sh
* 94 = Failed to auth func.sh
* 93 = Domain not found
* 92 = Record not found
* 50 = Missing dependency

### Custom Exit Codes for tests
* 404 = Domain Not Found
* 400 = No Test DOMAIN Set