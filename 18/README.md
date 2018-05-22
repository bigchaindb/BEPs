```
shortname: [18/TEP]
name: Transactional Election Process
type: standard
status: raw
editor: Alberto Granzotto <alberto@bigchaindb.com>
```


# Transactional Election Process

## Abstract
<!-- The abstract is a short (~200 word) description of the technical issue being addressed. -->
This specification introduces the new concept of **Election**. An Election is an asynchronous process that when successful triggers Network wide changes synchronously (i.e. at the same *block height*). An Election is started by any Validator in the Network, called **Initiatior**. The Election itself and all cast Votes are transactions, hence stored in the blockchain. This enables new Validators to replay Network changes incrementally, while syncing.

## Motivation
<!--The motivation is critical for BEPs that want to change the BigchainDB protocol. It should clearly explain why the existing protocol BEP is inadequate to address the problem that the BEP solves. BEP submissions without sufficient motivation may be rejected outright.-->
Changing the shape of a BigchainDB Network at runtime is an important requirement. While this BEP does not address this issue directly, it wants to solve the limitations we had with [Upsert Validators][BEP-3] by giving a tool that can be used this and other situations.

The basic idea is to formalize the concept of an Election storing its data in a [BigchainDB Transaction Spec v2][BEP-13].
By storing it in a BigchainDB Network, it allows Members to vote asynchronously, and Validators to apply changes synchronously.

## Specification
<!--The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations. It MAY describe the impact on data models, API endpoints, security, performance, end users, deployment, documentation, and testing.-->

At any point in time, a Member of a BigchainDB Network can start a new Election.This Member is called **Initiator**.

An Election is a transaction representing the matter of change, and some Vote tokens. The Initiator issues a `CREATE` transaction with the `amount` set to the total number of Validators, and transfer one vote token per Validator using the transaction `outputs`.

At this point the Election starts. Independently, and asynchronously, each Validator can spend its Vote Token to an Election Address to show agreement on the matter of change. The Election Address is the `id` of the first `CREATE` transaction. Once a Vote Token has been transferred to that address, it is not possible to transfer it again, because there private key is not known.

During the `end_block` call, all transactions about to be committed are checked. Every transfer of a vote token triggers a functions that counts the number of positive votes of Election over the number of voters. If the ratio is greater than ⅔, then the current validator commits the change. Given the BFT nature of the system, all non-Byzantine Validator will commit the change at the same block height.

Each Validator checks every new transaction that is about to be committed in a block. The process is roughly the following:
1. If the transaction is **not** a valid Vote, return.
4. If `asset.data.id` is **not** a valid Election, return.
2. If the Election has less than ⅔ of positive votes, return.
3. Execute the logic to implement the Election.

###  Validate Vote
A Validator must be able to discern valid Votes from invalid ones. The process is roughly the following:

1. If the transaction is **not** a `TRANSFER`, return false.
2. If `metadata.type` is **not** `vote`, return false.
3. If `inputs.owners_before` is **not** a Validator, return false.
5. Return true.

### Validate Election
A Validator must be able to discern valid Elections from invalid ones. The process is roughly the following:
1. `type`: must contain the string `election`.
2. `name`: name of the election.
3. `version`: version number.
4. `matter`: a human readable, short paragraph on the matter of change.
5. If `inputs.owners_before` is **not** a Validator, return.
6. If every `outputs.owners_after.amount` is **not** exactly `1`, return.
7. If `outputs.owners_after` does **not** contain exactly all Validators, return.
8. Apply any other validation rule enforced by the code specific to the election itself, return false if it fails.
9. Return true.

### Extra: Vote delegation
Vote delegation is trivial. Let's consider a Network of three Members: Alice, Bob, and Carly. Alice is the Initiator, and starts a new Election. Alice generates a `CREATE` transaction with three vote tokens, one per each Member. Bob wants to delegate his vote to Carly, so he transfers his output to Carly, granting her two votes she can spend in the way she wants.

### Example: an Election to add a new Validator
Alice, Bob, Carly and Daniel want to add Frank to the Network. Alice is the Initiator, and starts a new Election. Alice generates a `CREATE` transaction with four vote tokens, one per each Member. The transaction looks roughly like this:

```json
{
  "asset": {
    "data": {
      "type": "election",
      "name": "upsert-validator",
      "version": "1.0",
      "args": [
        "Frank's public key",
        "Frank's node id",
	"Frank's hostname",
	"New voting power"
      ]
    }
  },
  "id": "e...047",
  "inputs": [
    {
      "fulfillment": "p...34C",
      "fulfills": null,
      "owners_before": [
        "Alice's public key"
      ]
    }
  ],
  "metadata": null,
  "operation": "CREATE",
  "outputs": [
    {
      "amount": "1",
      "condition": {
        "details": {
          "public_key": "Alice's public key",
          "type": "ed25519-sha-256"
        },
        "uri": "ni:///sha-256;c...7-8Y?fpt=ed25519-sha-256&cost=131072"
      },
      "public_keys": [
        "Alice's public key"
      ]
    },
    {
      "amount": "1",
      "condition": {
        "details": {
          "public_key": "Bob's public key",
          "type": "ed25519-sha-256"
        },
        "uri": "ni:///sha-256;b...123?fpt=ed25519-sha-256&cost=131072"
      },
      "public_keys": [
        "Bob's public key"
      ]
    },
    {
      "amount": "1",
      "condition": {
        "details": {
          "public_key": "Carly's public key",
          "type": "ed25519-sha-256"
        },
        "uri": "ni:///sha-256;c...13C?fpt=ed25519-sha-256&cost=131072"
      },
      "public_keys": [
        "Carly's public key"
      ]
    },
    {
      "amount": "1",
      "condition": {
        "details": {
          "public_key": "Daniel's public key",
          "type": "ed25519-sha-256"
        },
        "uri": "ni:///sha-256;c...7-8Y?fpt=ed25519-sha-256&cost=131072"
      },
      "public_keys": [
        "Daniel's public key"
      ]
    }
  ],
  "version": "2.0"
}
```

Now that the Election has been created, each Member can cast their vote. Bob starts:
```json
{
  "asset": {
    "id": "e...047"
  },
  "id": "a...123",
  "inputs": [
    {
      "fulfillment": "f...qE8p",
      "fulfills": {
        "output_index": 1,
        "transaction_id": "e...047"
      },
      "owners_before": [
        "Bob's public key"
      ]
    }
  ],
  "metadata": {
    "type": "vote"
  },
  "operation": "TRANSFER",
  "outputs": [
    {
      "amount": "1",
      "condition": {
        "details": {
          "public_key": "Election Address",
          "type": "ed25519-sha-256"
        },
        "uri": "ni:///sha-256;b...123?fpt=ed25519-sha-256&cost=131072"
      },
      "public_keys": [
        "Election Address"
      ]
    }
  ]
  "version": "2.0"
}
```

## Rationale
<!--The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.-->
Another idea to implement this protocol is to use a multi signature transaction.

## Backwards Compatibility
<!--All BEPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The BEP must explain how the author proposes to deal with these incompatibilities. BEP submissions without a sufficient backwards compatibility treatise may be rejected outright.-->
This BEP is fully backwards compatible.

## Implementation
<!--The implementations must be completed before any BEP is given status "stable", but it need not be completed before the BEP is accepted. While there is merit to the approach of reaching consensus on the BEP and rationale before writing code, the principle of "rough consensus and running code" is still useful when it comes to resolving many discussions of API details.-->

# Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

[BEP-3]: ../3
[BEP-13]: ../13
