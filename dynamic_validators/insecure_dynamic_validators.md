# Dynamically add/remove validators at runtime (Insecure version)

## Problem Description
In the current state of tendermint bdb, validator nodes are specified in the Tendermint config file before starting the node. It is necessary that the users should be able to dynamically add new validators.

**NOTE**: This document presents an insecure implementation intended for bigchaindb tendermint MVP.

### Technical details
Tendermint allows the abci client application to return a list of validators during `end_block` call. If the client doesn't wish to modify the validators an empty list should be returned. The return value allows the client to dynamically add/remove validators. Note that the return value could be thought of as a (validators) diff of desired validators list and current validators list. Below is an example of validators diff,
```json
[{"pub_key":{"type":"ed25519","data":"4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A"},
  "power":10},
 {"pub_key":{"type":"ed25519","data":"608D839D7100466D6BA6BE79C320F8B81DE93CFAA58CF9768CF921C6371F2553"},
 "power":0}
 ]
```
Note: `"power": 0` implies that the validator should be removed from the validator list. In case this diff is empty the validators remain same. Furthermore, the validators returned during `end_block` are used to update the validators of the given Tendermint node and **not** for the whole network.


## Proposed Change
- Add a new subcommand `bighciandb upsert-validator PUBLIC_KEY POWER` which will allow the node admin to add/update/delete a validator.

- `GET /api/v1/validators` should be introduced to list the current validators.

### Technical challenges
Since node admin can call `upsert-validator` anytime it is necessary to (temporarily) store the payload until `end_block` is called. This implies that just executing `bigchaindb upsert-validator` doesn't imply the validator is add to validators list.

Furthermore, as discussed in [technical details](#technical-details) each/majority (>2/3) nodes in the network need to add the new node to their list of validators in order for the new node to be able to act as a validator. Until then the node may not be able to participate and vote on blocks.


### Storing dynamically added validators
In the previous section it was discussed that it is necessary to (temporarily) store the updates to validators list until `end_block` is executed. Following is one possible solution,

- Store validator diff in a MongoDB collection along with a flag when `bighciandb upsert-validator` (discussed below) is called i.e.,
```json
{"validators": [{"pub_key":{"type":"ed25519","data":"4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A"},
                 "power":10}],
 "sync": true
}
```
- The `"sync"` key is used during `end_block` to decide if a validator update should be returned.
- During `end_block` all the documents with `"sync": true` are aggregated in order based on their insert time stamp and validator diff list is prepared which is returned in `end_blocks` response.

NOTE: a validators diff which results in a change of `>1/3` of voting power will be rejected by tendermint.

### API impact

- A new subcommand `upsert-validator` should be introduced to add/update/delete validators
  - syntax : `bichaindb upsert-validator PUBLIC_KEY POWER`
  - example usage
    - add/update validator
    ```bash
    $ bichaindb upsert-validator 4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A 10
    ```
    - delete validator
    ```bash
    $ bichaindb upsert-validator 4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A 0
    ```

- List validators
  - Uri: `GET /api/v1/validators`
  - response: 
  ```json
  [{"pub_key":{"type":"ed25519","data":"4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A"},
    "power":10},
   {"pub_key":{"type":"ed25519","data":"608D839D7100466D6BA6BE79C320F8B81DE93CFAA58CF9768CF921C6371F2553"},
   "power":0}
   ]
  ```

**NOTE**: when `power: 0` is set for a given validator it is removed from the validators list.

### Workflow overview
Below is a summary of workflow sequence which should be executed in order to add/remove a validator dynamically,
- BigchainDB node operator wishes to add/update/delete a validator from their own node.
- The admin use `bigchaindb upsert-validator` to add the validator,
- BigchainDB stores the payload in a MongoDB collection as follows,
```json
{"validators": [{"pub_key":{"type":"ed25519","data":"4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A"},
                 "power":10}
               ],
 "sync": true
}
```
- The request has been successfully submitted to update the validators.
- Now, when `end_block` is executed, the validators from MongoDB collection are aggregated where `"sync": true`. **NOTE**: the aggregation should be performed by sorting the documents using time stamp.
- The aggregated validators are returned during `end_block` and the corresponding documents are updated i.e. `"sync": false`.


### Security impact
The current implementation is insecure i.e. any user who gains access to a given node can modify its validators. This node could effectively be considered byzantine and the network can tolerate (<1/3) byzantine nodes.

### Performance impact
N/A

### End user impact
N/A

### Deployment impact
N/A

### Documentation impact
The new api introduced should be documented along with its current state of security.


### Testing impact
Following test cases should be included:
- Add a new validator
- Remove a validator
- Change the power of a validator
**NOTE**: The above tests should check if the MongoDB collection is updated and calling `end_block` returns a valid diff. More accurate tests could be written in the integration test suite wherein `http://tendermint:46657/validators` is called to verify the validator changes.

## Implementation

### Assignee(s)
Primary assignee(s): @kansi

### Targeted Release
BigchainDB tendermint MVP


## Dependencies
N/A


## Reference(s)
- [Updating validators during `end_block`](http://tendermint.readthedocs.io/en/master/app-development.html#endblock)
- [Tendermint validators](http://tendermint.readthedocs.io/en/master/specification/validators.html)
