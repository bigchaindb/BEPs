# BigchainDB Enhancement Proposals (BEPs)

This is the BigchainDB Enhancement Proposal project. We collect BEPs for APIs, protocols, and processes.

The process to add or change a BEP is the following:
- A BEP is created and modified by pull requests according to [C4](./1).
- BEP lifecycle SHOULD follow the lifecycle defined in [COSS](./2).
- Non-cosmetic changes are allowed only on [Raw](./2#raw-beps) and [Draft](./2#draft-beps) specifications.

# Current BEPs

Short Name    | Title                                                        | Type     | Status     | Editor
--------------|--------------------------------------------------------------|----------|------------|-------
[1/C4](1)     | Collective Code Construction Contract                        | Meta     | Draft      | Alberto Granzotto
[2/COSS](2)   | Consensus-Oriented Specification System                      | Meta     | Draft      | Alberto Granzotto
[3/UPSERT-VALIDATORS](3) | Dynamically add/update/remove validators at runtime | Standard | Stable | Vanshdeep Singh
[4/STANDARDIZE-DC](4) | Standard process to set up a local node for development & testing, using Docker Compose | Standard | Raw | Muawia Khan
[5/IDRP](5)   | Illegal Data Response Plan                                   | Informational | Raw   | Troy McConaghy
[6/SWP](6)    | Shared Workspace Protocol                                    | Meta     | Draft      | Alberto Granzotto
[7/PUBLIC-API](7) | Definition of the BigchainDB Public API                  | Informational | Raw   | Troy McConaghy
[8/CRASH-RECOVERY](8) | Restore system state after crash                     | Standard | Raw        | Vanshdeep Singh
[10/SAAR](10)  | A Strangler Application Approach to Rewriting Some Code in Go | Informational | Raw   | Alberto Granzotto
[12/TX-SPEC-1](12) | BigchainDB Transaction Spec v1                          | Standard | Stable     | Troy McConaghy
[13/TX-SPEC-2](13) | BigchainDB Transaction Spec v2                          | Standard | Stable     | Troy McConaghy
[14/GIDR](14) | Guidelines to Improve Drivers Reliability                    | Standard | Raw        | Alberto Granzotto

# Current Participants

## Contributors

- Anyone who wants to contribute
- The whole [BigchainDB Team in Berlin](https://github.com/orgs/bigchaindb/people)

## Maintainers

Everyone with the ability to merge pull requests. Today that is mainly BigchainDB employees.

In the future, we can add more people who are not BigchainDB employees as maintainers.

Some people have specializations:

- Python Driver: Katha
- JavaScript Driver: Manolo
- Core: Vanshdeep, Alberto
- Docker, Kubernetes, NGINX: Shahbaz, Muawia
- Docs: Troy

## Administrators (Founders and Others)

- Kamal - @GataKamsky
- Gautaum - @gautamdhameja
- Alberto - @vrde
- Vanshdeep - @kansi
- Troy - @ttmc
- Trent - @trentmc (Inactive but advising)

Note: Administrators serve limited terms of six months or less. That's the idea, anyway.
