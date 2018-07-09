# Profiling and benchmarking BigchainDB

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

[post-tx-script]: ./scripts/bulk_post_transactions.py
[flame-graph]: https://github.com/brendangregg/FlameGraph
[pyflame]: https://github.com/uber/pyflame
[profile-script]: ./scripts/profile_bigchaindb
[flame-100-sync]: ./figures/profile_sync_100_threads.svg
[flame-100-async]: ./figures/profile_async_100_threads.svg
[flame-1000-async]: ./figures/profile_async_1000_threads.svg
[python-serialisation-benchmark]: ./scripts/serialise_fulfillment_python_benchmark.py
[go-serialisation-benchmark]: ./scripts/serialise_fulfillment_golang_benchmark.go
[python-schema-benchmark]: ./scripts/validate_schema_python_benchmark.py
[go-schema-benchmark]: ./scripts/validate_schema_golang_benchmark.go