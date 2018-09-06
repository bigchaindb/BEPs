```
shortname: BEP-42
name: Handling new transaction models and storage schemas
type: Informational
Status: Raw
editor: Vanshdeep Singh <vanshdeep@bigchaindb.com>
contributors: Lev Berman <ldmberman@gmail.com>
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

This section advises on how to approach backwards-incompatible upgrades of the Tendermint chain - the type of updgrades when Tendermint can not build blocks on top of the existing chain.

BigchainDB operators need a convenient way to do the following:

1. Stop building blocks for the old Tendermint chain at the same height as all the other operators.
2. Continue building blocks using the new Tendermint chain starting from that height.
3. Replay the whole blockchain after a migration.
4. Join the network as a new validator after a migration.

Additionally, BigchainDB HTTP API usage has to be seamless - all the HTTP responses has to look like there were no migrations.

Below we describe how to perform a migration while meeting the postulated requirements. Note that there is no limitation on the number of consequent migrations that can be performed this way.

#### 1. Stop building blocks

To make sure no blocks are committed after the agreed height, we propose an election process:

- The initiator creates an election.
- The validators vote for the election. Once the election is concluded, new blocks are not committed by the validators. New transactions from the users are rejected. New blocks sent by Tendermint are rejected too. Further in this BEP we refer to the height at which the election is concluded as the migration height. The conditions for resuming the chain operation are described below.

To perform a migration election, we propose 2 CLI commands.

The initiator executes:

```
$ bigchaindb election migrate-abci-chain new --private-key /home/user/.tendermint/config/priv_validator.json
```

The command outputs the migration ID. The initiator distributes it among other members of the network. The process is similar to adding new validators.

Validators vote for the migration:

```
$ bigchaindb election approve <election-id> --private-key /home/user/.tendermint/config/priv_validator.json
```

Validators can watch how the election goes:

```
$ bigchaindb election status <election-id>
```

Outputs:
```
votes_recieved=<Sum_of_votes_recieved>
votes_allocated=<Sum_of_votes_allocated_in_election>
network_size=<Total_network_power>
election_status=<Election_status>
```

#### 2. Start the new chain

Validators have to install and launch the new version of Tendermint. They need to prepare a new `genesis.json`. The new genesis file has to contain the validator set, the application hash (both at the migration height), and the identifier of the new Tendermint chain (`chain_id`).

`chain_id` is generated and stored by BigchainDB upon conclusion of the migration election. When Tendermint sends this ID as part of the `InitChain` ABCI request, BigchainDB understands that the user has switched to a new Tendermint version so BigchainDB switches to accept new transactions and blocks.

To offer a convenient way to get the data, we propose a CLI command:

```
$ bigchaindb status
```

Its output can be extended over time to solve different purposes. For a start, it has to contain the latest known list of validators, the latest known app hash, and the identifier of the Tendermint chain.
```
{
    "chain_id": "...",
    "validators": [{
        "pub_key": {
            "type": "...",
            "value": "..."
        },
        "power": "...",
        "name": "..."
    },
    "app_hash": "..."
}
```

Validators upgrading Tendermint are supposed to execute the command above and copy the validators, the app hash, and the chain ID into their `genesis.json`.

Validators joining the network after the migration take the genesis file from existing validators, as usual.

The status command can be always used to see the validator set and the app hash of the latest known block and the identifier of the current Tendermint chain. Note that `chain_id` is only reported after Tendermint sends it as part of the `InitChain` ABCI request.

#### 3. Replay the blockchain

In order to replay the chain up to the migration height, we need to either keep the old Tendermint version running or skip replaying the corresponding part of the chain = archive the chain. We consider the former to be a huge hassle so we describe an archiving scheme further in this BEP.

When a validator replays the chain after a migration, it does not suffice for him to know `genesis.json` - he also needs the archive of the old chain.

Therefore, after the migration election is concluded, each validator has to create a chain archive and keep it together with `genesis.json`. If `genesis.json` is published somewhere, the archive should be published alongside.

To generate the archive, validators can use the `mongodump` command (comes together with `mongod`):

```
$ mongodump --archive=bigchaindb.archive
```

The command creates the `bigchaindb.archive` file.

To replay the chain from scratch, one has to get `genesis.json` and the archive, start BigchainDB without Tendermint, and restore from the archive:

```
$ mongorestore --archive=bigchaindb.archive
```

Note that we do not take a dump of the Tendermint storage. After a migration, Tendermint starts building a new chain according to the new format so no old data is carried over by design.

Afterwards, Tendermint may be started.

Note that although a node can join the network and work to some extent without restoring from the archive, it is not able to properly validate transactions so restoring from the archive is a must.

There might be more than one migration, so the initial chain might go from height 0 to 33277, the second chain might go to height 88234, the third chain can go from 88234 up to the recent height. In this case the validator has to use an archive containing archived blocks from height 0 to height 88234. There is no need to keep the old archives around.

#### 4. Join the network after a migration

When a validator joins the network after a migration, he needs to receive `genesis.json` and the chain archive directly from another member of the network or from some public place.

The validator needs to restore from the archive before starting Tendermint as it is described in the previous section.

Note that new validators joining a permissioned network inherently have to trust the place they are getting data from - there is no generic way to assess the validity of `genesis.json` and the archive upon joining the network.

At the moment, there are no tools to verify the integrity between `genesis.json` and the archive. Such tools are subject to work on separately. In the future, one might need less trust in particular parties by downloading `genesison.json` and the archive from two different places and verifying the integrity. At the moment it is strongly recommended to download them from a single most trusted place.

#### Tendermint chain height

Upon concluding a migration, BigchainDB is advised to store the current migration height in a separate MongoDB collection. Every time BigchainDB needs to communicate the height to Tendermint, it needs to subtract the migration height from the height of the BigchainDB chain.

With every consequent migration, the migration height is overwritten.

#### Seamless HTTP API usage

Since BigchainDB retains the blocks built by old Tendermint chains, the HTTP API offers the exact same experience as if there were no migrations.

#### Migration election specs

We introduce a new [transaction operation](./tendermint_migration_election.yaml), `TENDERMINT_MIGRATION_ELECTION`, for the purpose of implementing migration elections. `TENDERMINT_MIGRATION_ELECTION` is an extension of `CREATE`. Its asset contains the new ABCI chain ID.

Election conclusion is inherited from [the TEP definition](../18#concluding-election).

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
