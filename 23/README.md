```
shortname: BEP-23
name: Performance Study: Analysis of Transaction Throughput in a BigchainDB Network
type: Informational
status: Raw
editor: Alberto Granzotto <alberto@bigchaindb.com>
contributors: Troy McConaghy <troy@bigchaindb.com>, Muawia Khan <muawia@bigchaindb.com>
```

# Performance Study: Analysis of Transaction Throughput in a BigchainDB Network

## Abstract
Transaction throughput is a key metric to evaluate the suitability of a blockchain system for real world applications. BigchainDB is now in its beta phase, and we don't expect major changes in the parts of the code that are responsible for the throughput of the system (i.e. the validation logic), for this reason we can now run performance tests and publish our results. The tested setup consists of a 4 node network running a [recent version of BigchainDB][bdb:git-commit]. Each node runs on a different virtual machine, hosted in the [Azure infrastructure][azure:landing-page]. A fifth virtual machine is used to generate the workload and collect metrics. Depending on the configuration of the system, the tested BigchainDB network, under constant load, finalizes between 300 and 1000 transactions per second.

## Introduction
Blockchain systems are currently under heavy research and development. Different projects have different definitions of what a blockchain is—or should be.
Given that there is no standard definition of *blockchain* (as there is, for example, for relational database management systems), no formal definitions of metrics exist, and no formal *benchmarking software suite* can be applied across different blockchain systems. Still, we can find concepts that are valid across multiple systems; a transaction, for example, goes through different states during its lifetime such as:

- **Accepted** by the network. In order to be accepted, a transaction must be "valid," where the definition of valid varies from network to network.
- **Committed** in the blockchain. If a transaction makes it into a block, it is stored together with other transactions in the local database of the node.
- **Finalized**. Finality means that once a transaction is committed, it cannot be reversed, i.e. the data cannot be rolled back to the previous state. Different blockchain systems may provide different types of finality. Typically, this is defined in the consensus protocol. Different types of consensus exist, such as voting-based consensus with immediate finality and lottery-based consensus with probabilistic finality. (Definition from the [Hyperledger Performance and Scale Working Group][hl:finality].) For BigchainDB, once a transaction is committed it is also finalized.

Note that BigchainDB inherits Tendermint **instant finality**. This means that as soon as a new block is committed, it cannot be reversed. Through this document, we won't make any distinction between a *committed* transaction and a *finalized* transaction. For clarity, we will always prefer the term *finalized*.

Given that, the metrics we measured in our experiments are:

- Transaction acceptance rate.
- Transaction finalization rate.
- Time to accept a transaction (how much time it takes for a valid transaction to be stored in the mempool).
- Time to finalize a transaction (how much time it takes for a valid transaction to be stored in the blockchain).

Those metrics reflect the different states of a valid transaction: accepted and finalized.

Even if the reference metric is how many transactions the network finalizes per second, during this analysis we dig deeper and analyze the distribution on accepted transactions, committed etc. We want to make sure that the system is responsive most of the time, and we don't want to get fooled by an average that hides a lot of data behind it. Knowing the actual distribution of how much time it takes for a transaction to be accepted and then committed allows us to have a clear understanding of the responsiveness of the system, and this is something we won't know if we look only at the average. For this reason we developed our own tool, `bigchaindb-benchmark`.
[BigchainDB Benchmark][bdb:benchmark-tool] is the tool we developed to generate the workload and collect statistics. It can simulate a large amount of workload by spawning multiple processes, and output a CSV file to timestamp the different steps in the life cycle of a transaction. This allows us to measure the distribution of how long it takes for a transaction to be accepted and later finalized.
We also run other tests using a customized version of [`tm-bench`][tm:tm-bench].

