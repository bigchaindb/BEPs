```
shortname: BEP-15
name: Ethereum Integration Tools & Demo 1
type: Standard
status: Raw
editor: Troy McConaghy <troy@bigchaindb.com>
reviewers: Gautam Dhameja <gautam@bigchaindb.com>
```

# Abstract

This BEP outlines the requirements of a "Hello world" demo (with tools and documentation) showing the basic concepts of how an Ethereum DApp can read from, or write to, a BigchainDB network. A smart developer should be able to build something more sophisticated once they understand the concepts illustrated by the demo.

# Motivation

There is a large community of Ethereum developers. We'd like to make it easy for them to use BigchainDB as part of their Ethereum projects, particularly for data storage and retrieval. We'd like them to be able to do that from their smart contract code, if possible.

By creating some tools, and a demo showing how to use them, we hope to help Ethereum developers get started using BigchainDB in their projects.

# Specification

## Reading Data from an External BigchainDB Network

An Ethereum smart contract can't just make a call to the outside world and take action based on the response. The reason is that the blockchain must be deterministic and replayable: one must be able to get back to the current state by starting with the initial state and replaying all the stored transactions in order. That wouldn't be possible if some of the current state depended on external information that changed or is no longer available. That doesn't mean external data can't be used at all. It just means that external data must first be stored in the blockchain, making it internal, before it can be used.

An external service is required: an oracle. While we could implement a new oracle, it would be non-trivial and a deviation from BigchainDB's focus. Therefore, to implement this BEP, we should use an existing, well-known oracle service or software.

The demo must illustrate how to query a BigchainDB network (such as the BigchainDB Testnet), and how to write data (based on the query response) to:

1. the Public Ethereum network (Mainnet). [Oraclize](https://docs.oraclize.it/) is one good option for this.
1. a private, permissioned network that can run EVM smart contracts (e.g. powered by Hyperledger Burrow or Ethermint). Stargate, a toolkit by Oraclize, could be used for this.

## Writing Data to an External BigchainDB Network

To write data to any BigchainDB network, one must construct a valid BigchainDB transaction then send it to the network using an HTTP POST request.

To be valid, a BigchainDB transaction must be signed. To sign a transaction, the software doing the signing must have a private key. If the software doing the signing is an EVM smart contract, then the private key must be stored in the associated blockchain: it wouldn't be private anymore! All the smart contracts in that blockchain would be able to sign things with that private key.

Therefore the private key must not be stored in the EVM blockchain network. It must be stored outside, and therefore BigchainDB transaction signing must also be done outside the EVM blockchain network. Broadly speaking, there are two options to demonstrate:

1. End users hold their own private keys and never share them with anyone. Therefore they must also sign all their BigchainDB transactions.
1. A separate service holds all the private keys and does all the BigchainDB transaction signing.

In the demo, the trigger event that (ultimately) causes a BigchainDB transaction to get posted to a BigchainDB network, must originate within an EVM blockchain network (e.g. the Ethereum Mainnet or a private blockchain running EVM smart contracts). Typically, a separate service will monitor the EVM blockchain to watch for that event. When the trigger event happens, the service will post the appropriate BigchainDB transaction to the BigchainDB network. (It might construct and sign that transaction itself, or it might get it pre-signed from an end user and just hold on to it.)

If the BigchainDB transaction comes from an end user, then that end user might want to put the hash of their BigchainDB transaction (i.e. the transaction "id" value) in the EVM smart contract, if possible. That way, the EVM blockchain would contain proof that the separate service didn't tamper with their BigchainDB transaction before posting it to the BigchainDB network.

The data to be written to the BigchainDB network could come from the inside EVM blockchain, outside the EVM blockchain, or both. The implementer of the demo can decide which possibility to demonstrate.

The separate service should be written using Python or JavaScript, using the [BigchainDB driver](http://docs.bigchaindb.com/projects/server/en/master/drivers-clients/index.html) for the chosen language.

Other than demonstrating the two cases listed above, we leave all other design decisions up to the implementors of this BEP.

## Additional Requirements

All smart contract code to implement this BEP must be written in Solidity.

Errors and other exceptions must be handled gracefully.

A new public GitHub repository must be created under the `bigchaindb` organization on GitHub, to store all code and documentation written to implement this BEP.

The code should be licensed under an Apache v2 license. The documentation should be licensed under a Creative Commons Attribution 4.0 International license.

The documentation should explain all the steps to set up and run the demo (both writing and reading), including how to set up the external service and the oracle service. That documentation could be written using one or more Markdown files.

The smart contracts must be tested on one of the Ethereum Testnets, if possible. The testing code, and some example results, should be included in the GitHub repo. There should be documentation about how to run the tests.

# Rationale

We required that all smart contract code be written in Solidity because, at the time of writing, Solidity was the most commonly-used EVM smart contract language.

# Change Process

BigchainDB GmbH has a process to improve BEPs like this one. Please see [BEP-1 (C4)](../1) and [BEP-2 (COSS)](../2).

# Implementation

Once an implementation exists (i.e. in the above-mentioned GitHub repository), add a link to it here.

# Copyright Waiver

<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law, all contributors to this BEP
  have waived all copyright and related or neighboring rights to this BEP.
</p>
