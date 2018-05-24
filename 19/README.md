```
shortname: [20/UPSERT-VALIDATORS]
name: Dynamically add/update/remove validators at runtime
type: standard
Status: raw
editor: Vanshdeep Singh <vanshdeep@bigchaindb.com>
```

## Description

The current [BEP 3](https://github.com/bigchaindb/BEPs/blob/master/3/README.md) spec for adding new validators requires that the node administrators coordinate when dynamically adding a new validator i.e. all the node operators have to simultaneously execute `upsert-validator` in order to ensure that the validator is added on all the nodes. A lack of coordination can result in a situation wherein only a part of the network updates their validator set which could eventually lead to a network hangup. Furthermore, for a sufficiently large network the coordination itself can become a tedious task.
Another major issue with the current implementation is that a new dynamically added validator (`V_i`) cannot be propagated to any new dynamically added validators added after `V_i` i.e. consider the following scenario,


- Given a 4 node network wherein the `genesis.json` file contains each of the four nodes `{N1,N2,N3,N4}` a validator.
- When a new node `N5` is to be dynamically added, each node executes `upsert-validator` on their respective nodes (including `N5`) and adds `N5`.
- When another new node `N6` needs to be added then each of the nodes in the network `{N1,N2,N3,N4,N5}` execute `upsert-validator` to add the new node `N6`.
- At this point the node `N6` won't see `N5` as a validator because the `genesis.json` would only contain `{N1,N2,N3,N4}` as validators.
- Since `N5` was added dynamically and `upsert-validator` only mutates the local validator set of a given node it implies that in order for the `N6` to see `N5` as a validator it would have to execute `upsert-validator N5_PUB_KEY N5_POWER` on its own node at the exact block height (when syncing with the network) when `N5` was previously added by the network.


From the above description it is evident that propagating dynamically added validators is a major hassle with huge possibility of errors.


## Technical details

To solve the aforementioned issue, following change to the behaviour of `upsert-validator` is being proposed. We use the transaction election process (TEP) proposed in [BEP 18](https://github.com/bigchaindb/BEPs/pull/44) to automate and synchronize the operation on the validator set.

Consider a network of 4 nodes `{A,B,C,D}` if now if a node A wishes to add a new node `E` to the network then following steps should be followed,

1. Node `A` executes

```
$ bigchaindb upsert-validator E_PUBKEY E_POWER
node_upsert_request_id
```

The above command `POST`s a TEP `CREATE` transaction and return the `node_upsert_request_id`. The asset data is of the following form,
```json
{
    "type": "election",
    "name": "upsert-validator",
    "version": "1.0",
    "args": {
        "public_key": "Wn2DedV9OA0LJJjOxr7Sl7jqCSYjQihA6dCBX+iHaEI=",
        "power": 10,
        "node_id": "82190eb6396bdd80b83aef0f931d0f45738ed075"
    }
}
```

NOTE: The `CREATE` transaction is signed using the private key generated and stored by Node `A`'s' Tendermint in `priv_validator.json`.


2. The `node_upsert_request_id` is then manually sent (via email or message) to rest of the nodes in the network.

3. The node operator can list the `upsert-validator` request using,

```
$ bigchaindb upsert-validator show-request node_upsert_request_id
public_key=Wn2DedV9OA0LJJjOxr7Sl7jqCSYjQihA6dCBX+iHaEI=
power=10
node_id=82190eb6396bdd80b83aef0f931d0f45738ed075
```

The above command list the details about the node which is being added/updated/deleted from the network.

4. If the node operator aggrees to the operation being proposed by the `node_upsert_request_id` then they can vote on the same using the following,

```
$ bigchaindb upsert-validator approve-request node_upsert_request_id
```

The above command `POST`s a `TRANSFER` transaction casting the vote of the node for the given TEP.
NOTE: The `TRANSFER` transaction is signed using the private key generated and stored by Tendermint in `priv_validator.json`.


## Backwards Compatibility 
The approach suggested in this specification is entirely different. The previous approach involved storing `upsert-validator` request in a seperate collection, which will not be required anymore. So migrating to the implementation of this new approach would involve to optionally drop collection holding the `upsert-validator` request.


## Implementation

### Assignee(s)
Primary assignee(s): @kansi

### Targeted Release
BigchainDB 2.0


## Reference(s)
- [BEP 3](https://github.com/bigchaindb/BEPs/blob/master/3/README.md)
- [BEP 18](https://github.com/bigchaindb/BEPs/pull/44)
- [Tendermint validators](http://tendermint.readthedocs.io/en/master/specification/validators.html)


## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