Another thing to consider is that BigchainDB is a multi-asset blockchain. With BigchainDB, users can create their own custom assets. Each new asset is identified by a unique value, that is the `id` of the `CREATE` transaction that minted it. Assets have their own unique history or—in more precise terms—directed acyclic graph. In order to check if a transaction is a double spend, we can safely ignore all transactions related to other assets. This means that when BigchainDB has to validate a block, it can parallelize validation, exploiting all cores in the current machine (more details to come). To understand if we could get a performance boost out of this, we integrated a new experimental feature that enables parallel validation of transactions. This feature is a proof of concept to show that higher throughput is realizable. Note: this feature skips also *Check Tx*, used by Tendermint to check a transaction before storing it in the mempool. BigchainDB validates transactions as soon as they are posted to the HTTP API, so *Check Tx* in this case is redundant. We must mention that *Check Tx* is used also to validate transactions coming from the other nodes of the network, so disabling it might allow byzantine actors to push invalid transactions to the mempool (handling invalid transactions is [actively discussed in the Tendermint issue tracker][tm:invalid-txs]). Even if an invalid transaction makes it to the mempool, it will be always discarded during the *Deliver Tx* phase, so this experimental feature will still maintain a correct state of the application. Parallel validation is an optimistic approach that will be eventually developed for specific production use cases.

## Methods
<!--
METHODS. The methods section will help you determine exactly how the authors performed the experiment.

The methods describes both specific techniques and the overall experimental strategy used by the scientists. Generally, the methods section does not need to be read in detail. Refer to this section if you have a specific question about the experimental design.
-->

The performance tests were run on the Microsoft Azure cloud infrastructure. For the BigchainDB nodes, we choose compute optimized virtual machines from the [Fsv2 series][azure:fsv2], specifically *Standard F32s v2* (32 vCPUs, 64GiB memory, SSD drives with estimated IOPS limit of 5000). For the machine generating the workload, we used a *Standard F8s v2* (8 vCPUs, 16GiB memory). The virtual machines were all in the same datacenter.

Note that the IOPS limit is crucial. A low number will create a bottleneck in disk reads and writes, slowing down database operations. To have a rough idea on the actual IO speed of the disk, `hdparam` was used.

```
benchmark1@benchmark1:~$ sudo hdparm -Tt /dev/sda

/dev/sda:
 Timing cached reads:   19514 MB in  1.99 seconds = 9785.28 MB/sec
 Timing buffered disk reads: 1484 MB in  3.00 seconds = 494.39 MB/sec
```

All machines were provided with the operating system *Ubuntu 18.04.1 LTS (Bionic Beaver)*. For simplicity we provided all machines (both the machine generating the workload and the machines running the BigchainDB nodes) with the same software:

- BigchainDB, [commit 6a9064196ad49baf3933051be6e116a3440fbad2][bdb:git-commit]
- Tendermint 0.22.8
- MongoDB v3.6.3

This procedure was automated by a [custom script][self:provide.sh].

Three main configuration files were generated and edited (all of them are included as extra files in this BEP):
- The Tendermint [`config.toml`](self:config.toml) configuration file (default location: `${HOME}/.tendermint/config/config.toml`) was generated via `tendermint init` and customized.
- The Tendermint [`genesis.json`][self:genesis.json] file (generated though the previous command `tendermint init`) was customized with the public keys of the four nodes. It was then copied into all machines under `${HOME}/.tendermint/config/genesis.json`.
- The BigchainDB [`.bigchaindb`][self:bigchaindb.json] was generated via `bigchaindb configure` and copied into all machines under `${HOME}/.bigchaindb`.

We also had a **setup** and **teardown** procedure we run before and after every test.

The **setup** procedure was responsible to start the BigchainDB and the Tendermint process.
```bash
#!/bin/bash

nohup bigchaindb start > ${HOME}/bigchaindb.log 2>&1 &
nohup tendermint node > ${HOME}/tendermint.log 2>&1 &
```

The **teardown** procedure was responsible to stop the BigchainDB and the Tendermint process, and to reset the state on MongoDB and on the Tendermint LevelDB.
```bash
#!/bin/bash

pkill tendermint
pkill bigchaindb
bigchaindb -y drop
tendermint unsafe_reset_all
```

### Experiments
Three experiments were performed.

The first one was run using BigchainDB without any special option.

The second one used the experimental feature for parallel validation, enabled on start with `bigchaindb start --experimental-parallel-validation`.

The third one used the experimental feature for parallel validation, enabled on start with `bigchaindb start --experimental-parallel-validation`, and was run with a smaller amount of requests to test the peak performance of the system.

### Experiment 1: finalize 1,000,000 transactions
For each node in the network, we started all services using the startup script. After some seconds, we switched to the workload-generating virtual machine, and ran:

```
bigchaindb-benchmark\
    --csv results/master-32proc-1000000sync.csv\
    --processes=32\
    --peer http://10.240.0.4:9984\
    --peer http://10.240.0.5:9984\
    --peer http://10.240.0.6:9984\
    --peer http://10.240.0.7:9984\
    send -r1000000 --mode=sync
```

This command uses 32 workers to push 1,000,000 transaction of 765 bytes to the four nodes in the network. The generated `CSV` file with the results was then copied to another machine

### Experiment 2: finalize 1,000,000 transactions (experimental parallelization)
For each node in the network, we started BigchainDB with `bigchaindb start --experimental-parallel-validation`. After some seconds, we switched to the workload generating virtual machine, and ran:

```
bigchaindb-benchmark\
    --csv results/exp-32proc-1000000sync.csv\
    --processes=32\
    --peer http://10.240.0.4:9984\
    --peer http://10.240.0.5:9984\
    --peer http://10.240.0.6:9984\
    --peer http://10.240.0.7:9984\
    send -r1000000 --mode=sync
```

This command uses 32 workers to push 1,000,000 transaction of 765 bytes to the four nodes in the network. The generated `CSV` file with the results was then copied to another machine

### Experiment 3: finalize 16,000 transactions (experimental parallelization)
For each node in the network, we started BigchainDB with `bigchaindb start --experimental-parallel-validation` and we changed the flag `skip_timeout_commit` to `true` in `${HOME}/.tendermint/config/config.toml` (we noticed a significant delay to create the last block of the test, and skipping the timeout commit seems to help in this regard). After some seconds, we switched to the workload generating virtual machine, and ran:

```
bigchaindb-benchmark\
    --csv results/exp-32proc-1000000async.csv\
    --processes=32\
    --peer http://10.240.0.4:9984\
    --peer http://10.240.0.5:9984\
    --peer http://10.240.0.6:9984\
    --peer http://10.240.0.7:9984\
    send -r16000 --mode=sync
```
This command uses 32 workers to push 16,000 transaction of 765 bytes to the four nodes in the network. The generated `CSV` file with the results was then copied to another machine

## Results
Each experiment generated a CSV file containing the following columns:
- `txid`: the ID of the transaction being sent to the server
- `size`: the size in bytes of the transaction
- `ts_send`: timestamp when the transaction was sent.
- `ts_accept`: timestamp when the transaction was accepted.
- `ts_commit`: timestamp when the transaction was committed and finalized.
- `ts_error`: timestamp of an error if it occurred.

We built a script called [`analysis.py`][bdb:analysis.py] to process those CSV files and output four different graphs per experiment:
- Distribution of how much time it takes to **accept** a transaction.
- Distribution of how much time it takes to **finalize** a transaction.
- **Accepted** transactions per second.
- **Finalized** transactions per second.


### Experiment 1: finalize 1,000,000 transactions (master)
![Experiment 1][self:plot-experiment-1]

Together with the plots, this output was captured:

```
0.680    0.112
0.950    0.294
0.997    0.730
Name: d_accept, dtype: float64
0.680    2.855
0.950    5.143
0.997    9.392
Name: d_commit, dtype: float64
```

BigchainDB was able to process 1,000,000 transactions in 56 minutes without any failure.

In terms of responsiveness, the system performed consistently during the whole test:
- 99.7% of transactions have been **accepted** within 0.730 seconds, 95% within 0.294 seconds, and 68% within 0.112 seconds.
- 99.7% of transactions have been **finalized** within 9.392 seconds, 95% within 5.143 seconds, and 68% within 2.855 seconds.

In terms of speed (transactions per second), the system:
- **Accepted** an average of _299 transactions per second_, with a median value of _309 transactions per second_.
- **Finalized** an average of _298 transactions per second_, with a median value of _320 transactions per second_.



### Experiment 2: finalize 1,000,000 transactions (experimental parallelization)
![Experiment 2][self:plot-experiment-2]

Together with the plots, this output was captured:

```
0.680    0.018
0.950    0.113
0.997    2.033
Name: d_accept, dtype: float64
0.680    2.898000
0.950    5.402000
0.997    7.686003
Name: d_commit, dtype: float64
```
BigchainDB was able to process 1,000,000 transactions in 26 minutes without any failure.

