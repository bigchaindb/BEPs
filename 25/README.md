```
shortname: BEP-25
name: MongoDB query and aggregation
type: Standard
status: Raw
editor: David Dashyan <mail@davie.li>
contributors: Madjid Aoudia <maoudia@viascience.com>
```

# MongoDB query and aggregation

## Abstract
This document contains information on proposed new endpoint

## Motivation
As written by Madjid in #96 :
> Currently, the asset search endpoint is a basic text search feature which
> imposes a large computational time to be able to retrieve assets with complex
> search criteria.  Similarly, asset aggregations have to go through a text
> search and perform the actual computation on the client side.

## Rationale
Motivation is clear and the implemented feature often requested. Although
provided implementation is straightforward it raises concerns.

- Giving the client ability to perform arbitrary queries on MongoDB might cause
  serious security issues. This possibility must be investigated further.

- Despite the fact that MongoDB is the only supported database backend at the
  moment it is best avoid assumption that it will always be one when it comes to
  public API.

But current implementation does not raises security concerns in usecases when
BigchainDB endpoints are not open for public. And It will be much more difficult
to create a proper query and aggregation abstraction that will be compatible
with different database backends. Taking these points into consideration the
best solution could be to move this functionality into some form of "contrib"
section and make it available only when BigchainDB administrator explicitly
states so in configuration.

## Implementation
New query and aggregation implemented in
[#2693](https://github.com/bigchaindb/bigchaindb/pull/2693):

As written by Madjid in #96 :
> - A MongoDB JSON query endpoint which allows a client to perform an arbitrary
>   search on assets. Benefiting from the power of MongoDB search and indexes.
> - An aggregation query which allows a client to perform aggregations on
>   MongoDB and push the computation to the server.

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
