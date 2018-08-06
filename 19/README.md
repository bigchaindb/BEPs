```
shortname: BEP-19
Name: Tendermint Performance Profiling
type: Informational
status: Raw
Editors: Zachary Bowen <zach@bigchaindb.com>
Contributors: 
```

# Tendermint Performance Profiling

## Abstract
This document contains the results of an in-depth benchmarking study of the Tendermint consensus layer. We use only Tendermint native tooling, and attempt to independently replicate their claim of [10500 txs/s][tm_benchmark_claim].

## Motivation
BigChainDB has quoted the Tendermint performance claim in our own documentation, and to date we have not independently verified this figure. As this represents a potential bottleneck for our own performance, and given that we have now released BigchainDB Beta, it is critical that we get a better understanding of the performance capabilities of Tendermint.

This investigation is further motivated as a natural out-growth of [BEP-10], which makes the assumption that tighter integration with Tendermint will result in performance improvements for BigchainDB. This assumption only holds if Tendermint is *not* the performance bottleneck for our system. Given the complexity of the consensus problem, it is reasonable to test this assumption before planning any engineering projects around it.

## Test System
All tests were run on hardware with the following specifications

* Processor: Intel(R) Xeon(R) CPU E5-2650 v3 @ 2.30GHz (10 cores)
* Memory: 15GB
* OS: Ubuntu 18.04 LTS
* Tendermint version: 0.20.0-27bd1dea

We ran tests against a single Tendermint instance, which is initialized in the setup of the test run. The [``config.toml``][config.toml] is modified at run time to set the ``mempool_size``, according to a test parameter. All other parameters were left with their default values.

## Tests
All tests were based on the [tm-bench] benchmarking tool. The tool specifies

* Duration of test
* Requests per second
* Number of connections

and returns

* Average txs and blocks per second
* Standard deviation
* Max txs and blocks per second.

In place of the BigchainDB layer, we used a simple kv-store as a proxy app. In these test configurations, we ran the kv-store integrated with Tendermint, however, comparison tests connecting the kv-store over a TCP pipeline can be seen [here.][comparison_tests]

### Executing Tests

To run the tests, please install [tm-bench] and your desired version of [Tendermint].

Next, download the [test scripts][scripts] and execute the following shell command:

``$ ./test_square_wave.sh > my_test_results.csv; tests.sh >> my_test_results.csv``

The first test script runs the tm-bench tool for a few seconds, then pauses, then repeats this cycle a number of times. This produces a series of request 'pulses', with breaks in between.

The second script puts Tendermint under a constant load of incoming requests, and changes the ``mempool_size`` in the ``config.toml``.

Our [data] is analyzed in the following sections.

#### Stress Tests
Our first set of tests looked at the effect of broadcasting requests at a constant rate over an increasing duration.

Looking at the data, we can see a sharp decline in Tendermint performance as the test duration increases. This is consistent with what we observed in our previous [study][comparison_tests] of Tendermint 0.19.5-747f28f8.

![High Tx Rate][high_tx_rate]

![Low Tx Rate][low_tx_rate]

#### Mempool Size Tests
One hypothesis for the performance degradation was that the mempool was filling up, and some process was taking longer and longer as it filled. To test this, we varied the size of the mempool and repeated tests, while holding other parameters constant.

![mempool_size=10]

![mempool_size=1000]

What we observe is that reducing the mempool size below 100,000 decreases performance when compared with our stress tests conducted at ``mempool_size=100,000``.

![mempool_size=100000+]

However, increasing it to 1,000,000 showed now significant performance improvement. From this result, we conclude that a ``mempool_size`` of 100,000 is optimal for our system.

While mempool size can indeed contribute to performance problems, the gradual performance decline cannot be a result of the mempool 'filling up'. Were this the case, we should see an almost immediate steady state with small mempool size. However, even with the mempool size set to 10 and 1000 requests per second, we still see a drop in performance as the test duration increases.

Also note that the shape of the data could be attributed to an initial burst of confirmed transactions, followed by a stall. That is, if the number of transactions written was constant after about 50s, and we average that number over longer and longer time periods, this would also produce a performance curve proportional to 1/t.

We ruled this possibility out by manually monitoring the blocks written for several minutes while the test script ran. We continued to see blocks with new transactions being written well past the 10th minute of test execution, albeit only one every few seconds. The reader can repeat this test by repeatedly pinging ``$ curl localhost:46657/block | grep height`` while a test script runs and watching the block height increment.

