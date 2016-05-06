# Contributing to rsdns

So you want to contribute? That makes you a rock star! :)

Please take 5 minutes to read this and familiarise yourself with these guidelines.

## The first rule of GitHub

If you've not used github before getting started can be a bit daunting, if you want to propose a feature or fix a bug start by [Forking](https://help.github.com/articles/fork-a-repo/) that will create a local copy of rsdns in your github account.

Next [create a branch](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/) and make your changes in there. Branching not only fits neatly into the github work flow (*you'll notice a button appear in github that says "create a pull request for this branch"*) but it keeps git tidy under the hood.
Finally [create a pull request](https://help.github.com/articles/creating-a-pull-request/) (*PR*). The PR will create an issue for me to review and make it easy to include your suggestions.

## Errors and Bug Fixes

If you have a problem with rsdns you can [create an issue](https://github.com/linickx/rsdns/issues); please ensure that all issues include an output of the error message and any steps you've tried to fix. Where possible, please suggest a fix via a *PR*.

All PRs must pass the tests on travis-ci, where possible please include a new test with your PR.

## New Features

If you have an idea to improve rsdns, that's great!

1. Where possible, please implement new features as an additional `-switch` or if relevant a new script file `rsdns-feature.sh`
2. Please do not use any additional dependencies such as Perl or Python.
3. All new features must have a unit test, see tests/README.md for more information.

Please ask if you have any problems with these. 

## Documentation

English is my native language but that doesn't mean I'm perfect at it, inspection and suggestions from the grammar police are welcome.

## Thanks for reading!
