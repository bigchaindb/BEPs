```
shortname: 9/TX-CODE-REFACTOR-1
name: Transaction Code Refactoring, Phase 1
type: Standard
status: Raw
editor: Troy McConaghy <troy@bigchaindb.com>
```

# Abstract

This document describes a set of small, specific changes that could be made to transaction-related BigchainDB code, to get the process of refactoring that code started, and to get BigchainDB developers familiar with that code again. Each thing could be done in one pull request.

# Motivation

- We want BigchainDB Server to be able to check if a transaction is valid, even if it conforms to an older version of the transaction spec.
- We want to be able reuse some Python code in both BigchainDB Server and the BigchainDB Python driver, without importing the entire server codebase into the driver codebase (as we do now).
- We want a given BigchainDB network to be able to support RBAC and other specialized business logic. The operators of a particular network should be able to decide what to support and what not to support in their network.
- We want the transaction-related code to be easier to work with in general.

Getting our transaction code to the point where it has everything wanted will take a lot of effort, but one must start somewhere. This BEP lists some specific things that could be done _to get started_.

# Specification

## Long-Term Goals

While these long-term goals won’t be achieved completely by the steps specified in this BEP, they guide what is proposed (and not proposed).

1. Have separate, mutually exclusive code for:
   - transaction construction
   - checking the validity of a transaction
1. Have transaction validation plugins for:
   - checking things that don’t depend on the state (e.g. checking against a JSON Schema), for each version of the transaction spec.
   - checking things that DO depend on the state (e.g. checking if a transaction is attempting to double spend), for each version of the transaction spec.
   - RBAC
   - more!

The idea is that the BigchainDB node operator can decide which transaction validation plugins they will enable. The codebase already has something like a “pluggable validation” system, which is inappropriately named “pluggable consensus”. It only supports one plugin at a time?

## Specific Tasks Proposed

1. Move the code for checking the MongoDB-specific things (listed in https://github.com/bigchaindb/BEPs/blob/master/13/README.md#bigchaindb-server-deviations ) from the webserver code to the transaction-validation code. Maybe only do those checks if the backend database is MongoDB?
1. Use a phrase other than "pluggable consensus" for that feature. See [issue #1779](https://github.com/bigchaindb/bigchaindb/issues/1779).
1. Seperate the code for checking transaction validity from the code for converting a transaction object to/from a Python dict.
1. Separate the code for checking transaction validity from the code for converting a transaction JSON string to/from a Python dict, if there is any such code.
1. Look at [the spec for checking if a version 2.0 transaction is valid](https://github.com/bigchaindb/BEPs/blob/master/13/README.md#transaction-validation). Are all those checks _actually done_? Is all the code for doing those checks in _one logical place_ in the code?

# References

- [How to construct a valid version 2.0 transaction](https://github.com/bigchaindb/BEPs/blob/master/13/README.md#how-to-construct-a-transaction)
- [How to check if a version 2.0 transaction is valid](https://github.com/bigchaindb/BEPs/blob/master/13/README.md#transaction-validation)

# Change Process

This document is governed by the [2/COSS](../2/README.md) (COSS).

# Copyright Waiver

To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.