In terms of responsiveness, the system performed consistently during the whole test:
- 99.7% of transactions have been **accepted** within 2.033 seconds, 95% within 0.113 seconds, and 68% within 0.018 seconds.
- 99.7% of transactions have been **finalized** within 7.686 seconds, 95% within 5.402 seconds, and 68% within 2.898 seconds.

In terms of speed (transactions per second), the system:
- **Accepted** an average of _636 transactions per second_, with a median value of _615 transactions per second_.
- **Finalized** an average of _636 transactions per second_, with a median value of _636 transactions per second_.



### Experiment 3: finalize 16,000 transactions (experimental parallelization)
![Experiment 3][self:plot-experiment-3]

Together with the plots, this output was captured:

```
0.680    0.014
0.950    0.074
0.997    0.373
Name: d_accept, dtype: float64
0.680    3.081000
0.950    4.099000
0.997    4.358003
Name: d_commit, dtype: float64
```

BigchainDB was able to process 16,000 transactions in 18 seconds without any failure.

In terms of responsiveness, the system performed consistently during the whole test:
- 99.7% of transactions have been **accepted** within 0.373 seconds, 95% within 0.074 seconds, and 68% within 0.014 seconds.
- 99.7% of transactions have been **finalized** within 4.358 seconds, 95% within 4.099 seconds, and 68% within 3.081 seconds.

In terms of speed (transactions per second), the system:
- **Accepted** an average of _1092 transactions per second_, with a median value of _1072 transactions per second_.
- **Finalized** an average of _889 transactions per second_, with a median value of _1102 transactions per second_.


## Discussion
<!--DISCUSSION. The discussion section will explain the authors interpret their data and how they connect it to other work.

Authors often use the discussion to describe what their work suggests and how it relates to other studies. In this section, authors can anticipate and address any possible objections to their work. The discussion section is also a place where authors can suggest areas of improvement for future research.-->


The aims of the study are twofold, on one side we want to have an understanding on how a BigchainDB network performs under stress; on the other side we want to define a methodology we can use for a) future versions of BigchainDB, b) running other tests under different conditions.

About the performance of the system, we can conclude that BigchainDB performs consistently and correctly under constant stress, and it's able to finalize one million transactions within one hour and always be responsive. Enabling parallel validation allows BigchainDB to finalize the same number of transactions less than half an hour.

We also ran a short test to measure the peak performance of the system: under favorable conditions we are able to reach ~1000 finalized transactions per second. We are confident that we can improve the system and reach this performance under constant, heavy load.

## Copyright Waiver
<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law, all contributors to this BEP
  have waived all copyright and related or neighboring rights to this BEP.
</p>

[bdb:git-commit]: https://github.com/bigchaindb/bigchaindb/commit/6a9064196ad49baf3933051be6e116a3440fbad2
[azure:landing-page]: https://azure.microsoft.com/
[bdb:benchmark-tool]: https://github.com/bigchaindb/benchmark/tree/32f525a7979b7bd6a701294386af61c7e471472f
[bdb:analysis.py]: https://github.com/bigchaindb/benchmark/blob/32f525a7979b7bd6a701294386af61c7e471472f/playground/analysis.py
[azure:fsv2]: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-compute#fsv2-series-sup1sup
[tm:tm-bench]: https://github.com/tendermint/tendermint/tree/059a03a66a0d950b5e4c8956145ce708d239a182/tools/tm-bench
[tm:invalid-txs]: https://github.com/tendermint/tendermint/issues/2175
[hl:finality]: https://docs.google.com/document/d/1DQ6PqoeIH0pCNJSEYiw7JVbExDvWh_ZRVhWkuioG4k0/edit#heading=h.c4hbns18iu37
[self:provide.sh]: ./provide.sh
[self:config.toml]: ./config.toml
[self:genesis.json]: ./genesis.json
[self:bigchaindb.json]: ./bigchaindb.json
[self:plot-experiment-1]: ./master-32proc-1000000sync.svg
[self:plot-experiment-2]: ./exp-32proc-1000000sync.svg
[self:plot-experiment-3]: ./exp-32proc-16000sync.svg
