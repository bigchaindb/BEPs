```
shortname: 14/GIDR
name: Guidelines to Improve Drivers Reliability
type: standard
status: raw
editor: Alberto Granzotto <alberto@bigchaindb.com>
contributors: Lev Berman <ldmberman@gmail.com>
```

# Guidelines to Improve Drivers Reliability

## Abstract
This BEP gives guidelines on how to improve the reliability of the current (and future) BigchainDB drivers by allowing them to talk to multiple nodes in a network.

## Motivation
A BigchainDB driver allows developers to integrate their applications with a BigchainDB network. At the time of writing, the drivers developed for BigchainDB connect to only one specific BigchainDB node in a network. If that specific BigchainDB node is unreachable, requests made by the driver will fail until the node is reachable again, even if there are other nodes in the network available.

Assumptions on BigchainDB availability and correctness are bound to the concept of **network of nodes**. If a driver connects to only one node, the reliability of BigchainDB perceived by the end user is harmed.

This BEP aims to improve the reliability of the drivers, and does **not** address how drivers should implement a [light client protocol][tm:light-client]. In other words, all the nodes the driver communicates to have to be trusted.

## Specification
First, let's take a look on how the current implementation works. In order to have a usable instance of a driver, the developer needs to specify the URL of the BigchainDB node to connect to.

The current [Python implementation][bdb:python-driver] looks like:
```python
driver = BigchainDB('https://test.bigchaindb.com')
```

The current [JavaScript implementation][bdb:javascript-driver] is similar:
```javascript
const conn = new driver.Connection('https://test.bigchaindb.com/api/v1/')
```

As mentioned before, if `test.bigchaindb.com` is down, no request can be fulfilled by the driver. From an end-user perspective the **whole bigchaindb test network is down**, even if it's just a node that is unreachable. That's a shame since there are (hopefully) other three healthy nodes to use.

### Initialize the driver with a list of endpoints
The driver should support initialization with a list of endpoints. Each endpoint is the URL of a BigchainDB node API. The list of endpoints doesn't need to contain **all** endpoints. Note that the list of endpoints should be known beforehand by the developer when using the driver: there is no automatic propagation of the peers from a BigchainDB node to the driver. Remember: a node can cheat, and the driver needs a way to check the validity of the list of peers. We keep things simple for this BEP, so you'll need to either trust the nodes you fill in or implement the proper transaction verification **on top** of the driver.

In addition to the current way to initialize the driver, this BEP allows initialization with list of URLs.

For the Python driver, the new implementation should look like this:
```python
driver = BigchainDB([
    'https://test.bigchaindb.com',
    'https://test2.bigchaindb.com',
    'https://test3.bigchaindb.com',
    'https://test4.bigchaindb.com'])
```

The JavaScript driver follows:
```javascript
const conn = new driver.Connection([
    'https://test.bigchaindb.com/api/v1/',
    'https://test2.bigchaindb.com/api/v1/',
    'https://test3.bigchaindb.com/api/v1/',
    'https://test4.bigchaindb.com/api/v1/'])
```

#### Working with custom headers
Drivers should support the injection of custom headers when doing requests. This allows authentication of the driver, and eventually other kind of custom behaviors. Those headers can be global for all endpoints or not.

##### Global headers for all endpoints
The BigchainDB test network is a good example for this use case: to post transaction, an `<app_id, app_key>` pair must be provided to authenticate the client. This pair is used across all nodes in the network.

For the Python driver, the new implementation should look like this:
```python
driver = BigchainDB([
    'https://test.bigchaindb.com',
    'https://test2.bigchaindb.com',
    'https://test3.bigchaindb.com',
    'https://test4.bigchaindb.com'],
    headers={'app_id': 'your_app_id',
             'app_key': 'your_app_key'})
```

The JavaScript driver is basically the same:
```javascript
const conn = new driver.Connection([
    'https://test.bigchaindb.com/api/v1/',
    'https://test2.bigchaindb.com/api/v1/',
    'https://test3.bigchaindb.com/api/v1/',
    'https://test4.bigchaindb.com/api/v1/'],
    {app_id: 'your_app_id', app_key: 'your_app_key'})
```

In this configuration, headers MUST be used for every request to any BigchainDB node the driver is doing.

##### Custom headers per endpoint
Different BigchainDB nodes can accept different headers. In this case, the developer should be able to specify which headers should be used with which node.

For the Python driver, the new implementation should look like this:
```python
driver = BigchainDB([
    'https://test.bigchaindb.com',  # the first node does not use custom headers, only common headers
    {'endpoint': 'https://test2.bigchaindb.com',
     'headers': {'app_id': 'your_app_id',
                 'app_key': 'your_app_key',
                 'Content-Type': 'application/xml',  # this node overrides the common header
		 'extra_header': 'extra value'}},
    {'endpoint': 'https://test3.bigchaindb.com',
     'headers': {'app_id': 'your_app_id',
                 'app_key': 'your_app_key',
		 'other_header': 'other value'}},
    {'endpoint': 'https://test4.bigchaindb.com',
     'headers': {'custom_auth': 'custom token'}],
    headers={'Content-Type': 'application/json'},  # this header is used by all nodes
)
```

