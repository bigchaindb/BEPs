```
shortname: ?/UTXO-IMPL
name: A short discription of the current UTXO implementation
type: informational
status: Draft
editor: Vanshdeep Singh <vanshdeep@bigchaindb.com>
```

## Description
The UTXO (unspent transaction output) of each transaction is tracked using the a merkle tree. The merkle root of this tree is used as the app hash and retuned to Tendermint during `commit`. Below is a short summary of the UTXO is calculated,

- Each unspent output is considered as a leaf node in the merkle tree.
- The nodes are added/removed with each incoming transaction i.e. during `commit` when the transactions are being processed for bulk write the UTXO are updated in the `utxo` collection.
- Once all the transactions in a block are processed and stored, all the objects in the `utxo` collection are fetched and stored i.e. a list of leaves is prepared.
- The merkle root is calculated using this list of leaves.


## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
