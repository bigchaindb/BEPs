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
Instead of exposing the new `POST /api/v1/validate` endpoint from the Python codebase, there are techniques to [call Python functions from Go code][cgo-python]. While this is probably more performant and allows a deeper integration, we might end up with a more complex solution.

#### Profiling BigchainDB

In order to gain confidence in the suggested approach, the main BigchainDB process was profiled.

The profile was collected on an Ubuntu 17.10 VM with 4 GB of RAM and 2 vcpus.

Behind BigchainDB, there were only a single Tendermint and a single MongoDB processes.

A [script][post-tx-script] was used to constantly push transactions to the running node, like this:

```
python3 bulk_post_transactions.py --threads 100 --transactions-per-thread 10000 --mode commit
```

The profiles were built for the system spammed with transactions from 100 and 1000 threads in the async mode and 100 threads in the sync mode.

As a visualization format, we used Brendan Gregg's [Flame Graphs][flame-graph]. To collect the data into the Flame Graphs we made use of Uber's [Pyflame library][pyflame]. Flame Graphs display stack traces in a very intuitive way and allow to conveniently zoom them in and out. Pyflame collects profiles very efficiently, not affecting the performance of the target program.

[This script][profile-script] was used to attach to the running BigchainDB process while it was actively serving requests and collect stack traces into Flame Graphs.

To run the script, install `pyflame`, download `FlameGraph` into the parent folder, and run:

```
./profile_bigchaindb <bigchaindb pid>
```

##### Flame Graphs

Download the `svg` files and open them in the browser to enable zoom and hovering events.

###### 100 threads mode=async
![100 threads mode=async][flame-100-async]

###### 100 threads mode=sync
![100 threads mode=sync][flame-100-sync]

###### 1000 threads mode=async
![1000 threads mode=async][flame-1000-async]

In all three profiles the `check_tx` ABCI step takes up most of the execution time. It dominates in the asynchronous mode (89.19%) and shares some graph space with `deliver_tx` and `commit` under the load of "synchronous" requests.

All three graphs show similar relative proportions of the following types of work; the percentage is given for the async 100 threads case; the lower-bound estimate is collected:


| Action                                            | Time                                                            |
|---------------------------------------------------|-----------------------------------------------------------------|
| Crypto Conditions validation                      | 41.75% (7.90 % + 7.31% + 6.61% + 6.35% + 5.62% + 3.75% + 4.22)  |
| MongoDB queries                                   | 28.42% (13.51% + 12.67% + 2.24% = 28.42%)                       |
| Transaction schema validation                     | 1.40%                                                           |
| An extra deep copy of the transaction             | 2.24%                                                           |
| Mining cryptocurrencies                           | 0%                                                              |

According to the profiles, BigchainDB spends most of the time manipulating the Crypto Conditions objects (`cryptoconditions/fulfillment.py:serialize_uri`, `cryptoconditions/fulfillment.py:from_uri`, `cryptoconditions/fulfillment.py:condition_uri`).

MongoDB queries also contribute significantly to the picture but are out of the considered scope.

#### Benchmarking fulfillment serialisation

We compared Python and Golang implementations of fulfillment serialisation. Each implementation parsed an `Ed25519Sha256` Base64 encoded fulfillment URI and then serialised the result back into the original format 100 000 times in a row.

###### Python

Prerequisites: Python 3.6.5, BigchainDB 2.0.0a6 development libraries.

Run the [script][python-serialisation-benchmark]:

```
time python3 ./serialise_fulfillment_python_benchmark.py
```

We got:

```

real	0m22.658s
user	0m22.217s
sys	0m0.112s
```

###### Go

Prerequisites: Go 1.10.2, github.com/go-interledger/cryptoconditions (written by Steven Roose)

Build and run the [script][go-serialisation-benchmark]:

```
go build serialise_fulfillment_golang_benchmark.go
time ./serialise_fulfillment_golang_benchmark
```

And you should see:
```

real	0m0.578s
user	0m0.582s
sys	0m0.013s
```

Golang turned out to be around 40 times faster, what is a good sign for us.

#### Benchmarking schema validation

This is a bonus section - schema validation takes up only a relatively small portion of the execution time.

Each implementation fetched the common and CREATE transaction schemas into memory once and validated a transaction object against them 100 000 times.

###### Python

Prerequisites: Python 3.6.5, BigchainDB 2.0.0a6 development libraries.

Run the [script][python-schema-benchmark]:

```
time python3 ./validate_schema_python_benchmark.py
```

We got:

```

real	1m15.996s
user	1m14.083s
sys	0m0.582s
```

###### Go

Prerequisites: Go 1.10.2, github.com/xeipuuv/gojsonschema (implemented by the community)

Build and run the [script][go-schema-benchmark]:

```
go build validate_schema_golang_benchmark.go
time ./validate_schema_golang_benchmark
```

And you should see:
```

real	0m0.578s
user	0m0.582s
sys	0m0.013s
```

This is about 15 times faster than the Python equivalent.

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
[post-tx-script]: ./bulk_post_transactions.py
[flame-graph]: https://github.com/brendangregg/FlameGraph
[pyflame]: https://github.com/uber/pyflame
[profile-script]: ./profile_bigchaindb
[flame-100-sync]: ./profile_sync_100_threads.svg
[flame-100-async]: ./profile_async_100_threads.svg
[flame-1000-async]: ./profile_async_1000_threads.svg
[python-serialisation-benchmark]: ./serialise_fulfillment_python_benchmark.py
[go-serialisation-benchmark]: ./serialise_fulfillment_golang_benchmark.go
[python-schema-benchmark]: ./validate_schema_python_benchmark.py
[go-schema-benchmark]: ./validate_schema_golang_benchmark.go