```
shortname: 2/COSS
name: Consensus-Oriented Specification System
status: raw
editor: Alberto Granzotto <alberto@bigchaindb.com>
contributors: Troy McConaghy <troy@bigchaindb.com>, Katha Griess <katha@bigchaindb.com>
```

This document describes a consensus-oriented specification system (COSS) for building interoperable technical specifications. COSS is based on a lightweight editorial process that seeks to engage the widest possible range of interested parties and move rapidly to consensus through working code.

This specification is based on [unprotocols.org 2/COSS](https://rfc.unprotocols.org/spec:2/COSS/) and on [EIP1 - EIP Purpose and Guidelines](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1.md).

## Change Process
This document is governed by the [2/COSS](../2/README.md) (COSS).

## Language
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [BCP 14](https://tools.ietf.org/html/bcp14) \[[RFC2119](https://tools.ietf.org/html/rfc2119)\] \[[RFC8174](https://tools.ietf.org/html/rfc8174)\] when, and only when, they appear in all capitals, as shown here.

## Goals
The primary goal of COSS is to facilitate the process of writing, proving, and improving new technical specifications. A "technical specification" defines a protocol, a process, an API, a use of language, a methodology, or any other aspect of a technical environment that can usefully be documented for the purposes of technical or social interoperability.

COSS is intended to above all be economical and rapid, so that it is useful to small teams with little time to spend on more formal processes.

Principles:

* We aim for rough consensus and running code.
* Specifications are small pieces, made by small teams.
* Specifications should have a clearly responsible editor.
* The process should be visible, objective, and accessible to anyone.
* The process should clearly separate experiments from solutions.
* The process should allow deprecation of old specifications.

Specifications should take minutes to explain, hours to design, days to write, weeks to prove, months to become mature, and years to replace.

Specifications have no special status except that accorded by the community.

The author of the specification is responsible for building consensus within the community and documenting dissenting opinions.

## Architecture

### Types of specification
There are three types of specifications:
* A **Standard Track Specification** describes any change to network protocols, transaction validity rules, proposed application standards/conventions, or any change or addition that affects the interoperability of applications using BigchainDB products.
* An **Informational Specification** describes a BigchainDB design issue, or provides general guidelines or information to the BigchainDB community, but does not propose a new feature. Informational Specifications do not necessarily represent BigchainDB community consensus or a recommendation, so users and implementers are free to ignore Informational Specifications or follow their advice.
* A **Meta Specification** describes a process surrounding BigchainDB or proposes a change to a process.

### Specification Format
A specification is a set of Markdown documents (the main file SHOULD be called `README.md`), together with comments, attached files, and other resources. A specification is identified by its number and short name (e.g. this specification is **2/COSS**). The number of the specification is also the name of the directory where its files are stored.

Every specification (including branches) carries a different number. New versions of the same specification have new numbers.

### Specification template
TBD: Embed Muawia work here https://github.com/bigchaindb/bigchaindb/tree/master/proposals

### Copyright Waiver
Except for 1/C4 and 2/COSS, all Specifications MUST be released to the public domain.
The following waiver SHOULD be used:
> To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

## COSS Lifecycle
Every specification has an independent lifecycle that documents clearly its current status.

A specification has six possible states that reflect its maturity and contractual weight:

![Lifecycle diagram](lifecycle.png)

### Raw Specifications
All new specifications are **raw** specifications. Changes to raw specifications can be unilateral and arbitrary. Those seeking to implement a raw specification should ask for it to be made a draft specification. Raw specifications have no contractual weight.

### Draft Specifications
When raw specifications can be demonstrated, they become **draft** specifications. Changes to draft specifications should be done in consultation with users. Draft specifications are contracts between the editors and implementers.

### Stable Specifications
When draft specifications are used by third parties, they become **stable** specifications. Changes to stable specifications should be restricted to cosmetic ones, errata and clarifications. Stable specifications are contracts between editors, implementers, and end-users.

### Deprecated Specifications
When stable specifications are replaced by newer draft specifications, they become **deprecated** specifications. Deprecated specifications should not be changed except to indicate their replacements, if any. Deprecated specifications are contracts between editors, implementers and end-users.

### Retired Specifications
When deprecated specifications are no longer used in products, they become **retired** specifications. Retired specifications are part of the historical record. They should not be changed except to indicate their replacements, if any. Retired specifications have no contractual weight.

### Deleted Specifications
Deleted specifications are those that have not reached maturity (stable) and were discarded. They should not be used and are only kept for their historical
value. Only Raw and Draft specifications can be deleted.

## Editorial control
A specification MUST have a single responsible editor, the only person
who SHALL change the status of the specification through the lifecycle stages.

A specification MAY also have additional contributors who contribute changes to it. It is RECOMMENDED to use the [C4 process](../1/README.md) to maximize the scale and diversity of contributions.

The editor is responsible for accurately maintaining the state of specifications and for handling all comments on the specification.

## Branching and Merging
Any member of the domain MAY branch a specification at any point. This is done by copying the existing text, and creating a new specification with the same name and content, but a new number. The ability to branch a specification is necessary in these circumstances:

* To change the responsible editor for a specification, with or without the cooperation of the current responsible editor.
* To rejuvenate a specification that is stable but needs functional changes. This is the proper way to make a new version of a specification that is in stable or deprecated status.
* To resolve disputes between different technical opinions.

The responsible editor of a branched specification is the person who makes the branch.

Branches, including added contributions, SHOULD be dedicated to the public domain using CC0 (just like the original specification). This means that contributors are guaranteed the right to merge changes made in branches back into their original specifications.

Technically speaking, a branch is a *different* specification, even if it carries the same name. Branches have no special status except that accorded by the community.

## Conflict resolution
COSS resolves natural conflicts between teams and vendors by allowing anyone to define a new specification. There is no editorial control process except that practised by the editor of a new specification. The administrators of a domain (moderators) may choose to interfere in editorial conflicts, and may suspend or ban individuals for behaviour they consider inappropriate.

## Conventions
Where possible editors and contributors are encouraged to:

* Refer to and build on existing work when possible, especially IETF specifications.
* Contribute to existing specifications rather than reinvent their own.
* Use collaborative branching and merging as a tool for experimentation.

## License
Copyright (c) 2008-16 Yurii Rashkovskii <yrashk@gmail.com>, Pieter Hintjens <ph@imatix.com>, André Rebentisch <andre@openstandards.de>, Alberto Barrionuevo <abarrio@opentia.es>, Chris Puttick <chris.puttick@thehumanjourney.net>
Copyright (c) 2018 BigchainDB GmbH

This Specification is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This Specification is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses.
