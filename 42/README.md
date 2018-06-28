```
shortname: [42/HARD-FORKS]
name: Handling Hard Forks
type: information
Status: raw
editor: Vanshdeep Singh <vanshdeep@bigchaindb.com>
```

## Description

Currently, there is no active strategy to address breaking changes in BigchainDB 2.0 i.e. there is no general approach to migration such that breaking changes in transaction specs can be handled. This document is an attempt in quantifying scenarios wherein a breaking might occur and propose a generalized strategy to handle these situations.

## Hard fork scenarios
1. Change in any of the transaction specs
    - Change in signature algorithm
    - Change in hashing functions
    - Change in schema
2. Change in storage schema

## Handling Hard Forks

### Type 1 scenarios
In case of change to spec it might not be possible to port all existing validated transaction to the new format. In such cases one needs to make a distinction between transactions which have already been validated and stored in the Blockchain from new incoming transactions. Furthermore, a suitable trigger is needed so that the network can collectively jump to the new logic else there could be situations wherein the network might not be able to commit any new blocks because of honest nodes running different validation logic. So, it is apparent that a mechanism for transitioning to this new validation logic is need. Below is one such procedure to achieve the same,

- In order to decide when the validation logic should be upgraded to its newer version a TEP is initiated which defines the future block `height` at which to upgrade and the corresponding `BigchainDB` class to use.

   NOTE: It is assumed that the new validation logic is implemented by extending the existing `BigchainDB` class and at the time of starting BigchainDB an instance of each of these classes is passed to the ABCI `App` i.e.,
   ```python
   validation = {
       "v1": {
           "start_block_height": 0,
           "validation_class": "BigchainDB",
       }
       "v2": {
           "start_block_height": 20940394,
           "validation_class": "BigchainDBv2",
       }
       ...
   }
   ```

- Each node operator needs to approve the TEP proposal in order for the validation logic to be upgraded.

- If a super-majority of the network i.e. `> 2/3` voting power agrees with the change and the proposed height is still lies in the future then the proposed TEP is commit-ed and a new validation version is added (see above)

NOTE: There can only be one-and-only one ongoing hard fork i.e. concurrent hard forks should not be not allowed.


### Type 2 scenarios

These scenarios don't actually impact the sanctity of the blockchain but rather the shape of the data. In order to handle such scenarios following two approaches can used,

#### Approach 1

Create migration scripts for each new upgrade i.e. with each new release which results in a change in the shape of the data we create corresponding migrations scripts. Needless to say that writing such scripts might be tedious and in the worst case users can only incrementally upgrade to newer version

#### Approach 2

Tendermint allows to create follower nodes which don't validate transactions but rather just receive them and record them. We use this migrate data in the following manner,

- The node operator create an new node which follows its existing validator node. 
- This will allow this new follower node to replay all the blocks but store them according to the new data shape. 
- Once this new follower node fully syncs with the current validator node the node operator shuts down Tendermint and changes the `prox_app` address in `config.toml` to the follower nodes BigchainDB server.
- The operator can then go ahead and discard the existing older BigchainDB server and the corresponding data.

The above process ensure the node keeps validating and accepting new blocks while the new database is being populated. The downtime experienced is when the Tendermint is shutdown to change the `proxy_app` address.


## Copyright Waiver

To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
