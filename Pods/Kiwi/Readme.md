# Simple BDD for iOS
[![Build Status](https://travis-ci.org/kiwi-bdd/Kiwi.svg?branch=master)](https://travis-ci.org/kiwi-bdd/Kiwi)

Kiwi is a Behavior Driven Development library for iOS development.
The goal is to provide a BDD library that is exquisitely simple to setup and use.

## Why?
The idea behind Kiwi is to have tests that are more readable than what is possible with the bundled test framework.

Tests (or rather specs) are written in Objective-C and run within the comfort of Xcode to provide a test environment that is as unobtrusive and seamless as possible in terms of running tests and error reporting.

Specs look like this:

```objective-c
describe(@"Team", ^{
    context(@"when newly created", ^{
        it(@"should have a name", ^{
            id team = [Team team];
            [[team.name should] equal:@"Black Hawks"];
        });

        it(@"should have 11 players", ^{
            id team = [Team team];
            [[[team should] have:11] players];
        });
    });
});
```

## Documentation
The [Kiwi Wiki](https://github.com/kiwi-bdd/Kiwi/wiki) is the official documentation source.

## Getting it
The best way to get Kiwi is by using [CocoaPods](https://github.com/cocoapods/cocoapods).
For all the installation details, check out the [Wiki](https://github.com/kiwi-bdd/Kiwi/wiki)

## Support
For all the questions / suggestions you have, that aren't bug reports please use our [Google Group](https://groups.google.com/forum/#!forum/kiwi-bdd)

