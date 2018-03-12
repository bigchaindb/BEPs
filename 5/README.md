```
shortname: 4/STANDARIDIZE-DC
name: Standard process to set up a local node for development & testing, using Docker Compose
type: standard
status: raw
editor: Muawia Khan <muawia@bigchaindb.com>
```


## Abstract
In the current BigchainDB repository we have 8 docker-compose files, each serving a specific function:

- docker-compose.yml
  - DEPRECATED: Used for deployment of single node development BigchainDB v1.3.
- docker-compose.travis.yml
  - Used to setup the continous integration environment on Travis.
- docker-compose.tendermint.yml
  - Used to deploy Single node development environment for BigchainDB(integrated with Tendermint).
- docker-compose.network.yml
  - Used to deploy 4 node development environment for BigchainDB(integrated with Tendermint)
- docker-compose.docs.yml
  - Used to build and host BigchainDB docs.
- docker-compose.ssl.yml
  - DEPRECATED: Used for deployment of single node BigchainDB v1.3, SSL enabled for MongoDB authentication and authorization.
- docker-compose.rdb.yml
  - DEPRECATED: Used to deploy single node BigchainDB v1.3 with RethinkDB as the backend database.
- docker-compose.benchmark.yml
  - DEPRECATED: Used to deploy standalone BigchainDB v1.3 development environment.


Majority of the above mentioned files are either not in use OR can be integrated in a way that all of them are being tested effectively with CI pipeline(s).

We also have multiple Dockerfiles in the repository:

- Dockerfile
  - Dockerfile used to build and publish BigchainDB production images.
- Dockerfile-dev
  - Dockerfile used for development purposes.
- compose/bigchaindb-driver/Dockerfile
  - Dockerfile used to spawn a container in development environment with bigchaindb-driver installed.
    - This seems to be an invalid usecase for a separate container. In my opinion, `bigchaindb-driver` does not qualify as a service. It is just a python-package that can reside on a any of the containers, preferably BigchainDB.
- compose/bigchaindb-server/Dockerfile
  - This is a duplicate of `Dockerfile-dev`
- compose/travis/Dockerfile
  - Dockerfile used to build/run BigchainDB service in CI.

## Motivation
There are multiple problems with our current workflow and directory structure which also impacts testing:

- We need to deprecate or remove the unused or redundant docker-compose and Docker file(s).
- Since our development and CI files are different, there is no way to test the development `docker-compose` file(s). There are two solutions to this:
  - Write tests to test the docker-compose for development.
  - Integrate the development and CI workflow.


## Specification

### Proposed Solution

- Clean up the deprecated workflow(s).
  - Remove `docker-compose.rdb.yml`.
  - Remove `docker-compose.benchmark.yml`.
  - Remove `docker-compose.docs.yml`, since building documentation should be part of a development environment.
  - Remove `docker-compose.ssl.yml`, because we are planning to remove SSL support for MongoDB.
  - Remove `docker-compose.network.yml` file, this workflow will be supported by another deployment method. Currently, we are not using this method for development. We will have Vagrant, Ansible and K8s network driver to offer this functionality.

- Update the workflows with the new deployment workflow(s).
  - Update `docker-compose.yml` to support the current deployment strategy i.e. BigchainDB + Tendermint + Stand alone MongoDB.
- Integrate the development and CI compose file(s) in such a way that there are minimal differences and they can be tested on a CI, also rename the files:
  - `docker-compose.yml` will have the base services i.e.
  BigchainDB, MongoDB, Tendermint started with:
    - `docker-compose up bdb`
  - Any tools used to help with development, `bigchaindb-driver`, `nginx`, and `curl-client`,can be brought up using:
    - `docker-compose up curl-client`
    - `docker-compose up bdb-driver`
    - `docker-compose up vdocs`

- Update the MongoDB and Tendermint version(s) to the latest supported version:

  - mongo:3.4.13
  - tendermint/tendermint:0.13

- Deprecate the redundant Dockerfiles and only keep two:
  - Dockerfile
  - Dockerfile-dev

- Remove `compose/bigchaindb-server`, `compose-bigchaindb-driver`, and `compose/travis`.

- [IF NEEDED]: Introduce `bigchaindb/tools` directory to handle `Dockerfile`(s) for tools required for development i.e.
  - `bigchaindb-driver`
    - Python driver to interact and transact with the BigchainDB server.
  - `curl-client`
    - To verify if tendermint service is up i.e. making a curl call to `/abci_query` endpoint and BigchainDB root endpoint.
  - `nginx`
    - For hosting docs


### End user impact
This will impact and introduce ease for end users i.e. users deploying BigchainDB for development and testing.

**Build**

```
# For development/testing and CI
docker-compose build
```

**Run**

```
# For development/testing and CI
docker-compose up bdb
```

**Run tests**
```
# Without coverage
docker-compose run --rm --no-deps bdb pytest -v

# With coverage
docker-compose run --rm --no-deps bdb pytest -v --cov=bigchaindb
```

**Build docs**
```
docker-compose run --rm --no-deps bdb make -C docs/server html
```


### Deployment impact
One impact on the deployment strategy is covered with earlier in the [End user impact section](#end-user-impact) of this document.

Another deployment impact this change will have is with CI, we will need to update the CI scripts @`bigchaindb/.ci` to use `docker-compose.yml` instead of `docker-compose.travis.yml`.


### Documentation impact
Following documents will be impacted:

- [CONTRIBUTING.md](https://github.com/bigchaindb/bigchaindb/blob/tendermint/CONTRIBUTING.md)
- [Run BigchainDB with Docker](https://docs.bigchaindb.com/projects/server/en/tendermint/appendices/run-with-docker.html)
- [tests/README.d](https://github.com/bigchaindb/bigchaindb/blob/tendermint/tests/README.md)
- [TENDERMINT_INTEGRATION.rst](https://github.com/bigchaindb/bigchaindb/blob/tendermint/TENDERMINT_INTEGRATION.rst)
- [docs/contributing](https://github.com/bigchaindb/bigchaindb/pull/2119)


## Rationale
Already covered with [Abstract](#abstract) and [Motivation](#motivation)


## Implementation


### Assignee(s)
Primary assignee(s): @muawiakh


### Targeted Release
BigchainDB==v2.0


### Status
unstable


## Copyright Waiver
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
