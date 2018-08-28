```
shortname: BEP-42
name: Handling new transaction models and storage schemas
type: Informational
Status: Raw
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
3. Tendermint introduces a hard fork because of breaking changes


## Handling Hard Forks

### Type 1 scenarios
In case of change to spec it might not be possible to port all existing validated transaction to the new format. In such cases one needs to make a distinction between transactions which have already been validated and stored in the Blockchain from new incoming transactions. Furthermore, a suitable trigger is needed so that the network can collectively jump to the new logic else there could be situations wherein the network might not be able to commit any new blocks because of honest nodes running different validation logic. So, it is apparent that a mechanism for transitioning to this new validation logic is needed. Below is one such procedure to achieve the same,

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

- Each node operator needs to approve the [TEP](https://github.com/bigchaindb/BEPs/pull/44) proposal in order for the validation logic to be upgraded.

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


### Type 3 scenarios
When Tendermint migrates to a new version wherein new validation rules are not compatible with the existing blockchain it induces a hard fork. Tendermint encourages its users to create a new blockchain and archive the current blockchain at particular agreed upon (by the network) height. In order to support such changes BigchainDB would also need to archive the existing blockchain because the alternative approach is to run two Tendermint processes, one with the older validation logic and another with the newer validation logic. Since the latter approach is a huge hassle for BigchainDB users it would be best to recommend our user to archive the blockchain.

Following describes how to archive and start a new blockchain,
- Create a TEP which proposes a block height `h` at which the current blockchain will stop creating any new blocks.
- Once the TEP concludes and the height `h` has been chosen, validators stop proposing new blocks once height `h` has been reached.
- At height `h` the merkle root of the UTXO of the current blockchain is provided as the genesis state of the new blockchain.
- The validator set at height `h` should be used as the validator set in the genesis of the new blockchain.
- Since from Tendermint's point of view this is a new blockchain, block height will start from `0` which implies that BigchainDB would need to archive the existing blocks collection. All other collections would remain as is.


## Copyright Waiver

<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law, all contributors to this BEP
  have waived all copyright and related or neighboring rights to this BEP.
</p>

