```
shortname: BEP-22
name: Proxy Re-Encryption Demo 1
type: Standard
status: Raw
editor: Troy McConaghy <troy@bigchaindb.com>
contributors: Gautam Dhameja <gautam@bigchaindb.com>, Aram Jivanyan <aram@skycryptor.com>
```

# Abstract

This BEP outlines code that could be written as an initial demo of how one can use proxy re-encryption with BigchainDB.

# Motivation

Potential BigchainDB users often ask about how they can keep some data private, or private-for-some. There are many options. One useful building block is _proxy re-encryption_. It would be nice if there was some example code (with documentation) showing a way to use proxy re-encryption with BigchainDB.

# Cryptographic Background

## Symmetric Encryption

Symmetric or secret key encryption algorithms are comprised of two different algorithms called Encrypt and Decrypt. These algorithms are fast and can be used for securing large volumes of data. Both these algorithms use the same secret key K for operating over the data in the following way. 

    C = Encrypt_sym(K, D)
    D = Decrypt_sym(K, C)

Here D is the plaintext data, K is the secret key, commonly referred to as Data Encryption Key, and C is the ciphertext.
An example of a symmetric encryption algorithm is the AES (Advanced Encryption Standard) algorithm. 

## Asymmetric Encryption

While symmetric encryption algorithms are very fast, their require a common secret key K shared among the participants. 
Another cryptographic primitive called Asymmetric Encryption or Public-Key Encryption (PKE) enables you to securely exchange information between different parties without the need of any shared secret.

In the Public Key Encryption setup, every participant has a pair of keys: a public key PK and a secret key sk. Note: The secret key is sometimes called the private key. If Alice’s key pair is (PKA, skA), then anyone can use Alice’s public key PKA to encrypt a message for her, and Alice can decrypt it with her secret key skA. 
			
    C = Encrypt_pke(PKA, D)
    D = Decrypt_pke(skA, C)

Symmetric and Asymmetric cryptosystems can be combined to form a Hybrid system, which enables encrypting large volumes of data and  securely managing the common data encryption key exchange process. Assuming all participants have a pair of keys, the hybrid cryptosystem encryption flow for Alice is the following:

    K = generate_random_data_encryption_key()
    C = Encrypt_sym(D, K)
    Key_Capsule_A = Encrypt_pke(PKA, K)
    Return C || Key_Capsule_A

Here Key_Capsule_A is the data encryption key K encrypted with Alice’s public key. 
This capsule can be decrypted (or decapsulated) to reveal the data encryption key K using Alice’s secret key skA. The data decryption flow for Alice is the following:

    K = Decrypt_pke(Key_Capsule_A, skA)
    D = Decrypt_sym(C, K)

Hereafter, we will use the words Ciphertext and Capsule to refer to the symmetric-key-encrypted message and public-key-encrypted message accordingly.
 
## Proxy Re-Encryption

Proxy Re-Encryption is a new type of public key cryptography which enables a semi-trusted third party service called a proxy to take the capsules encrypted under first public key and transform them to capsules encrypted under the second public key without learning any information about the underlying message. 

# Why Proxy Re-Encryption with BigchainDB?

Suppose Dan owns some data D and wants to share it, but only selectively, and he doesn’t know who all he will share it with ahead of time.

He’d start by encrypting his data with (fast) symmetric encryption, i.e. with a randomly-generated secret key K. He probably wouldn’t store the encrypted data C in a BigchainDB network, since blockchains in general are an expensive place to store data. He’d store the encrypted data elsewhere.

He’d then encrypt the secret key K with his public key PKD (i.e. using asymmetric encryption) and store the encrypted key (key capsule) Key_Capsule_D in a BigchainDB network.

Next, to give Megan access to the encrypted data, Dan could encapsulate the data encryption key using Megan's public key and store the capsule in a BigchainDB network. Then Megan could decapsulate (decrypt) it with her private key, and nobody else could decrypt it. To provide access to Todd, Dan would have to encapsulate the key a second time, using Todd's public key, and he'd have to store _that_ capsule (for Todd) in a BigchainDB network too!

This is not a scalable approach in the case of multiple recipients. Another drawback of this method is it requires Dan to be online and perform cryptographic operations every time new access should be granted. This significantly limits how the encrypted data can be shared or accessed.

