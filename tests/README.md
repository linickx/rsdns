# RSDNS Tests

`run.sh` is the main test script that then executes each sub test.

For instances where I felt groups were necessary sub scripts exist, for example `a.sh` is a group of a record tests and `delete.sh` is all the delete commands.

The `rsdns` scripts exit with code 0 for normal (ok) or something else for a failure (see below), this _should_ cause travis to report a build issue.

## Running the tests locally

To run the tests locally you need: 

1. To setup a `~/.rsdns_config` file with at least `$RSUSER`, `$RSAPIKEY` & `$RSPATH` set. 
2. To define a domain for the test script with the  `$MYDOMAIN` variable. This has to be a new domain that can be created & deleted.

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
* 102 = API Exception (unknown status)
* 101 = API Status = ERROR
* 100 = API Authentication Failure (Key)
* 98 = API Authentication Failure (Token)
* 97 = API Authentication Failure (Management Server)
* 96 = Record (to update) not found
* 95 = Failed to load auth.sh
* 94 = Failed to load func.sh
* 93 = Domain not found
* 92 = Record not found
* 50 = Missing dependency

### Custom Exit Codes for tests
* 44 = Domain Not Found
* 40 = No Test Domain Set i.e. `$MYDOMAIN` missing.