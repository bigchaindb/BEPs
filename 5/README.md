```
shortname: 5/IDRP
name: Illegal Data Response Plan
type: Informational
status: raw
editor: Troy McConaghy <troy@bigchaindb.com>
contributors: Carsten Stöcker
reviewers: Kamal Ved, Alberto Granzotto, Dimitri De Jonghe, Sarah Vallon, Michael Rüther
```

## Abstract

If Joe is operating a BigchainDB node, he doesn't want to get fined, go to jail, or get capital punishment. But it might happen if some illegal data ends up being stored on his computer, because storing illegal data is illegal (by definition)! The outcome would depend on the legal jurisdiction where he lives. The problem is that data stored in BigchainDB is supposed to be immutable, so he can't delete it or change it. He has to keep breaking the law and face the consequences. Or maybe quit operating his node. We show that he doesn't have to live with that. There's a logical error that's obvious and easy to avoid. Joe will be okay! We show what Joe can do to keep operating his node. We also show that other solutions, while they seem promising, *won't work as expected.* We provide several thought experiments (*Gedankenexperiments*) to illustrate.

## Motivation

We want people to use BigchainDB, not to be terrified of breaking the law if they do so. To do that, we:

* Show BigchinDB node operators how they can avoid breaking the law. We provide a step-by-step **Illegal Data Response Plan (IDRP)** ("Plan").
* Aim to keep BichainDB node operators in good terms with the law.
* Explain what they shouldn't do because it won't work, and why.

## Type of BEP

This is an **Informational BigchainDB Enhancement Proposal** (BEP) because it provides general guidelines or information to the BigchainDB community.

## BEP Name

This BEP can be referred to as "5/IDRP" or "BEP-5." The number might change if someont else proposes another BEP that becomes number 5.

## Rationale

The immediate reason for writing this BEP was that a new BigchainDB consortium was starting and there were questions about what they should do about the illegal data should it show up on their computers somehow. Some were seriously wondering what they were getting themselves into.

## About GDPR

This BEP is not about how to comply with the European Union's [General Data Protection Regulation (GDPR)](https://www.eugdpr.org/). Look elsewhere for information about GDPR compliance.

There are *rare* cases where GDPR-relevant data is also illegal data. This BEP can help you then, but only because the data is illegal, not because it is GDPR-relevant.

## Who This Plan is for (and not for)

The Plan is for smaller consortia who need *some* plan. It should be fine for them. It's an "MVP," a *Minimum Viable Plan*.

The Plan is *not* for big consortia or companies. They can afford attorneys who can come up with something better.

## The Need for Governance

Coordinating execution the Plan will take some communication. The consortium members will all have to *agree* on what to do, and to do it. In short, there is a need for some minimal consortium *governance* for the Plan to get done and to work.

## The Illegal Data Response Plan

Here's what we reccommend a node operator do if they discover illegal data stored on their computer because it was stored there by BigchainDB:

1. Be sure that illegal data have been clearly identified. Have some reasonable, validated and difficult-to-dispute evidence that the data is illegal. Avoid [crying wolf](https://dictionary.cambridge.org/dictionary/english/cry-wolf).
1. Publicly announce that you've discovered illegal data on your computer and that you are following the **Illegal Data Response Plan** spelled out here. You can link to this page. The process now begins. You are acting responsibly. The law will give you a a reasonable amount of time to act. (Unless you are in some really sucky jurisdiction. Use discretion.)
1. Inform all other members of the BigchainDB consortium where your node is a cluster member. Tell them to follow the same plan.
1. Contact BigchainDB GmbH at contact@bigchaindb.com or some other way. Employees tend to have an email like firstname@bigchaindb.com. This is like [the Bat-Signal](https://en.wikipedia.org/wiki/Bat-Signal). You need their help. They will help. They don't want you to get in trouble with the law either! That would be bad for BigchainDB. (Note: You don't _have_ to contact BigchainDB if you have developers who are competent to do the next step without help.)
1. The BigchainDB team (or your team) will work with you create a modified version of BigchainDB Server (software) that is okay with certain specific data being deleted. This the core magic bit. It means that soon you will be deleting data and breaking the "immutability rule" but there's _nothing_ that was stopping you from doing that before. You could always delete data, but it would have broken BigchainDB. Unless BigchainDB was modified not to care, which is what's now happening!
1. Upgrade BigchainDB Server on your node to run the new version. *All nodes in the network must do this upgrade.*
1. Delete the illegal data. *All nodes in the network must do this deletion step.*

Optional follow-up: a _second_ version of BigchainDB Server that will only believe the new situation, with the illegal data deleted is okay. The old situation, with the illegal data still there, should register as an error. Upgrade to that.

Note: BigchainDB currently stores all data on-chain, but if it stores some data off-chain in the future, then the general idea of the plan would still work. It would just have to be modified a bit.

A conceptually simpler but more expensive alternative would be to make all changes or deletions necessary, find the highest unchanged block, and generate/write a whole new blockchain following that block, i.e. a "clean fork." All the new/clean blocks must be agreed upon by more than two thirds of the network (i.e. using Tendermint consensus), and that might be impossible in practice.

## Your Expected Response

"But BigchainDB is supposed to be immutable. This breaks immutability!"

Yes. And it gets you out of trouble with the law. You'll notice it's not easy to do deletion. You can't just delete data without BigchainDB complaining. You have to do something special to make it not complain first.

Moreover, the planned change is extremely specific. It doesn't make the entire blockchain mutable. If only one transaction is involved, then the change will allow only two possible versions of that transaction. It won't allow arbitrary changes to the transaction. All the other transactions remain as immutable as ever.

## Things that Won't Work

There are many things that won't work. That's what the rest of this BEP is about: to convince you that those other ways will still land you in trouble with the law.

### "We're running a blockchain so the rules should be different for us."

You might say, "Blockchains are supposed to be immutable so we can't delete the data. Therefore the law should make an exception for us."

I don't know of any jurisdiction that makes an exception for blockchains. The best you can hope for is for your case to end up in legal limbo for months or years, until some court or legislature decides what to do. Meanwhile, your users, partners and investors (and potential ones) will be scared away. Is that really what you want?

### Buy Insurance!

Insurance isn't going to do you much good if you get arrested for breaking the law. It might pay for some lawyers to tie your case up in the courts for a few years, but you've got to keep storing the illegal data, and it's unlikely that law enforcement is going to let you do that.

### Filter Incoming Data!

There's no way to detect all illegal data, not even using the best classifiers (Machine Learning) in the world. There are all kinds of tricks to fool classifiers. Like [Steganography](https://en.wikipedia.org/wiki/Steganography). Illegal data will get by. Now what?

That said, it wouldn't hurt to have some basic filters ("sanity checks") on incoming data, to make sure it conforms to what you're expecting. That's useful for other reasons, but don't expect it to stop illegal data.

### Allow Only Encrypted Data!

If the incoming data is encrypted, then it's okay, right?

That depends on the legal jurisdiction. But even if it were legal to store encrypted illegal data everywhere in the world, there are many issues with the "encrypt everything solution."

Here's a thought experiment:

> Monica the Criminal uploads some encrypted illegal data to your node somehow. Then she publishes _the decryption key_ in ads in 50 newspapers globally. Now anyone can get the encrypted illegal data _and_ the decryption key and it's as if the data was never encrypted. They can get the unencrypted illegal data.

Moreover, sometimes encryption algorithms get broken, i.e. someone discovers a fast decryption algorithm, so all the data encrypted by the encryption algorithm becomes effectively not-encrypted. Quantum computers bring the same issue. History teaches us we shouldn't assume encryption is forever, but blockchains are supposed to store data forever.

### Allow Only Hashed Data!

(There might be a way to make this work, but how _depressing_ if the only thing you are allowed to store is hashes!) To first order, if you allow arbitrary hashes to come in, then here's your thought experiment of how to use that to upload illegal data:

> Richard the Criminal gets an illegal data file. You can think of it as a sequence of zeroes and ones. Now he starts sending each zero and one, one at a time, as follows. It's a zero if the hash (as binary) starts with 0, and 1 otherwise. This is slow but will work as a proof of concept. You could speed this up, but the result is the same: allowing arbitrary hashes is like allowing arbitrary data, over time.

Exercise for the reader: what could you do to prevent the above technique? There's a way. It's fun.

### Store All the Data Off-Chain!

_Something_ must get stored on-chain, unless it's a trivial (and therefore useless) blockchain. If on-chain data depends, _in any way_, on the transactions submitted by external parties, then those parties can manipulate their transactions to store arbitrary data on-chain, including illegal data.

For example, when Bitcoin started, it didn't support the `OP_RETURN` opcode, but it was still possible to store arbitrary data in the Bitcoin blockchain. There's a survey of methods in the paper "[Data Insertion in Bitcoin's Blockchain](https://ledgerjournal.org/ojs/index.php/ledger/article/viewFile/101/93)" by Sward, Vecna and Stonedahl (2018).

If it's possible to prevent external parties from storing arbitrary data on-chain, then there are a few possibilities:

1. If the off-chain data must be stored immutably forever, then the people storing that data face the same problem with illegal data. It has just been shunted to them.
1. If the off-chain data can be changed or deleted without causing problems, then haven't we lost one of the main blockchain features, i.e. immutability?
1. If the off-chain data can be changed or deleted, but it takes a lot of effort to prevent problems, then you've got a variant of the plan proposed in this BEP. (BigchainDB, today, stores all data on-chain, so this variant is irrelevant for the BigchainDB of today.)

### Make the BigchainDB Network Fully Private!

What if you just prevent anyone from writing to the network except for, say, the node operators themselves. Surely that would keep the bad guys out? Nope. You need to start thinking more like a criminal!

Here's a thought experiment:

> Julie the Criminal breaks into the office of Node Operator Fred at 3:00 am. She uses one of those things to make a nice circle in the glass, like in the movies. Or something. Anyway, she gets in. She sits at Fred's computer, she turns it on, enters the password from the sticky note on the montior, and she's in. (Maybe she got the password some other way, like social engineering. It's not that hard to make someone believe you need their password, or to trick them into telling it to you.) Now she uploads some illegal data because Fred's computer thinks she is Fred, who has access. Done.

Read [_The Art of Deception: Controlling the Human Element of Security_](https://www.amazon.com/Art-Deception-Controlling-Element-Security/dp/076454280X), by by Kevin Mitnick, Wiley, 2003. 

"People always make the best exploits. I've never found it hard to hack most people. If you listen to them, watch them, their vulnerabilities are like a neon sign screwed into their heads." - [Elliot](https://youtu.be/32VKyY4ymvc?t=1m5s), _Mr. Robot_

### Make the BigchainDB Network Fully Public!

Bitcoin and Ethereum are public networks and they haven't had problems with illegal data! Make BigchainDB a public, permissionless network like that! All nodes are anonymous! There would be nobody to go after!

For a long time, there was no illegal data known to be stored on the Bitcoin or Ethereum blockchains. Why? Here are some potential explanations:

* It’s considered a taboo topic in the blockchain world, so people tend not to think about it in general.

* Nobody with significant investment in those networks will want to bring it up, or do it, and risk their investment.

* The people developing the software to implement permissionless networks are caught up in the fun technical questions, and not spending much time pondering legal questions. Even if they do think about legal questions, they say, “I am not a lawyer. I am not qualified.” They assume that the lawyers have thought about the legal questions and decided that everything is okay. The fact is, everyone knows about certain basic laws so they don’t get in trouble, and that’s all that’s needed here. For example, you don’t need a law degree to know that you can’t steal headphones from an Apple Store. A software developer can’t say, “I just wrote the software to control the headphone-stealing drone. I’m not a lawyer, so I’m not qualified to comment on whether it’s legal to use my software.”

* It’s quite expensive to write a lot of data to those blockchains. Something like tens of millions of US dollars per Gigiabyte. Not free!

* A law-abiding person would be reluctant to store some illegal data (e.g. in Bitcoin `OP_RETURN` slots), because they’d have to have some first, before they can store it elsewhere, and that’s illegal. They might consider doing it anonymously, but it’s not easy to be anonymous online, so why risk it?

In any case, it's just a matter of time before someone stores illegal data on a public blockchain. In early 2018, some researchers at Germany's RWTH Aachen University (Matzutt _et al._) published [a paper](https://fc18.ifca.ai/preproceedings/6.pdf) describing potentially-illegal data that they discovered in the Bitcoin blockchain. Moreover, they wrote:

> "Our analysis shows that certain content … can render the mere possession of a blockchain illegal."

The basic idea is that everyone hosting a Bitcoin or Ethereum full node will have a full copy of the illegal data and therefore will be acting illegally. They will all become criminals. Maybe they aren't caught yet, but do you think Tim the university student is going to continue running a Bitcoin full node if it means he risks going to jail rather than graduating and marrying his fiancee in June? No, he is not. He's smart. He will shut down his node.

Only outlaws, scofflaws and crazy liberarians will be left hosting nodes.

In America and Europe, people know who of their friends has crypto nodes. There won't be any hiding. Bitcoin and Ethereum people tend to be well-known. They chat on Twitter and go to events. The authorities would have no trouble finding them, and if they continue to run nodes, they will get in trouble. The whole anonymity thing is an illusion.

### Erasure Coding!

[Erasure coding](https://en.wikipedia.org/wiki/Erasure_code) is pretty neat. You can take a file and break it into 30 pieces, for example, so that any ten of the pieces are needed to reconstruct the original file. It's hard to believe that's possible. But it is. Math is cool. Data centers use erasure coding to save money.

Even better, each piece is useless by itself. Just useless noise. It's like there's nothing there. No way you'll get in trouble for storing those pieces, am I right?

Maybe not! For example, it's in some places it's illegal to carry a gun, but it's also illegal to carry _gun parts_. This depends on the legal jurisdiction, of course. But the idea is that even though a piece isn't dangerous by itself, it's _still illegal_. A lawyer could make an analogy to convince a judge or jury that a piece of an illegal file is similarly illegal.

Maybe someday erasure coding could be used, but for now the legal question isn't decided yet, so why risk it?

Moreover, if it's known that a blockchain has some illegal data stored in it, somehow, then many people won't use it (e.g. for ethical reasons).

### Deindex the Data!

Google and other search engines are often asked to remove links from their search indexes, so those links stop showing up in search results. Maybe we could just deindex the illegal data in the blockchain?

Even if that was possible without breaking the blockchain or its auditability, the illegal data would still be stored _somewhere_, and whoever is storing it is still breaking the law.

### There Must Be a Way!

Please share! If there is, and it works, that would be awesome.

I wouldn't be surprised if some cryptographers figure out some great tricks, but I'm not from that world and I can't guess what they might do. I know it's just math, and math can be used to do amazing things, so there is hope!

Meanwhile, we've got to do something _today._

## Why Now?

Why didn't we publish this sooner? I actually proposed an idea like this over a year ago, and Trent (my brother, and our CTO) liked it.

We told the idea to some of our work colleagues (who will remain nameless), and they _hated it_. "Blockchains are supposed to be immutable!" they said. "Do this and BigchainDB won't be a blockchain anymore!"

So we dropped it. Maybe we are too nice. Dogmatism got in the way of pragmatism. Well, pragmatism is back.

## Can I Suggest an Improvement to This BEP?

BigchainDB GmbH has a process to improve BEPs like this one. Please see [BEP-1/C4](https://github.com/bigchaindb/BEPs/blob/master/1) and [BEP-2/COSS](https://github.com/bigchaindb/BEPs/blob/master/2).

Your consortium might have a variation of the IDRP. Your consortium can modify its variant using it's own governance processes.

## Copyright Waiver

_To the extent possible under law, the person who associated CC0 with this work_ (Troy McConaghy, editor) _has waived all copyright and related or neighboring rights to this work._
