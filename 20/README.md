```
shortname: 20/BOUNTY
name: Bounties in BigchainDB
type: Meta
status: Raw
editor: Chalid Mannaa <chalid@bigchaindb.com>
```

This document describes a pragmatic bounty system that enables open source projects to reward coding contributions to software in the BigchainDB ecosystem.

This specification is based on the intends and concepts of the [Gitcoin](https://gitcoin.co/) project.
## Change Process
This document is governed by [1/C4](../1/README.md) and  [2/COSS](../2/README.md).

## Language
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [BCP 14](https://tools.ietf.org/html/bcp14) \[[RFC2119](https://tools.ietf.org/html/rfc2119)\] \[[RFC8174](https://tools.ietf.org/html/rfc8174)\] when, and only when, they appear in all capitals, as shown here.

## Goals
The primary goal of BOUNTY is to facilitate a reward process for open source software contributions into github repositories. Such repositories should represent elements of the ecosystem building for the web3. 

BOUNTY is intended to above all be economical and rapid, so that it is useful to small teams with little time to spend on more formal processes.

## Problem and Motivation
Software [repositories](https://help.github.com/articles/about-repositories/) in [Github](https://github.com/) contain [issues](https://guides.github.com/features/issues/) . Issues represent problems in their specific context which SHOULD be resolved. 

An issue is called **bounty** when it has 

* a [requirement specification](https://en.wikipedia.org/wiki/Software_requirements_specification), 
* a [definition of done](https://www.scrum.org/resources/blog/walking-through-definition-done), 
* a funding,
* a resolution proposal, 
* an approved revision, 
* a merge into the master code branch and 
* a successful payment transaction. 

The purpose of bounties is to 
 * resolve issues,
 * scale developments in the ecosystem,
 * attract contributors for key components,
 * support adoption and
 * self-maintenance
 
## Process
The process requires following activities that should be performed

1. Identify issue and provide requirements specification 
1. Estimate efforts for the work to be done
1. Define the bounty, eg. funds/DoD
1. Clarify revisions and issue labeling ("bounty")
1. Create and submit bounty on the platform
1. Publish to blog, slack, gitter, twitter and linkedin
1. Monitor progress and comment where applicable
1. Revise pull request and merge
1. Reward / pay the bounty hunter

Gitcoin as a platform supports the lifecycle of the bounty with Github integration and enables monitoring via email. Additional guidance can be found [here](https://docs.google.com/document/d/1_U9IdDN8FIRMGAdLWCMl2BnqCTAv558QvyJiSWQfkbs/edit?usp=sharing).

![img](https://github.com/gitcoinco/web/raw/master/docs/bounty_flow.png) 

## License
Copyright (c) 2018 BigchainDB GmbH, Notice <notices@consensys.net> Copyright (C) 2018 Gitcoin

This BEP is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This BEP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses.