```
shortname: BEP-5
name: Dealing with Illegal Data
type: Informational
status: raw
editor: Troy McConaghy <troy@bigchaindb.com>
contributors: Carsten Stöcker
reviewers: Kamal Ved, Alberto Granzotto, Dimitri De Jonghe, Sarah Vallon, Michael Rüther
```

# Overview

## Some History

BEP-5 has changed a lot since its initial version. It began as a plan for how to respond if illegal data got stored in a BigchainDB network, with some notes about things that don't work 100% of the time. It was written because a new consortium was starring and they needed to know how to handle illegal data, if any got stored in their network.

The current version of BEP-5 advocates for prevention as a first line of defense, even though prevention doesn't work 100% of the time. The part about how to deal with stored illegal data is about what can be done _today_, based on how BigchainDB works today. The last part covers some ideas for the future.

## Illegal Data?

Some data is illegal to store in all (or almost all) jurisdictions. If you can't think of an example, then see the paper:

Matzutt, Roman, et al. "[A Quantitative Analysis of the Impact of Arbitrary Blockchain Content on Bitcoin.](https://fc18.ifca.ai/preproceedings/6.pdf)" _Proceedings of the 22nd International Conference on Financial Cryptography and Data Security (FC)_. Springer. 2018.

## What about Personal Data and GDPR Compliance?

This BEP is not about how to comply with the European Union's [General Data Protection Regulation (GDPR)](https://www.eugdpr.org/). That said, some of the techniques described in this BEP might be used to help with GDPR compliance.

## "Blockchains are supposed to be immutable so we can't delete the data. Therefore the law should make an exception for us."

I don't know of any jurisdiction that makes an exception for blockchains. The best you can hope for is for your case to end up in legal limbo for months or years, until some court or legislature decides what to do. Meanwhile, your users, partners and investors (and potential ones) will be scared away. Is that really what you want?

# Part 1: Preventing Illegal Data Storage

BigchainDB is designed so that it's very difficult to change or delete data once it has been stored. It's "practically immutable." Therefore, the operators of a BigchainDB network should do whatever they can to avoid having to change or delete data once it has been stored in their network.

While it's not possible to prevent the storage of illegal data 100% of the time, there are many steps that can be done to minimize how often it happens, including:

- **Whitelisted writers:** Only give write access to people (or autonomous agents) who are known or vetted ahead of time. There are many ways to set up and enforce write access. One can check the IP address. One can look for a client certificate (SSL certificate). One can look for specific HTTP request headers. One can check the public keys of the signers. And so on. There are several third party "API management" services offering access control and more.
- **Blacklisted writers:** One can block attempted writes from suspicious sources, such as from the IP addresses of known VPN exit nodes.
- **Filtering:** One can scan the incoming transactions to detect illegal or suspicious data, then block it, something like a spam filter or malware filter. There are third-party services which can help with that.
- **Only allow hashes:** BigchainDB transactions have many required fields, most of which aren't hashes, but the `asset.data` and `metadata` can contain arbitrary JSON strings. You could set up your network to only allow valid SHA-3 hashes (or similar) in _those_ fields. That won't prevent illegal data from getting stored, because 1) a bad actor might send illegal data encoded as faux hashes, and 2) there are all the other fields, such as the public keys, which could also contain encoded illegal data.
- **Only allow encrypted data:** This is similar to only allowing hashes, with the same caveats, but there's are more caveats specific to encrypted data: 1) In some jurisdictions, storing encrypted data that's known to decrypt to something illegal is illegal, even if you don't have the decryption keys. 2) If a bad actor stored encrypted illegal data, they could publicly publish the decryption key (e.g. in an ad in the _New York Times_ newspaper), and then it may as well be plaintext. Moreover, sometimes encryption algorithms get broken.

A note about insurance: It might be prudent to buy insurance, if possible, to help cover any costs (e.g. legal fees) that might be incurred if illegal data gets stored in the network. In other words, insurance won't prevent illegal data from getting stored, but it might help in case that happens.

# Part 2: The Illegal Data Response Plan

What should a BigchainDB consortum do if they learn that some illegal got stored in their network? Below, we outline a plan.

## Who the Plan is for (and not for)

The Plan is for smaller consortia who need *some* plan. It should be fine for them. It's an "MVP," a *Minimum Viable Plan*. It's *not* for big consortia or companies. They can afford developers and attorneys who can come up with something better.

## The Need for Governance

Coordinating execution the plan will take some communication. The consortium members will all have to *agree* on what to do, and to do it. In short, there is a need for some minimal consortium *governance* for the plan to get done and to work.

## The Plan

Here's what we reccommend a node operator do if they discover illegal data stored on their computer because it was stored there by BigchainDB:

1. Be sure that illegal data has been clearly identified. Have some reasonable, validated and difficult-to-dispute evidence that the data is illegal. Avoid [crying wolf](https://dictionary.cambridge.org/dictionary/english/cry-wolf).
1. Publicly announce that you've discovered illegal data on your computer and that you are following the plan spelled out here. You can link to this page. The process now begins. You are acting responsibly. Law enforcement should give you a a reasonable amount of time to act.
1. Inform all other members of the BigchainDB consortium where your node is a cluster member. Tell them to follow the same plan.
1. Maybe contact the current maintainers of BigchainDB Server (i.e. the bigchaindb/bigchaindb repository on GitHub) to ask for assistance, if needed.
1. Create a modified version of BigchainDB Server (software) that is okay with certain specific data being deleted, possibly with the assistance of the current maintainers of BigchainDB Server. This the core magic bit. It means that soon you will be deleting data and breaking the "immutability rule" but there's _nothing_ that was stopping you from doing that before. You could always delete data, but it would have broken BigchainDB. Unless BigchainDB was modified not to care, which is what's now happening!
1. Upgrade BigchainDB Server on your node to run the new version. *All nodes in the network must do this upgrade.*
1. Delete the illegal data. *All nodes in the network must do this deletion step.*

Optional follow-up: Develop _one more_ version of BigchainDB Server that will only believe the new situation, with the illegal data deleted is okay. The old situation, with the illegal data still there, should register as an error. Upgrade to that.

Note: BigchainDB currently stores all data on-chain, but if it stores some data off-chain in the future, then the general idea of the plan would still work. It would just have to be modified a bit.

A conceptually simpler but more expensive alternative would be to make all changes or deletions necessary, find the highest unchanged block, and generate/write a whole new blockchain following that block, i.e. a "clean fork." All the new/clean blocks must be agreed upon by more than two thirds of the network (i.e. using Tendermint consensus), and that might be impossible in practice.

## Your Expected Response

"But BigchainDB is supposed to be immutable. This breaks immutability!"

Yes. And it gets you out of trouble with the law. You'll notice it's not easy to do deletion. Moreover, the change is extremely specific. It doesn't make the entire blockchain mutable. If only one transaction is involved, then the change will allow only two possible versions of that transaction. It won't allow arbitrary changes to the transaction. All the other transactions remain as immutable as ever.

## Technical Notes

A key technical trick used by the plan is to change the hash functions and the signature functions used by BigchainDB (and Tendermint) to new ones, so that hashes/signatures after the change are the _same_ as hashes/signatures after the change. Here's a concrete example of how to do that with a SHA-3 hash function:

Suppose that before the change, the SHA-3 hash of a transaction was a1b2c3... and after the change (which changed the transaction), its SHA-3 hash was afafaf... We need to change BigchainDB to use a modified-SHA-3 hash function such that:

if SHA-3 hash is afafaf... then then the modified-SHA-3 hash is a1b2c3..., else the modified-SHA-3 hash = SHA-3 hash

Similar things have to be done with signature computation and signature verification functions.

# Part 3: Ideas for the Future

## Only Store "Safe Hashes"

One could make an ultra-simple blockchain where each transaction only contains a provably-random, large nonce and the value of hash(message + nonce), where hash() is a cryptographically secure hashing function. Those values can't encode any illegal data, so deletion would never be necessary.

Such a blockchain could be used to prove that the message existed before the block was written... if you have the message and know the associated nonce.

That would be a very different blockchain from what BigchainDB is today.

## Only Store Zero Knowledge Whizbangs

This is similar to only storing safe hashes, except the design space is bigger.

## Erasure Coding

[Erasure coding](https://en.wikipedia.org/wiki/Erasure_code) is neat. You can take a file and break it into 30 pieces, for example, so that any ten of the pieces are needed to reconstruct the original file. It's hard to believe that's possible. But it is. Data centers use erasure coding to save money.

Even better, each piece is useless by itself. Just noise. It's like there's nothing there.

Maybe it's legal to store such pieces, even if they're pieces that could be used to reconstruct some illegal data?

Maybe not. For example, in some places it's illegal to carry a gun, but it's also illegal to carry _gun parts_. This depends on the legal jurisdiction, of course. But the idea is that even though a piece isn't dangerous by itself, it's _still illegal_. A lawyer could make an analogy to convince a judge or jury that a piece of an illegal file is similarly illegal.

Some decentralized storage networks, such as Sia, already use erasure coding, so maybe a test case will arise from them.

Moreover, if it's known that a blockchain has some illegal data stored in it, in any way, then many people won't use it (or run a node) for ethical reasons.

## Maybe Permissionless Public Networks Can Get Away with Storing Illegal Data?

Bitcoin and Ethereum are permissionless public networks and they haven't had problems with illegal data, yet. Why? Here are some potential explanations:

* It’s considered a taboo topic in the blockchain world.

* Nobody with significant investment in those networks will want to bring it up, for fear of losing money.

* The people developing the software to implement permissionless networks are caught up in the fun technical questions, and not spending much time pondering legal questions. Even if they do think about legal questions, they say, “I am not a lawyer. I am not qualified.” They assume that the lawyers have thought about the legal questions and decided that everything is okay. The fact is, everyone knows about certain basic laws so they don’t get in trouble, and that’s all that’s needed here. For example, you don’t need a law degree to know that you can’t steal headphones from an Apple Store. A software developer can’t say, “I just wrote the software to control the headphone-stealing drone. I’m not a lawyer, so I’m not qualified to comment on whether it’s legal to use my software.”

* It’s quite expensive to write a lot of data to those blockchains. Something like tens of millions of US dollars per Gigabyte.

* A law-abiding person would be reluctant to store some illegal data (e.g. in Bitcoin `OP_RETURN` slots), because they’d have to have some first, before they can store it elsewhere, and that’s illegal. They might consider doing it anonymously, but it’s not easy to be anonymous online, so why risk it?

In any case, it's just a matter of time before someone stores illegal data on a public blockchain. In early 2018, some researchers at Germany's RWTH Aachen University (Matzutt _et al._) published [a paper](https://fc18.ifca.ai/preproceedings/6.pdf) describing potentially-illegal data that they discovered in the Bitcoin blockchain. Moreover, they wrote:

> "Our analysis shows that certain content … can render the mere possession of a blockchain illegal."

The basic idea is that everyone hosting a Bitcoin or Ethereum full node will have a full copy of the illegal data and therefore will be acting illegally. They will all become criminals. Will authorities go after them? Even if they can't find all of them, will they scare away all the law-abiding people?

## How to Improve this BEP

There is a process to improve BEPs like this one. Please see [BEP-1 (C4)](https://github.com/bigchaindb/BEPs/blob/master/1) and [BEP-2 (COSS)](https://github.com/bigchaindb/BEPs/blob/master/2).

## Copyright Waiver

<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law, all contributors to this BEP
  have waived all copyright and related or neighboring rights to this BEP.
</p>
