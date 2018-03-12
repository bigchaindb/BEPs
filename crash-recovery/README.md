```
shortname: ?/CRASH-RECOVERY
name: Restore system state after crash
type: standard
status: raw
editor: Vanshdeep Singh <vanshdeep@bigchaindb.com>
```

## Abstract
Unexpect crashes are bound to occur when BigchainDB is deployed in production which could leave the system in an inconsistant state. Hence it is necessary that an appropriate methodology should be developed to restore the system to a consistant state.


## Motivation
For BigchainDB, a crash which can cause the state to be inconsistent could leave the system inoperable. The 'achilles heel' for BigchainDB is its `commit` function during which a new block with its transactions is written to the disk. Furthermore, UTXO merkle tree is updated based on these new transactions. An overview of what happens during `commit` is given below,

1. Store metadata of the transactions.
1. Store assets of the transactions.
1. Store transactions and update UTXO.
1. Store Block.

These write operations are not transactional so any intermediate failure could result in an inconsistent state. For example, 

- Consider a scenario where the system fails after step 2 i.e. we have a state where such metadata and assets exists which don't belong to any transaction (also called zombie assets and zombie metadata).
- Consider a scenario wherein the system fails during setup 3 i.e. we would have a state which zombie metadata, zombie assets and zombie transactions (because the block to which these transactions belong is written in 4.). Moreover we might have an inconsistent UTXO.

Hence it is crucial that the system should be able to recover from such crashes and bring itself to a consistent state.


## Specification
The ABCI proxy app adheres to the following state machine to commit a new block,

```
BEGIN BLOCK
    ↓
DELIVER TRANSACTION
    ↓
END BLOCK
    ↓
COMMIT
```

Here `BEGIN BLOCK` is used to indicate a new incoming block and `DEVLIER TRANSACTION` is used to iteratively deliver each transaction in this new block. `END BLOCK` is called by Tendermint when the set of transactions being commit-ed in the new block have been delivered (NOTE: the block height of the new block is passed as argument to `end_block`). Lastly, `COMMIT` is called and it is expected that all the state mutations are done during `COMMIT`. So, as previously discussed the transactions are stored and the block is added in the database.

Since `COMMIT` api is mission critical and any crash during `COMMIT` can cause the system to be inconsistent so it is necessary that there should be a pre-commit state stored to the disk which should store the metadata of the state mutations being performed during actual `COMMIT` i.e. pre-commit object should at least store the following data,

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

Following from the previous section, the metadata for `COMMIT` is stored in `pre_commit` collection which stores the block height and a list of transaction ids which will be written during `COMMIT`. Using this information we perform the following setups, 

- Check if there is mismatch between latest height from `blocks` collection and `pre_commit` collection.
- If there is no height mismatch then proceed normally.
- If there is a height mismatch then the height difference should be at most 1 and latest block height retrieved from `blocks` collection should be less than that from `pre_commit` collection.
- The block object retrieved from `pre_commit` collection provides the list of transaction ids which were to be commited.
- If all the transaction ids from the above list exist in the `transactions` collection then the crash occurred after all the transactions were written and before the block could be written. In this case the block with new block height can be written to `blocks` collection using metadata from `pre_commit` collection.
- In case all the transaction ids are not present in the `transactions` collection then there could possibly exist zombie assets, metadata or transactions in the database.
- These zombie assets, metadata, transactions should be deleted and the UTXO should be reverted.


## Reference(s)
- [ABCI state machine](http://tendermint.readthedocs.io/projects/tools/en/master/app-development.html#blockchain-protocol)


## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
