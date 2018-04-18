```
shortname: 10/SAAR
Name: A Strangler Application Approach to Rewriting Some Code in Go
type: Informational
status: Raw
Editors: Alberto Granzotto <alberto@bigchaindb.com>
Contributors: Vanshdeep Singh <vanshdeep@bigchaindb.com>
```

# A Strangler Application Approach to Rewriting Some Code in Go

## Abstract
This document describes an experimental architecture for BigchainDB Server, illustrated in the diagram below. It replaces a small amount of Python code with Go code, allowing the BigchainDB team to experiment with Golang with low risk while achieving several other goals, including easier migration to new versions of Tendermint and higher performance.

## Motivation
BigchainDB 2.0 Alpha 1 has been developed using BigchainDB 1.3 as a starting point. Design decisions that were correct for the first generation of BigchainDB, are now challenged by the integration of a new consensus algorithm (managed by Tendermint). Specifically, the Tendermint state machine runs in a separate process, and communicates with BigchainDB using multiple channels.

BigchainDB 2.0 Alpha 1 is now the composition of three different system (MongoDB, Tendermint, and BigchainDB itself). This setup generates different problems: a) managing multiple services together adds overhead and complicates deployment; b) the current design makes some calls going from BigchainDB to Tendermint to BigchainDB again, penalizing performance; c) there is data duplication between LevelDB and MongoDB; d) we need to maintain [`py-abci`][pyabci], while the official implementation of the [ABCI][abci] interface is in Golang; e) the logic to validate transactions is spread across multiple files and it's difficult to manage, and a heavy refactoring is needed; f) the configuration is spread across BigchainDB and Tendermint.

## Overview
In this BEP, we evaluate a rewrite of some parts of BigchainDB in another language, specifically Golang. The benefits are multiple: Golang it is a fairly simple language, easy to learn and read; it is shown to be efficient and faster than Python and can compile to a binary file; it is used in several big projects, and it's the language of choice for major blockchain projects: this simplifies code reuse if we need it in the future, and allows us a tighter integration with Tendermint.

Rewriting a system to another language is a risky and possibly endless process. To minimize the risk, an incremental approach is proposed. The approach is incremental in the following sense:
- It is divided into different subsequent steps.
- Every step is self contained and outputs a usable system.
- Every step should be a reasonably small unit of work.
- It is not a requirement to fully migrate the system, the rewrite can be stopped at any point.

From a bird's-eye perspective, the idea is to replace the Tendermint process BigchainDB depends on, with our own process: `bigchaindb-go` (this is not the final name). The new `bigchaindb-go` will allow a tighter implementation with Tendermint Core. The goal is to incrementally replace the HTTP API endpoints implemented in Python with new ones implemented in `bigchaindb-go`.

This approach is not new. Martin Fowler defined this approach in 2004, in his blog post [Strangler Application][strangler:application]. A [paper has been presented][strangler:paper] the same year, during a conference on extreme programming (XP2004). Benefits of this approach, compared to other approaches like _big bang refactoring_, has been proven valid by many case studies ([1][strangler:case-study-1], [2][strangler:case-study-2]).

### Step 1: Posting a transaction
Posting a transaction to BigchainDB is one of the main primitives of the system.

The goal of _Step 1_ is to expose through `bigchaindb-go` one single endpoint fully compatible with [`POST /api/v1/transactions`][bdb:post-tx], and implement the logic required to satisfy the [ABCI][abci] interface.

The integration between the existing BigchainDB Server code (written in Python) and the new `bigchaindb-go` is described in the following section.

About the existing BigchainDB Server:
- All the HTTP API endpoints will still be served from the existing code.
- The endpoint `POST /api/v1/transactions` will be just a _pass through proxy_ to the `bigchaindb-go` implementation.
- A new endpoint `POST /api/v1/validate` will be implemented, to check the validity of a transaction (this endpoint will be used by `bigchaindb-go` to do the actual validation, and will give us more time to actually focus on the experiment). Since we are *asking for information*, using the HTTP verb `GET` would be more appropriate, but using `GET` with an HTTP request body is [controversial][get:controversial].

About the new `bigchaindb-go` Server:
- It implements the endpoint `POST /api/v1/transactions`.
- It implements the ABCI interface (`check_tx`, `begin_block`, `deliver_tx`, `end_block`, `commit`), and communicates to the local MongoDB instance to write transactions once they are validated, ideally using the [in process interface][abci:in-process].

The following diagram shows how the two systems work together.

![Interaction between the existing BigchainDB Server and bigchaindb-go][diagram]

It is important to notice that the existing BigchainDB Server will only **read** from the shared MongoDB instance, while `bigchaindb-go` will be the only process able to **write** data in the underlying database.

### Other steps
If the experiment is successful, other API endpoints can be easily integrated one by one into the `bigchaindb-go` implementation. This BEP does not cover this part for now.

## Rationale
Instead of exposing the new `POST /api/v1/validate` endpoint from the Python codebase, there are techniques to [call Python functions from Go code][cgo-python]. While this is probably more performant and allows a deeper integration, we might end up with a more complex solution.

It's worth mentioning that two alternate approaches have been internally discussed before writing this BEP.

### Approach A
The first approach entailed implementing the ABCI proxy app in Golang and then creating a corresponding abstraction in BigchainDB so that the new Golang ABCI proxy can talk to BigchainDB. This approach was more conservative as it required defining and implementing an abstraction layer to talk to ABCI proxy app.

### Approach B
The second approach required to re-implement the validation logic first, and integrated it with the ABCI interface. This approach was too risky because it would require more work to have something functional and deliverable in the short term.

## Backwards Compatibility
The system is :100:% compatible with the existing one. That's the goal of the incremental approach. Because of this, integration tests are crucial.

## Implementation
The idea of this BEP is to share ideas on how we can move forward. For now, there is no specific implementation to describe how to do this in Go. We will create a public repository to experiment on this instead. This will give us some hands-on experience to understand how the actual implementation can be.

## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.


[leveldb:corruption]: https://github.com/google/leveldb/issues?utf8=%E2%9C%93&q=corrupt+is%3Aissue
[bdb:changelog]: https://github.com/bigchaindb/bigchaindb/blob/07f03dbd5e903bbc35555ef4a00fe84b2e2dd122/CHANGELOG.md
[bdb:post-tx]: https://docs.bigchaindb.com/projects/server/en/v2.0.0a1/http-client-server-api.html#post--api-v1-transactions?mode=mode
[pyabci]: https://github.com/davebryson/py-abci/
[strangler:application]: https://www.martinfowler.com/bliki/StranglerApplication.html
[strangler:paper]: http://cdn.pols.co.uk/papers/agile-approach-to-legacy-systems.pdf
[strangler:case-study-1]: https://paulhammant.com/2013/07/14/legacy-application-strangulation-case-studies/
[strangler:case-study-2]: http://agilefromthegroundup.blogspot.de/2011/03/strangulation-pattern-of-choice-for.html
[abci]: http://tendermint.readthedocs.io/en/master/introduction.html#abci-overview
[abci:in-process]: https://github.com/tendermint/abci#in-process
[diagram]: ./diagram.jpg
[get:controversial]: https://stackoverflow.com/a/983458/597097
[cgo-python]: https://www.datadoghq.com/blog/engineering/cgo-and-python/
