```
shortname: 17/AZURE-1
name: Listing BigchainDB in Azure Marketplace, Phase 1
type: Standard
status: Raw
editor: Troy McCoanghy <troy@bigchaindb.com>
```

# Abstract

A proposal to get BigchainDB listed on Azure Marketplace.

# Motivation

If BigchainDB were listed in the [Azure Marketplace](https://azuremarketplace.microsoft.com/en-us/marketplace/):

- it would have more visibility, especially for users of Microsoft Azure.
- it would be easy for some people to install and try.
- it would benefit from Azure's marketing efforts.

BigchainDB version 2.0 is the first version that we consider production-ready, for some use cases. As such, we're more comfortable publishing it on Azure Marketplace than we were in the past.

Also, until now, the main BigchainDB production deployment template required an entire Kubernetes cluster for each BigchainDB node, making it very tricky to package for Azure Marketplace. At the time of writing, we were developing a virtual-machine-based deployment template which is _much easier_ to package for Azure Marketplace.

# Specification

We propose listing an offer to deploy a single BigchainDB node on a single Azure virtual machine (VM). We can consider listing an offer to deploy a BigchainDB network in the future.

There is information about listing on Azure Marketplace in the Microsoft Azure help page titled "[Azure Marketplace and AppSource Publisher Guide](https://docs.microsoft.com/en-us/azure/marketplace/marketplace-publishers-guide)". It presents some decisions:

- Publish BigchainDB on Azure Marketplace or AppSource? Azure Marketplace.
- What listing type? List, Trial or Transaction? Transaction.

The next step is to become a "cloud partner publisher."

- We (BigchainDB GmbH) signed up for something like that some time ago, so we might be able to use our existing account ("azure publisher"). It could login to the Microsoft developer resources dashboard and the Microsoft Azure Publishing workspace as of May 9, 2018.
- We also have another, different account that we use for Microsoft Azure itself ("bruce"). That second account has Azure credits associated with it.
- Ricardo also started signing up for a _third_ account.

We will have to determine which account to use. We should make sure all the account information is up-to-date.

We'd like to allow several BigchainDB accounts to have access. Apparently that _can_ be done, so long as the accounts use Azure Active Directory.

We might have to do some more steps in the "2. Become a cloud partner publisher" section of that help page.

Lastly, we must do step "3. Complete offer and listing type prerequisites". For details, see the [Publisher Guide](https://docs.microsoft.com/en-us/azure/marketplace/marketplace-publishers-guide). The main _technical_ one is to create an Azure-compatible virtual hard disk (VHD).

# Rationale

As far as I know, deploying an entire network on Azure is quite involved and requires significant effort, e.g. to write the necessary Azure Resource Manager (ARM) template(s). Deploying a single VM is a much simpler way to get started.

# Implementation

This section will be started once we do some of the things outlined in the Specification section.

# Copyright Waiver

To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
