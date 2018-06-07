# Benchmarking the TCP Connection between BDB and Tendermint

#### Running the TCP Benchmark Tests

In order to execute a TCP benchmark test, first install [tm-bench][tm-bench].

We used a couple of handy bash scripts to [specify test parameters][tests] and [execute tests][runtests] to output test results in a nice format for a csv. You can download and try them yourself.

We took [data] on hardware with the following specifications

* Processor: Intel(R) Xeon(R) CPU E5-2650 v3 @ 2.30GHz (10 cores)
* Memory: 15GB
* OS: Ubuntu 18.04 LTS

For the following graphs, we use the coloring scheme:
* Blue
  * KV-store integrated with Tendermint (no TCP pipeline)
  * Logging enabled 
* Red
  * KV-store integrated with Tendermint (no TCP pipeline)
  * Logging disabled
* Yellow
  * KV-store remote from Tendermint (yes TCP pipeline)
  * Logging enabled
* Green
  * KV-store remote from Tendermint (yes TCP pipeline)
  * Logging disabled

Examining the data collected, we can see a few patterns.

###### Transactions per Second / Duration
![tx/s vs duration][duration]

FIrst, notice that there is a severe degradation in performance under a sustained heavy load. The integrated processes (no TCP connection) initially slightly out perform the external processes, but eventually, they all reach a steady state of 210 tx/s.

###### Transactions per Second / Requests
![tx/s vs requests][requests]

Next, note that for a fixed duration, the performance is unresponsive to the transaction rate.

###### Transactions per Second / Connections
![tx/s vs connections][connections]

Similarly, we see no significant impact when we increase the number of connections.

#### Conclusions

Broadly, we can see that except in the case of the long term performance degradation, the TCP connection causes a performance degradation of about 14%. This is consistent across all parameter configurations, with the red and blue trend lines consistently above the green and yellow lines.

It is worth noting that the transaction rate seems to *increase* when logging is enabled. This seems counter intuitive, and at the moment, I don't have a good explanation of why this should be the case. However, it is also consistent across all data sets, so it is likely not an artifact.

#### Further investigation

We are currently running a more detailed investigation of the performance degradation at low and high transaction rates, sustained for different durations. The results will be incorporated into this document when they become available.

[tm-bench]: https://github.com/tendermint/tools/tree/master/tm-bench
[tests]: ./tcp_benchmark_parameters.sh
[runtests]: ./run_tcp_benchmark.sh
[data]: ./tendermint_connection_tests.ods
[connections]: ./connections_vs_tx_rate.png
[requests]: ./requests_vs_tx_rate.png
[duration]: ./duration_vs_tx_rate.png