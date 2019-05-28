```
shortname: BEP-???
name: A short description of the current UTXO implementation
type: informational
status: Draft
editor: Vanshdeep Singh <vanshdeep@bigchaindb.com>
```

## Description
The UTXO (unspent transaction output) of each transaction is tracked using the a [merkle tree](https://en.wikipedia.org/wiki/Merkle_tree). The merkle root of this tree is used as the app hash and returned to Tendermint during `commit`. Below is a short summary of how the UTXO is calculated,

- Each unspent output is considered as a leaf node in the merkle tree.
- The unspent outputs are stored in `utxo` collection in MongoDB.
- The unspent outputs are added/removed from the `utxo` collection with each incoming transaction i.e. during `commit` when the transactions are being processed for bulk write the UTXO are updated in the `utxo` collection.
- Once the transactions in a block are processed and stored, all the objects in the `utxo` collection are fetched.
- This list of unspent outputs fetched from the `utxo` collection is considered as the leaves of the UTXO merkle tree. Refer the image below,
- The list of leaves is hashed and sorted after which the merkle root is calculated by pairing adjacent leaves.

![Merkle Tree](https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Hash_Tree.svg/800px-Hash_Tree.svg.png)

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
