# Example: an Election to add a new Validator

## Start a new Election

Alice (power `20`), Bob (power `10`), Carly (power `10`) and Daniel (power `10`) want to add Frank to the Network. Alice is the Initiator, and starts a new Election. Alice generates a `CREATE` transaction with `50` vote tokens. The transaction looks roughly like this:

```json
{
  "asset": {
    "data": {
      "type": "election",
      "name": "upsert-validator",
      "version": "1.0",
      "matter": "After the meeting we had on May 23rd, 2018, we decided to add Frank to the Network.",
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
      "amount": "20",
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
      "amount": "10",
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
      "amount": "10",
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
      "amount": "10",
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


## Cast a Vote

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
      "amount": "10",
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
  ],
  "version": "2.0"
}
```

## Implement the Election
pass
