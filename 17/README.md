```
shortname: BEP-17
name: Listing BigchainDB in Azure Marketplace, Phase 1
type: Standard
status: Raw
editor: Troy McConaghy <troy@bigchaindb.com>
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
- Virtual machine or something else? Virtual machine.

We already have an "azure publisher" account which has enrolled in, signed up for, and otherwise gotten login rights for:

* account.microsoft.com
* Microsoft Dev Center at developer.microsoft.com/en-us/dashboard/overview
* Azure Portal at portal.azure.com
* Microsoft Partner Network at partner.microsoft.com
* Cloud Partner Portal at cloudpartner.azure.com
* Microsoft Azure Publishing workspace at publish.windowsazure.com/workspace/

That account should be able to add more user accounts by going to cloudpartner.azure.com. The added user accounts will then have access the same Microsoft Azure Publishing workspace. The added user accounts can be Microsoft accounts or Azure accounts.

We should publish a final/stable release of BigchainDB, i.e. BigchainDB 2.0.

The main _technical_ task is to create an Azure-compatible virtual hard disk (VHD).
See the help page titled, "[How to use Packer to create Linux virtual machine images in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer)".
The virtual machine image (VHD) can be stored under _any_ Azure subscription. It doesn't have to be stored under a subscription owned or managed by "azure publisher".

One can create a "new offer" (virtual machine offer) at cloudpartner.azure.com.

# Rationale

As far as I know, deploying an entire network on Azure is quite involved and requires significant effort, e.g. to write the necessary Azure Resource Manager (ARM) template(s). Deploying a single VM is a much simpler way to get started.

# Implementation

This section will be started once we do some of the things outlined in the Specification section.

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
