```
shortname: BEP-18
name: Transactional Election Process
type: Standard
status: Draft
editor: Alberto Granzotto <alberto@bigchaindb.com>
contributors: Vanshdeep Singh <vanshdeep@bigchaindb.com>, Lev Berman <lev@bigchaindb.com>
```

# Transactional Election Process

## Abstract
This specification introduces the new concept of **Election**. An Election is an asynchronous process that when successful triggers Network wide changes synchronously (i.e. at the same *block height*). An Election is started by any Validator in the Network, called **Initiatior**. The Election itself and all cast Votes are transactions, hence stored in the blockchain. This enables new Validators to replay Network changes incrementally, while syncing.

## Motivation
Changing the shape of a BigchainDB Network at runtime is an important requirement. While this BEP does not address this issue directly, it wants to solve the limitations we had with [Upsert Validators (BEP-3)][BEP-3] by giving a tool that can be used this and other situations. BEP-3 addresses a really interesting use case: adding a Member to a running Network. Since changes in the Validator Set are not themselves expressed as transactions but are included into the metadata of an arbitrary block, all the nodes have to add a Validator simultaneously—if less than the majority of the nodes attempt to include a Validator, the block fails and the whole Network can stuck. Since those changes are **not** stored in the blockchain itself, a new Node that needs to sync with the Network will fail in validating blocks from a specific *height* on. The *height* will match the one of the first block voted by a new Validator that was **not** included in the `genesis.json` file (and Tendermint will fail with `Invalid commit (last Validator set size) vs (number of precommits)`).

The abstract version of the problem is "make Network wide decisions". We need a way for Members to vote on proposals, and implement them as soon as the quorum of ⅔ is reached. In this BEP, a proposal is named *Election*, a vote is a fungible token formalized with the capitalized name *Vote Token*. Elections and Vote Tokens are stored in the blockchain, so a new Node that syncs with the Network will be able to replay them locally, and reach the same state of all other Members.

The basic idea is to formalize the concept of an Election storing its data in a [BigchainDB Transaction Spec v2 (BEP-13)][BEP-13]. Implementations of this BEP might introduce new operations for a *BigchainDB Transaction Spec v2*, and new validation rules for the Election transaction and the Vote transaction. By storing it in a BigchainDB Network, it allows Members to vote asynchronously, and Validators to apply changes synchronously.

## Specification
At any point in time, a Member of a BigchainDB Network can start a new Election.This Member is called **Initiator**.

An Election is a transaction representing the matter of change, and some Vote tokens. Election transactions follow the `CREATE` transaction spec. The Initiator issues an election transaction. The transaction has multiple `outputs`, one per Validator. Each output is populated with the public key of the Validator, and an amount equal to the power of the Validator.

At this point the Election starts. Independently, and asynchronously, each Validator can spend its **Vote Tokens** to an **Election Address** to show agreement on the matter of change. The Election Address is the `id` of the election transaction. Once the Vote tokens has been transferred to that address, it is not possible to transfer it again, because their private key is not known.

During the `end_block` call, all transactions about to be committed are checked. Every transfer of a vote token triggers a function that counts the number of positive votes of Election over the number of voters. If the ratio is greater than ⅔, then the current Validator commits the change. Given the BFT nature of the system, all non-Byzantine Validator will commit the change at the same block height.

Each Validator checks every new transaction that is about to be committed in a block. The process is roughly the following:

1. If the transaction is **not** a valid Vote, return.
2. If the Vote is for a **not** valid Election, return.
3. If the Election **including** the current Vote has less than ⅔ of positive votes, return.
4. If the Election **excluding** the current Vote has more than ⅔ of positive votes, return. (It has been concluded already.)
5. If the Election **excluding** the current Vote has less than ⅔ of positive votes and **including** the current Vote has more than ⅔ of positive votes, execute the logic to implement the Election.

### What is a valid Vote?
A Validator must be able to discern valid Votes from invalid ones. A valid vote is a transaction where all the following conditions are true.

1. It's a valid BigchainDB `TRANSFER` transaction.
1. It conforms to the JSON Schema of a `VOTE` transaction.
1. It spends one or more Vote Tokens to the Election Address.

