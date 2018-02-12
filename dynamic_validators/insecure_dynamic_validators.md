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
- `PUT /api/v1/validators` should be introduced in order to allow bdb client applications to add/remove validators. The body of the request should contain the validators diff which would then be returned during `end_block`.

- `GET /api/v1/validators` should be introduced to list the current validators.

### Technical challenges
Since bdb clients can call `PUT /api/v1/validators` anytime it is necessary to (temporarily) store the payload until `end_block` is called. This implies that a successful `PUT` doesn't necessarily mean that the validators list has been updated. Moreover, one also needs to consider a scenario wherein the Tendermint node goes offline for whatever reason. When the node is brought back online it would load the validators list from its config file which may not include dynamically added validators.

Furthermore, as discussed in [technical details](#technical-details) each/majority (>2/3) nodes in the network need to add the new node to their list of validators in order for the new node to be able to act as a validator. Until then the node may not be able to participate and vote on blocks.


### Storing dynamically added validators
As discussed in the previous section it is necessary to (temporarily) store the updates to validators list until `end_block` is executed. Furthermore, in case of a node crash it is required that that upon restart the node should be able to recover its dynamically added validators. Following is one possible solution,

- Store the validators in a MongoDB collection along with a flag when `PUT /api/v1/validators` (discussed below) is called i.e.,
```json
{"validators": [],
 "sync": true
}
```
- The sync flag is used during `end_block` to decide if a validator update should be returned.
- The sync flag is set to `true` when api `PUT /api/v1/validators` is called and the `"validators"` are updated.
- Whenever the sync flag is set to `true`, `end_block` will call `http://tendermint:46657/validators`, calculate the diff with the list of validators retrieved from mongodb and return it.
- When bigchaindb starts the sync flag should be set to `true`.
- In case the sync flag is set to `false`, it implies that the validators are synced and `end_block` shall return `[]` (empty validator diff).


### API impact
Following new api endpoints should be introducted,

- Add/remove validators
  - Uri: `PUT /api/v1/validators`
  - Body: 
  ```json
  [{"pub_key":{"type":"ed25519","data":"4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A"},
    "power":10},
   {"pub_key":{"type":"ed25519","data":"608D839D7100466D6BA6BE79C320F8B81DE93CFAA58CF9768CF921C6371F2553"},
   "power":0}
   ]
   ```
   - response:
     - `200` i.e. the request was correctly formed and the MongoDB collection has been updated
     - `400` i.e. there was issue with the request payload i.e. value for `"pub_key"` or `"power"` was invalid.

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
Below is a summary of worflow sequence which should be executed in order to add/remove a validator dynamically,
- BigchainDB client wishes to add/remove validators from their own node.
- The client calls `PUT /api/v1/validators` with the following payload,
```json
[{"pub_key":{"type":"ed25519","data":"4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A"},
  "power":10},
 {"pub_key":{"type":"ed25519","data":"608D839D7100466D6BA6BE79C320F8B81DE93CFAA58CF9768CF921C6371F2553"},
 "power":0}
 ]
```
where `"power": 0` indicates that the key will removed from the given node.
- BigchainDB stores the payload in a MongoDB collection as follows,
```json
{"validators": [{"pub_key":{"type":"ed25519","data":"4E2685D9016126864733225BE00F005515200727FBAB1312FC78C8B76831255A"},
                 "power":10},
                {"pub_key":{"type":"ed25519","data":"608D839D7100466D6BA6BE79C320F8B81DE93CFAA58CF9768CF921C6371F2553"},
                 "power":0}
               ],
 "sync": true
}
```
- The bigchainDB client has successfully submitted a request to update the validators.
- Now, when `end_block` is executed, the validators from MongoDB collection are aggregated where `"sync": false`. **NOTE**: the aggregation should be performed by sorting the documents using timestamp.
- The aggregated validators are returned during `end_block` and the corresponding documents are updated i.e. `"sync": true`.


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
