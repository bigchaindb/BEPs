```
shortname: 10/SAAR
Name: A Strangler Application Approach to Rewriting Some Code in Go
type: Informational
status: Raw
Editors: Alberto Granzotto <alberto@bigchaindb.com>
Contributors: Vanshdeep Singh <vanshdeep@bigchaindb.com>, Lev Berman <ldmberman@gmail.com>
```

# A Strangler Application Approach to Rewriting Some Code in Go

## Abstract
This document describes an experimental architecture for BigchainDB Server, illustrated in the diagram below. It replaces a small amount of Python code with Go code, allowing the BigchainDB team to experiment with Golang with low risk and at the same time make the step forward the long-term goals of the increased transaction rate and better platform reliability.

## Motivation
BigchainDB 2.0 Alpha 1 has been developed using BigchainDB 1.3 as a starting point. Design decisions that were correct for the first generation of BigchainDB, are now challenged by the integration of a new consensus algorithm (managed by Tendermint). Specifically, the Tendermint state machine runs in a separate process, and communicates with BigchainDB using multiple channels.

BigchainDB 2.0 Alpha 1 is now the composition of three different system (MongoDB, Tendermint, and BigchainDB itself).

This setup generates different problems:

1. managing 3 services together adds operational overhead and complicates distribution;

    Blockchain clients are commonly independent binaries. This is true for Bitcoin, Ethereum, and Monero.

2. the current design raises certain performance concerns;

    The TCP communications between BigchainDB and Tendermint, the transaction validation implemented in Python, and Crypto-Conditions implemented in Python might significantly contribute to the performance degradation. The detailed benchmarks SHOULD follow.

3. there is data duplication between LevelDB and MongoDB;

    Currently, the only way to replace the database backend in Tendermint is to implement a Tendermint-based service in Go, with the database interface implemented according to the needs.

4. we need to maintain [`py-abci`][pyabci], which is not an official implementation;

5. the configuration is spread across BigchainDB and Tendermint.

    A way to overcome the issue is to implement a Tendermint-based service in Go, with the overwritten config loading/parsing mechanisms.

The BEP does not aim to solve all of the problems described above but suggests a reasonable small experimental first step towards the new design.

## Problem breakdown

* The BEP suggests to replace the remote ABCI proxy app with the HTTP server that serves `POST /api/v1/validate`.
* The BEP suggests to produce a custom binary based on Tendermint where
  * the Golang ABCI interface implementation either directly executes ABCI commands or proxies them to the HTTP server;
  * the HTTP server proxies `POST /api/v1/transactions` to the corresponding endpoint in BigchainDB Server.

## Overview
In this BEP, we evaluate a rewrite of some parts of BigchainDB in Golang.

The main reasons to choose Go are defined by the following long-term goals:

  - the most efficient ABCI communications, offered by an in-process ABCI proxy app written in Golang;
  - using a single storage;
  - straightforward compilation of BigchainDB and Tendermint into a single binary.

Also, Go is generally faster than Python.

Moreover, Go seems to be more common among the blockchain projects. If it is the case, finding tools to solve problems is going to be easier with the Golang codebase.

Rewriting a system to another language is a risky and possibly endless process. To minimize the risk, an incremental approach is proposed. The approach is incremental in the following sense:
- It is divided into different subsequent steps.
- Every step is self contained and outputs a usable system.
- Every step should be a reasonably small unit of work.
- It is not a requirement to fully migrate the system, the rewrite can be stopped at any point.

From a bird's-eye perspective, the idea is to replace the Tendermint process BigchainDB depends on, with our own process: `bigchaindb-go` (this is not the final name). `bigchaindb-go` will allow a tighter implementation with Tendermint Core. The goal for the future is to incrementally replace the HTTP API endpoints implemented in Python with new ones implemented in `bigchaindb-go`.

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

#### Call Python from Go?

Instead of exposing the new `POST /api/v1/validate` endpoint from the Python codebase, there are techniques to [call Python functions from Go code][cgo-python]. While this is probably more performant and allows a deeper integration, we might end up with a more complex solution.

#### Profiling and benchmarking BigchainDB

In order to gain confidence in the application rewrite, we profiled the main BigchainDB process.
We identified the work that constitutes the major part of the collected profile. We isolated the corresponding functions and compared them to the prototyped Golang implementations. Go equivalents turned out to be
faster by an order of magnitude.

Read the detailed report [in appendix 1][profiling-bigchaindb].

#### Profiling the TCP connection

To get a sense of the performance impact of the TCP connection, we ran a simple comparison test. Tendermint provides a nice benchmarking tool, [tm-bench][tm-bench], which measures transactions and blocks per second, using some proxy app.

As a proxy app, we used a simple kv-store implemented in Golang. The proxy-app was configured both as an integrated Tendermint process and as an external process communicating over a TCP connection. We ran benchmarks using a number of different parameters to isolate the effect of load, number of connections, logging, and test duration on overall performance.

Over several test conditions, we observed an average performance loss of 14% due to the TCP connection. It is worth noting, however, that under sustained high load, transaction rates for both internal and external processes were identical. This suggests that while the TCP connection slows down performance when Tendermint has idle cycles, under high load, our bottleneck occurs on the Tendermint side. This conclusion is supported by observing the connection rate under sustained but low load, which reveals no significant difference in the internal and external transaction rates.

Results can be seen in detail [in appendix 2][benchmark-tcp-connection].

#### Picking a migration approach

The following approaches were considered while developing the design for the BEP:

##### Approach A
The approach entailed implementing the ABCI proxy app in Golang and then creating a corresponding abstraction in BigchainDB so that the new Golang ABCI proxy can talk to BigchainDB. This approach was more conservative as it required defining and implementing an abstraction layer to talk to ABCI proxy app.

##### Approach B
The approach required to re-implement the validation logic and to integrate it with the ABCI interface. This approach is too risky because it requires more work to have something functional and deliverable in the short term.

## Backwards Compatibility
The system is 100% compatible with the existing one. That's the goal of the incremental approach. Because of this, integration tests are crucial.

## Implementation
The idea of this BEP is to share ideas on how we can move forward. For now, there is no specific implementation to describe how to do this in Go. We will create a public repository to experiment on this instead. This will give us some hands-on experience to understand how the actual implementation can be.

## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.


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
[profiling-bigchaindb]: ./profile_bigchaindb.md
[benchmark-tcp-connection]: ./benchmark_tcp_pipeline.md
[tm-bench]: https://github.com/tendermint/tools/tree/master/tm-bench