The JavaScript driver is basically the same:
```javascript
const conn = new driver.Connection([
    {endpoint: 'https://test.bigchaindb.com/api/v1/',
     headers: {app_id: 'your_app_id',
               app_key: 'your_app_key'}},
    {endpoint: 'https://test2.bigchaindb.com/api/v1/',
     headers: {app_id: 'your_app_id',
               app_key: 'your_app_key',
               extra_header: 'extra value'}},
    {endpoint: 'https://test3.bigchaindb.com/api/v1/',
     headers: {app_id: 'your_app_id',
               app_key: 'your_app_key',
       	       other_header: 'other value'}},
    {endpoint: 'https://test4.bigchaindb.com/api/v1/',
     headers: {custom_auth: 'custom token'}])
```


### Connection strategy
Now that the driver has a list of endpoints, it needs some kind of logic to know how to use them. This is the role of the connection strategy. Different use-cases might require different connection strategies, but only a single connection strategy can be used at the time. A connection strategy should be a pluggable component of the driver.

For this BEP, we analyze a round-robin connection strategy, similar to [Round-robin scheduling][wiki:rr]. More strategies are welcome, and should be submitted in the form of one or more BEPs.

#### Round-robin strategy
In this scenario, every request is forwarded to a different node, distributing the load to all the nodes, and allowing recovering from connection errors by forwarding the failed request to another healthy node.

This strategy needs to keep track of the following values:

- `E`, the list of BigchainDB endpoints passed at initialization time.
- `i`, the index of the BigchainDB node to use for a request (`0 ≤ i < len(E)`).
- `timeout`, user-specified timeout, defaults to 20 seconds. Users may choose to have no timeout.
- `T`, a list of timestamps, expressed as the number of seconds elapsed since Unix Epoch. It has the same length as `E`. On initialization, all elements contain the minimal possible timestamp `0`. It is used to track the availability of the nodes.
- `DELAY`, in case a node is unreachable, how much seonds we must pass before the request can be repeated. This is used in combination with `T`.
- `retry_count`, how many times the node was retried unsuccessfully.

We also need to know the current time of the system, for this we use the variable `current_time_ms`.

When a driver needs to forward a request to the network, the following algorithm (or equivalent) SHALL be implemented:

1. pick the node `i` with the minimal `T[i]`, that is the earliest available node
1. wait until `current_time_ms > T[i]` or timeout is expired
1. if timeout is expired, return
1. if timeout is not expired, make the request
1. if timeout is expired while the request is in progress, return
1. in case of a successful response, set `retry_count` to 0, set `T` to `0`, return
1. in case of a connection error (e.g. DNS failure, connection refused), set `T` to `DELAY * 2 ** retry_count`, increment `retry_count`, repeat from step 1.
1. in case of other error, return

The algorithm achieves the following traits:

- Available nodes are exploited as much as possible, what optimizes the request time.
- Exponential backoff is there for all the nodes no matter how many nodes are there and how many requests were made, what prevents the network from being overloaded.
- Users can wait for a reply from an available node for as long as they wish, expressing it via `timeout`.

## Rationale
There are many optimizations that can be done, for example the round-robin strategy can be improved by prioritizing nodes with low latency, or `DELAY` can be capped to a max value, or `jitter` may be introduced.

There are a lot of interesting things to work with, for example adding a [AIMD][wiki:AIMD] algorithm to evaluate how much the BigchainDB network is congested, and adapt the request-rate.

Another great feature would be to have a list of endpoints from a single BigchainDB node. But this requires the driver to check the validity of the data coming from a node.

This design has been chosen for it's simplicity and backward compatibility. This design can be easily implemented in our drivers. Moreover, this design is the shortest path to a more reliable BigchainDB network.

## Backwards Compatibility
As long as the driver handles both single and multiple endpoints on its initialization, this change is fully backwards compatible.

## Implementation
The implementation is TBD.

## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

[tm:light-client]: https://blog.cosmos.network/light-clients-in-tendermint-consensus-1237cfbda104
[bdb:javascript-driver]: https://github.com/bigchaindb/js-bigchaindb-driver/
[bdb:python-driver]: https://github.com/bigchaindb/bigchaindb-driver/
[wiki:rr]: https://en.wikipedia.org/wiki/Round-robin_scheduling
[wiki:AIMD]: https://en.wikipedia.org/wiki/Additive_increase/multiplicative_decrease
