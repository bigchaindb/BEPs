```
shortname: 4/IDRP
name: Illegal Data Response Plan
type: Informational
status: raw
editor: Troy McConaghy <troy@bigchaindb.com>
```

## Abstract

If Joe is operating a BigchainDB node, he doesn't want to get fined, go to jail, or get capital punishment. But it might happen if some illegal data ends up being stored on his computer, because storing illegal data is illegal (by definition)! The outcome would depend on the legal jurisdiction where he lives. The problem is that data stored in BigchainDB is supposed to be immutable, so he can't delete it or change it. He has to keep breaking the law and face the consequences. Or maybe quit operating his node. We show that he doesn't have to live with that. There's a logical error that's obvious and easy to avoid. Joe will be okay! We show what Joe can do to keep operating his node. We also show that other solutions, while they seem promising, *won't work as expected.* We provide several thought experiments (*Gedankenexperiments*) to illustrate.

## Motivation

We want people to use BigchainDB, not to be terrified of breaking the law if they do so. To do that, we:

* Show BigchinDB node operators how they can avoid breaking the law. We provide a step-by-step **Illegal Data Response Plan (IDRP)**.
* Aim to keep BichainDB node operators in good terms with the law.
* Explain what they shouldn't do because it won't work, and why.

## Type of BEP

This is an **Informational BigchainDB Enhancement Proposal** (BEP) because it provides general guidelines or information to the BigchainDB community.

## BEP Name

This BEP can be referred to as "4/IDRP" or "BEP-4." The number might change if someont else proposes another BEP that becomes number 4.

## Rationale

The immediate reason for writing this BEP was that a new BigchainDB consortium was starting and there were questions about what they should do about the illegal data should it show up on their computers somehow. Some were seriously wondering what they were getting themselves into.

## The Illegal Data Response Plan

Here's what we reccommend a node operator do if they discover illegal data stored on their computer because it was stored there by BigchainDB:

1. Publicly announce that you've discovered illegal data on your computer and that you are following the **Illegal Data Response Plan** spelled out here. You can link to this page. The process now begins. You are acting responsibly. The law will give you a a reasonable amount of time to act. (Unless you are in some really sucky jurisdiction. Use discretion. This should be okay in modern "Western" countries.)
1. Inform all other members of the BigchainDB consortium where your node is a cluster member. Tell them to follow the same plan.
1. Contact BigchainDB GmbH at contact@bigchaindb.com or some other way. Employees tend to have an email like firstname@bigchaindb.com. This is like [the Bat-Signal](https://en.wikipedia.org/wiki/Bat-Signal). You need their help. They will help. They don't want you to get in trouble with the law either! That would be bad for BigchainDB. (Note: You don't _have_ to contact BigchainDB if you have developers who are competent to the next step without help.)
1. The BigchainDB team (or your team) will work with you create a modified version of BigchainDB Server (software) that is okay with certain specific data being deleted. This the core magic bit. It means that soon you will be deleting data and breaking the "immutability rule" but there's _nothing_ that was stopping you from doing that before. You could always delete data, but it would have broken BigchainDB. Unless BigchainDB was modified not to care, which is what's now happening!
1. Upgrade BigchainDB Server on your node to run the new version.
1. Delete the illegal data.
1. [There's no place like home.](https://www.youtube.com/watch?v=ooM-RGUTe2E)

Optional follow-up: a _second_ version of BigchainDB Server that will only believe the new situation, with the illegal data deleted is okay. The old situation, with the illegal data still there, should register as an error. Upgrade to that. 

## Your Expected Response

"But BigchainDB is supposed to be immutable. This breaks immutability!"

Yes. And it gets you out of trouble with the law. You'll notice it's not easy to do deletion. You can't just delete data without BigchainDB complaining. You have to do something special to make it not complain first.

## Things that Won't Work

There are a lot of things that don't work. That's what the rest of this BEP is about: to convince you that those other ways will still land you in trouble with the law.

### Fiter Incoming Data!

There's no way to detect all illegal data, not even using the best classifiers (Machine Learning) in the world. There are all kinds of tricks to fool classifiers. Like [Steganography](https://en.wikipedia.org/wiki/Steganography). Illegal data will get by. Now what?

That said, it wouldn't hurt to have some basic filters ("sanity checks") on incoming data, to make sure it conforms to what you're expecting. That's useful for other reasons, but don't expect it to stop illegal data.

### Allow Only Encrypted Data!

If the incoming it _is_ encrypted (and there is some way to check, which there isn't, but I digress), it's not legal to store illegal data, even if it's encrypted. Actually, that hasn't been decided in many jurisdictions, but are you really going to wait around for the courts to decide if you're breaking the law. What if they decide you are?

Anyway, there's a worse problem. Here's a thought experiment:

> Joe Criminal uploads some encrypted illegal data to your node somehow. Then he uploads _the decryption key_. Now anyone can get the encrypted illegal data and the decryption key and it's as if the data was never encrypted. They can get the unencrypted illegal data.

### Allow Only Hashed Data!

(There might be a way to make this work, but how _depressing_ if the only thing you are allowed to store is hashes!) To first order, if you allow arbitrary hashes to come in, then here's your thought experiment of how to use that to upload illegal data:

> Joe Criminal takes his illegal data file. You can think of it as a sequence of zeroes and ones. Now he starts sending each zero and one, one at a time. It's a zero if the hash (as binary) starts with 0, and 1 otherwise. This is slow but will work as a proof of concept. You could speed this up, but the result is the same: allowing arbitrary hashes is like allowing arbitrary data, over time.

Exercise for the reader: what could you do to prevent the above technique? There's a way. It's fun.

### Make the BigchainDB Network Fully Private!

What if you just prevent anyone from writing to the network except for, say, the node operators themselves. Surely that would keep the bad guys out? Nope. You need to start thinking more like a criminal!

Again, here's a thought experiment:

> Joe Criminal breaks into the office of Node Operator Susan at 3:00 am. He uses one of those things to make a nice circle in the glass, like in the movies. Or something. Anyway, he gets in. He sits at Susan's computer, he turns it on, enters the password from the sticky note on the montior, and he's in. (Maybe he got the password some other way, like social engineering. It's not that hard to make someone believe you need their password, or to trick them into telling it to you.) Now he uploads some illegal data because Susan's computer thinks he is Susan who has access. Done.

Read [_The Art of Deception: Controlling the Human Element of Security_](https://www.amazon.com/Art-Deception-Controlling-Element-Security/dp/076454280X), by by Kevin Mitnick, Wiley, 2003. 

"People always make the best exploits. I've never found it hard to hack most people. If you listen to them, watch them, their vulnerabilities are like a neon sign screwed into their heads." - [Elliot](https://youtu.be/32VKyY4ymvc?t=1m5s), _Mr. Robot_


### Make the BigchainDB Network Fully Public!

Bitcoin and Ethereum are public networks and they haven't had problems with illegal data. Make BigchainDB a public, permissionless network like that! All nodes are anonymous! There would be nobody to go after!

It won't work, but this one is more subtle to explain.

First of all, it's just a matter of time until someone does upload illegal data to the Bitcoin or Ethereum blockchains. It just hasn't happened yet. You'll know when it happens. It will be on the news.

Everyone hosting a Bitcoin or Ethereum full node will have a full copy of the illegal data and therefore will be acting illegally. They will all become criminals. Maybe they aren't caught yet, but do you think Tim the university student is going to continue running a Bitcoin full node if it risks him going to jail rather than graduating and marrying his fiancee in June? No, he is not. He's smart. He will shut down his node.

Only actual outlaws, scofflaws and crazy liberarians will be left hosting nodes. Also Chinese miners who don't give a shit and are all making money for their local government officials and themselves.

In America and Europe, people know who of their friends has crypto nodes. There won't be any hiding. Bitcoin and Ethereum people tend to be well-known. They chat on Twitter and go to events. The authorities would have no trouble finding them, and if they continue to run nodes, they will get in trouble. The whole anonymity thing is an illusion.

Why hasn't someone uploaded illegal data to Bitcoin or Ethereum already?

- It’s considered a taboo topic in the blockchain world, so people tend not to think about it in general.

- Nobody with significant investment in those networks will want to bring it up, or do it, and risk their investment.

- The people developing the software to implement permissionless networks are caught up in the fun technical questions, and not spending much time pondering legal questions. Even if they do think about legal questions, they say, “I am not a lawyer. I am not qualified.” They assume that the lawyers have thought about the legal questions and decided that everything is okay. The fact is, everyone knows about certain basic laws so they don’t get in trouble, and that’s all that’s needed here. For example, you don’t need a law degree to know that you can’t steal headphones from an Apple Store. A software developer can’t say, “I just wrote the software to control the headphone-stealing drone. I’m not a lawyer, so I’m not qualified to comment on whether it’s legal to use my software.”

- It’s quite expensive to write a lot of data to those blockchains. Something like tens of millions of US dollars per Gigiabyte. Not free!

- A law-abiding person would be reluctant to store some illegal data (e.g. in Bitcoin `OP_RETURN` slots), because they’d have to have some first, before they can store it elsewhere, and that’s illegal. They might consider doing it anonymously, but it’s not easy to be anonymous online, so why risk it?

### Erasure Coding!

[Erasure coding](https://en.wikipedia.org/wiki/Erasure_code) is pretty neat. You can take a file and break it into 30 pieces, for example, so that any ten of the pieces are needed to reconstruct the original file. It's hard to believe that's possible. But it is. Math is cool. Data centers use erasure coding to save money.

Even better, each piece is useless by itself. Just useless noise. It's like there's nothing there. No way you'll get in trouble for storing those pieces, am I right?

Maybe not! For example, it's in some places it's illegal to carry a gun, but it's also illegal to carry _gun parts_. This depends on the legal jurisdiction, of course. But the idea is that even though a piece isn't dangerous by itself, it's _still illegal_. A lawyer could make an analogy to convince a judge or jury that a piece of an illegal file is similarly illegal.

Maybe someday erasure coding could be used, but for now the legal question isn't decided yet, so why risk it?

### There Must Be a Way!

Please share! If there is, and it works, that would be awesome.

I wouldn't be surprised if some cryptographers figure out some great tricks, but I'm not from that world and I can't guess what they might do. I know it's just math, and math can be used to do amazing things, so there is hope! (My first dergree was in math, and physics.)

Meanwhile, we've got to do something _today._


## Why Now?

Why didn't we publish this sooner? I actually proposed an idea like this over a year ago, and Trent (my brother, and our CTO) liked it. We're both former Canadian farmboys who grew up raising pigs together and are very practical.

We told the idea to some of our work colleagues (who will remain nameless), and they _hated it_. "Blockchains are supposed to be immutable!" they said. "Do this and BigchainDB won't be a blockchain anymore!"

So we dropped it. Maybe we are too nice. Dogmatism got in the way of pragmatism. Well, pragmatism is back.

## Copyright Waiver

_To the extent possible under law, the person who associated CC0 with this work_ (Troy McConaghy, editor) _has waived all copyright and related or neighboring rights to this work._

## The Process to Change this BEP

There's a process to change this BEP. It's the same for all BEPs. See [2/COSS](https://github.com/bigchaindb/BEPs/tree/master/2).