Dan would like to store just one ciphertext (key capsule) in BigchainDB, and he'd also like to give selective access to recipients in the future, as needed. Proxy re-encryption is one way to enable that, but it would be nice to have some code demonstrating _how_.

# Specification

The code developed for this BEP/demo must work with [Skycryptor's](http://skycryptor.com/) code for proxy re-encryption. (Note: That code is written in C++ but has Python bindings.)
Skycryptor Proxy Re-Encryption libraries provide the following functionality:

- **Key Generation:** Generates and returns a pair of secp256k1 public and private keys.
- **Encapsulate:** Takes a secp256k1 public key _PK_ and returns a randomly generated data encryption key _K_ and a _capsule_, which encapsulates this key with the _PK_. This function combines the two operations of generating a random data encryption key and encapsulating it with the given public key into one.
- **Decapsulate:** Takes as parameters a _capsule_ and secp256k1 private key _sk_ and decapsulate it to reveal the data encryption key _K_.
- **Re-Encryption Key Generation:** Takes an secp256k1 private key _sk1_, an secp256k1 public key _PK2_, and returns a re-encryption key _re_encryption_key_user1_user2_.
- **Re-Encrypt:** Takes a _capsule1_ encapsulated with the public key _PK1_, and a re-encryption key _re_encryption_key_user1_user2_, and returns a transformed _capsule2_, which later can be decapsulated by the second user's private key _sk2_. 

All the changes to the drivers (described below) should be implemented in the Python Driver first.

"BigNet" is the name of a BigchainDB network that is set up by whoever does this demo.

## A Usage Story

To understand the required software and what it must do, we wrote this sample user story:

- Dan is a data owner.
- Dan generates an ed25519 key-pair for signing and verifying BigchainDB-related things.
- Dan generates an secp256k1 key-pair for encapsulating and decapsulating messages (data encryption keys).
- Dan prepares and signs a BigchainDB CREATE transaction to associate his two public keys:

  - `inputs[0].owners_before[0]` = Dan's ed25519 public key (verifying key)
  - `asset.data.type` = "public key linker"
  - `asset.data.secp256k1_public_key` = Dan's secp256k1 public key

Note: Skycryptor expects secp256k1 keys to be hex-encoded using (unlike the ed25519 keys, which BigchainDB expects to be encoded using Python/Bitcoin’s version of Base58.)

- Dan posts that transaction to BigNet.
- Dan uses Skycryptor’s _Encapsulate_ method to generate a symmetric encryption key K and capsule_1 which encapsulates K with Dan’s secp256k1 public key.
- Dan uses the symmetric encryption key K to encrypt message_1 via some symmetric encryption algorithm (such as AES). The result is ciphertext_1.
- Dan stores ciphertext_1 somewhere (maybe in BigNet, maybe elsewhere).
- Dan prepares and signs a BigchainDB CREATE transaction to store capsule_1:

  - `inputs[0].owners_before[0]` = Dan's ed25519 public key (verifying key)
  - `asset.data.type` = "capsule storage"`
  - `asset.data.capsule` = capsule_1
  - `asset.data.capsule_digest` = capsule_1_hash	

- Dan posts that transaction to BigNet.
- Megan wants to read message_1 (or actually, _any_ message encrypted using Dan’s secret key K).
- Megan generates an secp256k1 keypair.
- Megan generates an ed25519 key pair. (Although Megan could be identified by her secp256k1 public key only, her ed25519 signing key will be used to sign her "access request" transaction.)
- Megan prepares and signs a "public key linker" transaction (analogous to Dan’s) and posts it to BigNet.

Access Requests

- Megan prepares and signs an "access request" transaction to request permission to read message_1, a BigchainDB CREATE transaction with:

  - `inputs[0].owners_before[0]` = Megan’s ed25519 public key
  - `asset.data.type` = "access request"
  - `asset.data.transaction_id` = The transaction ID of Dan’s "capsule storage" transaction, i.e. the one storing capsule_1
  - `outputs[0].public_keys[0]` = Dan’s ed25519 public key
  - `outputs[0].condition.details.type` = "ed25519-sha-256"
  - `outputs[0].condition.details.public_key` = Dan’s ed25519 public key

(In other words, Megan is the creator of the asset but she immediately gives ownership to Dan, right in the initial CREATE transaction. From then on, Dan will stay the owner and will grant and revoke Megan’s access using a sequence of TRANSFER transactions involving that asset.)

- Megan posts that transaction to BigNet.
- Somehow (TBD), Dan finds out about Megan’s "access request" transaction. (For example, maybe Dan is subscribed to the BigchainDB events API and is looking for "access request" transactions relevant to him.)
- If Dan is okay with Megan getting his secret key K, then he prepares and signs a TRANSFER transaction with:

  - `inputs[0].owners_before[0]` = Dan’s ed25519 public key
  - `asset.id` = Transaction ID (asset ID) of Megan’s "access request" transaction
  - `metadata.access_allowed` = True
  - `outputs[0].public_keys[0]` = Dan’s ed25519 public key
  - `outputs[0].condition.details.type` = "ed25519-sha-256"
  - `outputs[0].condition.details.public_key` = Dan’s ed25519 public key

- If Dan is not okay with Megan's request, then he prepares and signs a similar TRANSFER transaction, except with `metadata.access_allowed` = False
- Dan posts that transaction to BigNet.
- Note how Dan can revoke or grant access by spending/transferring the unspent output on that TRANSFER transaction, and so on. To determine the current access status of a particular access request, one must find the _last_ TRANSFER transaction involving that asset, i.e. the one with the unspent output, and check the value of `metadata.access_allowed`.

- If Megan is supposed to get access, then Dan generates a special re-encryption key denoted as re_encryption_key_dan_megan by using Skycryptor's Re-Encryption Key Generation function. This step is performed on Dan's device using Dan's secp256k1 private key and Megan's secp256k1 public key.
- Dan sends this _re-encryption_dan_megan_ key to the Proxy Service along with other auxiliary data. (Note: The Proxy Service should provide a special API enabling  Dan to make a POST requests.)

  - `data.delegator_id` = Dan's secp256k1 public key
  - `data.delegatee_id` = Megan's secp256k1 public key
  - `data.re_encryption_key` = re_encryption_key_dan_megan
  - `data.signature` = Re-Encryption Record Signature

Note: The Re-Encryption Record Signature is the signature of the message (data.delegator_id || data.delegatee_id || data.re_encryption_key) encoded to bytes. It’s signed using Dan’s ed25519 private (signing) key. Here the symbol || means string concatenation.

- The Proxy Service checks the signature, and if it’s valid, it stores this record in a private local database (only accessible to the Proxy Service). 
- Once the re-encryption key is created by Dan for Megan, the Proxy Service will be able to serve Megan's re-encryption requests. 
- The Proxy Service will provide an API for re-encryption requests. Each re-encryption request will contain the following information:

  - `data.capsule` = capsule_1 OR (the BigchainDB transaction ID of the transaction containing capsule_1)
  - `data.requesting_user_id` = Megan's secp256k1 public key 
  - `data.request_signature` = Request signature

Note: The request signature is the signature of the message (data.ciphertext || data.requesting_user_id) encoded to bytes. It’s signed using Megan’s ed25519 private (signing) key. || means string concatenation.

- When the Proxy Service gets a re-encryption request from Megan (as above), it checks the signature to make sure it’s valid. If it is, it checks in BigNet to make sure Megan has access (granted by Dan, signed by Dan). (The logic to determine if Megan has access was outlined above.)
- If Megan is allowed to read K, the Proxy Service takes capsule_1 from BigNet and re_encryption_key_dan_megan from its private database. It then performs a _ReEncrypt_ operation, which transforms capsule_1 into capsule_2. The resulting capsule_2 is encapsulated under Megan's secp256k1 public key.
- The Proxy Service sends capsule_2 to Megan in the response to her re-encryption request.
- Megan decapsulate the capsule_2 into the secret key K, which she can use to decrypt any message that Dan encrypted using K (including message_1).

## Ideas for Future Enhancements

- Add more information to "public key linker" transactions, such as an `asset.data.public_id` to store another public identifier, such as an email address.
- The transaction associating the ed25519 and secp256k1 public keys might be modified so that it better conforms with some standard such as [Decentralized Identifiers (DIDs)](https://w3c-ccg.github.io/did-spec/). At a minimum, it must contain those two public keys and it must be signed by the corresponding ed25519 private (signing) key.

# Change Process

BigchainDB GmbH has a process to improve BEPs like this one. Please see [BEP-1 (C4)](../1) and [BEP-2 (COSS)](../2).

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