We additionally verified that the increment in block height was linked to actual transactions being written in two ways. First, we repeated selected tests with `create_empty_blocks=false` in the `config.toml`. Second, by omitting the `grep height` while monitoring the block height, we could see transactions included in the newly mined blocks.

#### Intermittent Load Tests
Next, we tested the effect of pausing the test and restarting it. In essence, rather than broadcasting at a constant rate, we set a square wave, with a constant broadcast, followed by a pause. Our assumption was that if Tendermint was experiencing a backlog somewhere, the pause should give the system a chance to clear itself out, restoring the performance once the broadcast restarted.

Of greatest interest, we can see that in a series of tests where we separate broadcasts with a pause of varying duration, the transaction rate is stabilized. For example, examine lines 126 to 194 of the [data]. In this series of tests, we send 10 request batches. Each batch lasts 100 seconds, and has a request rate of 1,000 requests per second. We vary the pauses between request batch from 1 to 20 seconds in successive tests, and in all cases, our transaction rate stabilizes between 900 and 1,000 transactions per second. Compare this to sending 1,000 requests per second for 1,000 seconds straight, as we did on line 13 of the [data]. Without pauses, our average transaction rate fell to 210 transactions per second.

Note that there is a sweet spot here. When we reduce our broadcast time too much, we start to lose performance, (see lines 254 - 294 in the [data]). This is due to the fact that there is a lag when we initialize the connection to Tendermint. There is a cost to breaking and re-establishing this connection that needs to be balanced against the increase in transaction rate.

Also, it is worth mentioning that it may not be necessary to fully break the connection with Tendermint. Recall that the tests were run using an integrated kv-store written in GoLang. In the context of these tests, 'breaking the connection' and 'pausing transmission' look the same. It is possible that in the context of BigChainDB, we can simply pause transmission of new requests for a second, without actually breaking the TCP connection. However, testing this would require re-engineering parts of the tm-bench tool, and in the interest of getting results out rapidly, I will simply present the 'worst case' analysis, as if we really need to break the TCP connection.

## Recommendations

We recommend implementation of a sentinel server to field incoming requests to Tendermint. This will offer several benefits.

First, we can use the sentinel to protect against DoS attacks, by limiting the number of requests from any given IP address to a reasonable number.

                                            _____________________                                ____________
    User_1, 100,000 requests/s------------>| Sentinel            |   User_1, 995 requests/s     |            |
    User_2, 1,000 requests/s-------------->| max_req=2,000/s     |---User_2, 995 requests/s---> | Tendermint |
    User_3, 10 requests/s----------------->| pause_interval=100s |   User_3, 10 requests/s      |____________|
                                           |_____________________|   Break every 100s

Second, we can use the sentinel to break/pause the connection with Tendermint as a mitigation for the perfomance degradation.

This could be implemented in two ways. First, we could simply experiment to find the optimal frequency with which we hang up and call back to Tendermint. This has the advantage of being easy to engineer. However, we could also implement active monitoring from the sentinel layer, where we measure the transaction rate and hang up if it falls below a certain threshold. This offers the advantage of being a more general solution that will respond to changes in performance as different version of Tendermint are rolled out, or when the system is run on different hardware, for example.

In any case, the sentinel server should function as a buffer between the request author and the Tendermint layer. Incoming requests should be stored in memory and fed to Tendermint at a manageable rate. Any pauses needed to maintain throughput on the Tendermint end should be invisible to the user, as the memory buffer stays available at all times.

[tm_benchmark_claim]: https://github.com/tendermint/tendermint/wiki/Benchmarks
[Tendermint]: http://tendermint.readthedocs.io/projects/tools/en/master/install.html
[BEP-10]: https://github.com/bigchaindb/BEPs/blob/master/10/README.md
[tm-bench]: https://github.com/tendermint/tools/tree/master/tm-bench
[comparison_tests]: https://github.com/bigchaindb/BEPs/blob/master/10/benchmark_tcp_pipeline.md
[high_tx_rate]: ./figures/high_tx_rate.png
[low_tx_rate]: ./figures/low_tx_rate.png
[mempool_size=10]: ./figures/mempool_size=10.png
[mempool_size=1000]: ./figures/mempool_size=1000.png
[mempool_size=100000+]: ./figures/mempool_size=100000+.png
[scripts]: ./scripts
[data]: ./data/tendermint_mempool_tests_16_6_2018.csv
[config.toml]: ./data/config.toml