Note: At the time of writing, all BigchainDB JSON Schema files (YAML files) could be found in the `bigchaindb/common/schema/` directory of [the bigchaindb/bigchaindb repository on GitHub](https://github.com/bigchaindb/bigchaindb).

### What is a valid Election?
A Validator must be able to discern valid Elections from invalid ones. A valid Election is a transaction where all the following conditions are true.

1. It's a valid BigchainDB `CREATE` transaction.
1. It conforms to one of the JSON Schemas for BigchainDB elections (e.g. `VALIDATOR_ELECTION` or `CHAIN_MIGRATION_ELECTION`).
1. `outputs` has as many entries as the total number of Validators.
1. Each Validator is represented in `outputs`.
1. Each entry in `outputs` can be spent by only one Validator, and the amount attached to it is equal to the power of that Validator.

**Note: Any change in the Validator Set makes old Elections invalid. Check [approach 2](#generalized-approach-approach-2) for a process that can tolerate a certain degree of change to the Validator Set.**

**Note 2: Pending validator changes do not make elections invalid.**

Note 3: At the time of writing, all BigchainDB JSON Schema files (YAML files) could be found in the `bigchaindb/common/schema/` directory of [the bigchaindb/bigchaindb repository on GitHub](https://github.com/bigchaindb/bigchaindb).

### Election statuses
The lifecycle of an Election is described by the three statuses:

- `ongoing`
- `concluded`
- `inconclusive`

`ongoing` are valid Elections denoted by committed transactions, which did not receive a sufficient amount of votes, and the validator set has not changed since their creation.

Elections become `concluded` after they receive a sufficient amount of votes. See [Concluding Election](#concluding-election) for more details on how elections are concluded.

Elections are considered `inconclusive` if they had not been concluded by the time the validator set was changed.

### Extra: Vote delegation
Vote delegation is trivial. Let's consider a Network of three Members: Alice, Bob, and Carly. Alice is the Initiator, and starts a new Election. Alice generates an election transaction with three outputs, one per each Member. Bob wants to delegate his vote to Carly, so he transfers his output to Carly, granting her more votes she can spend in the way she wants.

### About Election finality
Let the Validator Set be denoted by ![V_t][eq_V_t] at time ![][eq_t], a member of a BigchainDB Network can start a new Election. This member is called **Initiator** (![v_it][eq_v_it] s.t. ![v_it in V][eq1]) .

#### Valid Election
An Election proposal is a transaction representing the matter of change. The _Initiator_ ![v_it][eq_v_it], issues an election transaction ![][EC_t]. The election MUST contain outputs  such that each output is populated with the public key of the Validator ![][eq_v_k] s.t. ![][v_k_in_V_t], and an amount equal to the current power ![][eq_p(v_k, t)]  of the Validator.

#### Voting
Once ![][EC_t] is committed in a block, the election starts. Independently and asynchronously, each Validator may spend its vote tokens (referred as ![][T_k]) to the election address ![][EC_t_addr] to show agreement on the matter of change. The Election Address ![][EC_t_addr] is the `id` of the transaction ![][EC_t].

NOTE: Once the vote tokens ![][T_k] have been transferred to the election address ![][EC_t_addr] it is not possible to transfer it again, because the private key is not known.

#### Concluding Election
At time ![][t_n] let,
- Validator set be denoted by ![][V_t_n] s.t. ![][vi_in_V_tn]
- ![][vm_in_Vm], where ![][V_m] denotes the set of public keys who voted for election ![][EC_t]
- ![][T_new] be the newly received vote token


##### Constrained approach (Approach 1)
In the constrained approach any change to the Validator Set invalidates all the elections which were initiated with a different Validator Set.

If below conditions hold true then the election is concluded and the proposed change is applied,
1. ![][V_tn_equals_V_t]
2. ![][constrain_condition1] where ![][v_k_in_V_t] and ![][T_k] denotes the vote tokens received at ![][EC_t_addr] prior the the current token
3. ![][constrain_condition2]


##### Generalized approach (Approach 2)
The generalized constraints can tolerate a certain degree of change to the Validator Set.

If below conditions hold then the election is concluded and the proposed change is applied,

1. ![][general_condition1]
2. ![][constrain_condition1] where ![][v_k_in_V_t] and ![][T_k] denotes the vote tokens received at ![][EC_t_addr] prior the the current token
3. ![][constrain_condition2]

The above constraints state that if the Validators with which an election ![][EC_t] was initiated still hold super-majority then the election can be concluded.

##### Approach 1 vs Approach 2
Approach 1 is easier to comprehend and explain because of how constrained it is.

Approach 2 allows elections to survive validator set changes within certain limits.

For a start, we plan to implement Approach 1 because of its simplicity. We are able to switch to Approach 2 in the future by the means of a soft fork with additional support for the new type of elections described in Approach 2.

### Applying change
During the `end_block` call, all transactions about to be committed are checked. Every vote token triggers a function (which implements **Approch 1** or **Approach 2**) that checks the necessary conditions. If the function returns `True` then the current Validator applies the suggested change in ![][EC_t]. Given the BFT nature of the system, all non-Byzantine Validator will commit the change at the same block height.

### Command-line interface
The interface for creating an election depends on the type of the election and has to be described by the BEP documenting this particular type.

The CLI command for creating a new election should use the following template:
```
$ bigchaindb election new <type> ...
```

The CLI command for approving an election does not depend on its type. It should follow the template:
```
$ bigchaindb election approve <election_id> --private-key PATH_TO_PRIVATE_KEY
```

Moreover, we do not need to know the election type to display its status. The command should look like:
```
$ bigchaindb election show <election_id>
```

The expected output is:
```
status=<status>
```


Additional data, specific to a particular election type, can be added to the output of the status command.

## Rationale
A *blockchain* is a Byzantine fault tolerant, replicated state machine. BigchainDB is a permissioned one, this means that the nodes that validate transactions and create blocks know about each other: their identity is not anonymous. This is not true for networks like Bitcoin or Ethereum: in those permissionless blockchains the Validator set changes over time and the identity is anonymous.

The reasoning behind this BEP exploits the permissioned nature of a BigchainDB Network, and the instant finality of the blocks.

In this context, a Member of a BigchainDB Network can start an election on a specific matter by calling out all Members. The election is successful when the supermajority (⅔ of the Network) agree on the matter.

The *matter* is domain specific, and can be something like adding a new Validator to the Network, adding support for a new transaction model, and so on. Each *matter* has some specific logic (code) that is triggered when the election is successful. All non byzantine nodes reach the same conclusion on the election at the same block height, and they all trigger the same logic if the election is successful (even if they voted against).

#### About the conclusion threshold
The conclusion threshold we choose in this BEP is ⅔ of the Network power. Although it matches the threshold used by consensus algorithms powering permissioned blockchains with instant finality, it does not, in general, have to be this big for custom elections.

The consensus engine ensures all the validators agree on the exact block they commit. Therefore, byzantine actors can not make one group of validators think a particular election is concluded while at the same time making the other group think the same election is not concluded, even when the threshold is less than ⅔.

#### About Election finality
We had some discussions around the *finality* of an election. In the original design, the current Validator Set is used to decide the outcome of an election. Any change to the Validator Set would make all existing elections invalid. To overcome this issue, another approach has been proposed and documented. This new approach can tolerate a certain degree of change to the Validator Set.

## Backwards Compatibility
This BEP is fully backwards compatible.

## Implementation
This BEP proposes a framework to handle Elections. An implementation of this BEP is another BEP that defines the scope of the Election and all the details related to it.

By now, this BEP has been implemented in:
- [Dynamically add/update/remove Validators at runtime (BEP-21)][BEP-21]

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

[BEP-3]: ../3
[BEP-13]: ../13
[BEP-21]: https://github.com/bigchaindb/BEPs/pull/45
[eq_V_t]: http://latex.codecogs.com/gif.latex?V_t
[eq_t]: http://latex.codecogs.com/gif.latex?t
[eq_v_it]: http://latex.codecogs.com/gif.latex?v_%7Bit%7D
[eq1]: http://latex.codecogs.com/gif.latex?v_%7Bit%7D%20%5Cin%20V_t
[EC_t]: http://latex.codecogs.com/gif.latex?EC_t
[eq_v_k]: http://latex.codecogs.com/gif.latex?v_k
[v_k_in_V_t]: http://latex.codecogs.com/gif.latex?v_k%20%5Cin%20V_t
[eq_p(v_k, t)]: http://latex.codecogs.com/gif.latex?P%28v_k%2C%20t%29
[T_k]: http://latex.codecogs.com/gif.latex?T_k
[t_n]: http://latex.codecogs.com/gif.latex?t_n
[T_new]: http://latex.codecogs.com/gif.latex?T_%7Bnew%7D
[EC_t_addr]: http://latex.codecogs.com/gif.latex?EC_%7Bt%2C%20addr%7D
[V_t_n]: http://latex.codecogs.com/gif.latex?V_%7Bt_%7Bn%7D%7D
[vi_in_V_tn]: http://latex.codecogs.com/gif.latex?v_i%20%5Cin%20V_%7Bt_%7Bn%7D%7D
[vm_in_Vm]: http://latex.codecogs.com/gif.latex?v_m%20%5Cin%20V_m
[V_m]: http://latex.codecogs.com/gif.latex?V_m
[V_tn_equals_V_t]: http://latex.codecogs.com/gif.latex?V_%7Bt_%7Bn%7D%7D%20%5Cequiv%20V_t
[constrain_condition1]: http://latex.codecogs.com/gif.latex?T_%7Bnew%7D%20&plus;%20%5Csum_%7Bk%7D%20T_k%20%3E%20%5Cfrac%7B2%7D%7B3%7D%20%5CBigg%28%20%5Csum_k%20P%28v_k%2C%20t%29%20%5CBigg%29
[constrain_condition2]: http://latex.codecogs.com/gif.latex?%5Csum_%7Bk%7D%20T_k%20%3C%3D%20%5Cfrac%7B2%7D%7B3%7D%20%5CBigg%28%20%5Csum_k%20P%28v_k%2C%20t%29%20%5CBigg%29
[general_condition1]: http://latex.codecogs.com/gif.latex?%5Csum_m%20P%28v_m%2C%20t_n%29%20%3E%20%5Cfrac%7B2%7D%7B3%7D%20%5CBigg%28%5Csum_i%20P%28v_i%2C%20t_n%29%20%5CBigg%29
