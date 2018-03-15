```
shortname: 8/CRASH-RECOVERY
name: Restore system state after crash
type: standard
status: raw
editor: Vanshdeep Singh <vanshdeep@bigchaindb.com>
```

## Abstract
During runtime it is reasonable to expect a system might crash because of varied reasons viz. power shutdown, hardware failure etc. Such failures for BigchainDB imply that it might end up in an inconsistent state i.e. the ABCI proxy app state running inside BigchainDB might differ from that of Tendermint. This state difference could cause BigchainDB to not start at all after crash. Hence, it is necessary that an appropriate methodology should be developed to restore the system to a consistent state.


## Motivation
For BigchainDB, a crash which can cause the state to be inconsistent could leave the system inoperable. The 'achilles heel' for BigchainDB is its `commit` function during which a new block with its transactions is written to the disk. Furthermore, [UTXO](https://bitcoin.org/en/glossary/unspent-transaction-output) merkle tree is updated based on these new transactions. An overview of what happens during `commit` is given below,

1. Store metadata of the transactions.
1. Store assets of the transactions.
1. Store transactions and update UTXO.
1. Store Block.

These write operations are not [atomic](https://en.wikipedia.org/wiki/ACID) so any intermediate failure could result in an inconsistent state. For example, 

- Consider a scenario where the system fails after step 2 i.e. we have a state where such metadata and assets exists which don't belong to any transaction (also called zombie assets and zombie metadata).
- Consider a scenario wherein the system fails during setup 3 i.e. we would have a state which zombie metadata, zombie assets and zombie transactions (because the block to which these transactions belong is written in 4.). Moreover we might have an inconsistent UTXO.

Hence it is crucial that the system should be able to recover from such crashes and bring itself to a consistent state.


## Specification
The ABCI proxy app adheres to the following state machine <sup>[1](https://tendermint.readthedocs.io/en/master/introduction.html#intro-to-abci) [2](https://tendermint.readthedocs.io/en/master/app-development.html)</sup> to commit a new block,

```
BEGIN BLOCK
    ↓
DELIVER TRANSACTION
    ↓
END BLOCK
    ↓
COMMIT
```

Here `BEGIN BLOCK` is used to indicate a new incoming block and `DELIVER TRANSACTION` is used to iteratively deliver each transaction in this new block. `END BLOCK` is called by Tendermint when the set of transactions being commit-ed in the new block have been delivered (NOTE: the block height of the new block is passed as argument to `end_block`). Lastly, `COMMIT` is called and it is expected that all the state mutations are done during `COMMIT`. So, as previously discussed the transactions are stored and the block is added in the database.

Since `COMMIT` API is mission critical and any crash during `COMMIT` can cause the system to be inconsistent so it is necessary that there should be a pre-commit state stored to the disk which should store the metadata of the state mutations being performed during actual `COMMIT` i.e. pre-commit object should at least store the following data,

```json
{ "id": "pre_commit",
  "height": 10,
  "transaction_ids": ["txid1", "txid2", "txidn"],
}
```

The above object should be stored in a separate collection `pre_commit` during `END BLOCK`. Note that the `pre_commit` collection should have only 1 object with `'id': 'pre_commit'` because next write to `pre_commit` collection implies that the previous block was successfully `commit`ed. 

### Recovering from crash
In case of a crash following inconsistent object(s) might exists the database,

- Zombie assets
- Zombie metadata
- Zombie transactions, inconsistent UTXO

Following from the previous section, the metadata for `COMMIT` is stored in `pre_commit` collection which stores the block height and a list of transaction ids which will be written during `COMMIT`. Using this information, BigchainDB performs the following steps when started,

- Check if there is mismatch between latest height from `blocks` collection and `pre_commit` collection.
- If there is no height mismatch then proceed normally.
- If there is a height mismatch then the height difference should be at most 1 else a panic message is displayed and the system should exit.
- The latest block height retrieved from `blocks` collection should be less than or equal to that from `pre_commit` collection.
- The block object retrieved from `pre_commit` collection provides the list of transaction ids which were to be commited.
- In case the height retrieved from `blocks` collection is less than that of `pre_commit` collection then all the zombie assets, metadata and transactions are deleted. Furthermore, the UTXO is reverted up till the highest block height retrieved from `blocks` collection.
- Once the zombie objects are removed from their respective collections the `pre_commit` collection object is reverted to the highest block height retrieved from `blocks` collection.


## Reference(s)
- [ABCI state machine](http://tendermint.readthedocs.io/projects/tools/en/master/app-development.html#blockchain-protocol)
- [Tendermint crash recovery](https://github.com/tendermint/tendermint/issues/1254)


## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
