# DAISY - A decision gadget for DAI

Voting is notoriously hard. Ideally, everyone wants the option to be able to vote, without revealing who they voted for. At the same time, we want to trust our vote was counted and have full transparency in the final outcome. These two ideas are fundamentally opposed.

### Anonymity + Transparency

At the same time, trust in a system is needed for the validity of the decisions to hold. If everything is transparent and verifiable, then I can be bribed or sell my vote to the highest bidder.

#### The problem of Selling out

An interesting example is the attach on MolochDAO called SelloutDAO. Someone made a contract that worked like a voting vending machine, where for the price of 1ETH, anyone can control a huge chunk of the voting power and vote themselves in.

The only way to avoid this is to be able to vote multiple times. (Ignoring the fact that zcash vote transfers or tornado cash mixers dont allow you to double spend) No one is going to waste any amount of money on a vote that can be changed. Would you spend money if it could be swapped? 


#### SuperSelloutDAO
Ok so now you voted three times, I saw on the blockchain you cheated me!! Until someone in the future makes SuperSelloutDAO, where you have to wait until the vote ends before claiming your reward. 
It gets even worse when the stakes are high when coercion is involved and people are watching accounts online for disobedience. Timing analysis gets involved with deanoymising tornado vote mixers. Now there has to be a way to prevent sell outs in your DAO, but how to do that securely, and if possible privately, where it’s not possible to see if or what you voted for, but also if you have changed your vote or not.  


## The Solution
#### Add a pin number. 
It is as simple as that. 

![daisy pin](/docs/mkrpin.jpg "Daisy Pin")

Under the covers, sure there is some fancy cryptography, but for the users, it doesn’t need to be more complicated than that. If for whatever reason, say you had a lot of MKR and were asked to vote one way or worse, coerced to do so, you can simply use a dummy pin. It will still work, they would never know, it just won’t be counted by Maker. 
Everything on-chain is encrypted, so neither your preference nor its validity can be checked by anyone else. There is also proof that Maker counted every message just to be sure.   

#### Multiple Voting
In reality, the real magic about Daisy is not in its pin, but its ability to broadcast multiple times, some of which can be decrypted as eligible Votes. 
In systems built with Daisy make collusion among participants difficult while retaining the censorship resistance and correct-execution are benefits of smart contracts. Although Daisy can provide collision resistance only if the coordinator is honest, a dishonest coordinator neither censors any of one message. nor tamper with the execution of the final tally.


## Implementation
#### Create a voting contract. (Once by MakerDAO)
Replaces the existing proxy voting process with a new voting contract, except we will have some additional features in the smart contract to ensure coercion (bribery) resistant voting, powered by the MACI voting system. 

* Daisy will be using existing MKR proxy voting smart contracts.
It is generally considered a best practice to keep wallets that hold any significant value in cryptocurrency offline as much as possible, i.e. to use a “cold wallet”.

#### Deposit MKR (Users, exisiting process)
* To vote, MKR owners must “lock up” their tokens by transferring them to the voting system. Once transferred, they can then vote on different proposals with the weight of the MKR that is locked up.
* The voting proxy contract assures that MKR owners can vote with the full weight of the MKR they own, both for Governance voting and for Executive voting.

#### Add Privacy Pin (Users, New / optional)
* User adds 4 digit pin, signed by their hot wallet. 
* Signed pin is used as seed in MACI KeyGen for anonymous voting
* This pin can be changed at any time

#### Vote on proposals (Users)
* Vote normally. Enter your pin to vote anonymously
* Incorrect pin will succeed, but not be counted 
* No way for public to determine correctness of pin

#### Proof of Correctness (Submitted by MakerDAO)
* Votes are tallied and verified with a proof
* Circom circuit ensures every vote is counted, correctly
* Final vote count is commited and publicly verifiable


![daisy pin](/docs/daisypin.png "Daisy Pin")

## Demo 

#### View the demo videos.
https://photos.google.com/share/AF1QipNQyAW2YxNzll9R-E4DYOW6ppD-lr5bW2UOyPuVBH_1AvJOouVyq-SG1xp0vgEnxQ?key=Rl9aWWM2bWtHclN4cHA1QzlTR0hDYmJtQXNweTF3

#### Smart Contracts

#### Pin powered Maci KeyPair Generator (AWS Lambda / Temperamental)
https://studio.petyl.com/voting/daisy


## Features
#### No Secondary Keys or ZK-Notes
We use metamask to sign the pin number with your private key to generate a set of keys in your browser. No writing down Twisted Edward keypairs that only work in SNARKs, no copying and pasting ZK notes that are as good as gold in your compromised clipboard and saved to your machine. Everything happens using your private key, signing any 4 digit pin to generate a temporary key. If you use the same pin, will generate the same key next time. No complicated 3box implementation to store those zk keys or notes, nor explaining to your users what on earth they are doing or what is actually happening.

#### Wallet Agnostic:

We use metamask to generate the voting key pairs. In fact, it’s just signing a message, simple. No specific wallet or integration required, just sign a message. 
Our Solution will be using the existing wallet providers so there is no need of any Custom wallet or any other Plugins for the process. Votes are encrypted in the browser using standard crypto libraries, so again can be wallet agnostic.

#### Security

If you ever get worried that you have a huge stack of MKR and that people will force you to vote on a spell in the middle of the night, rest assured you can now vote with ease. You can vote as you normally would, just use the wrong pin, no one can prove that you did otherwise. You can also change your pin for extra peace of mine. We use the existing proxy voting contracts and add a layer of zero-knowledge proofs to ensure each vote can only ever be counted once, from valid votes. 

#### Trustworthy

Suppose that we have an application where we need collusion resistance, but we also need the blockchain’s guarantees (mainly correct execution and censorship-resistance). 
Voting is a prime candidate for this use case: collusion resistance is essential for the reasons, guarantees of correct execution are needed to guard against attacks on the vote tallying mechanism, and preventing censorship of votes is needed to prevent attacks involving blocking votes from voters. 

We can make a system that provides the collusion resistance guarantee with a centralized trust model (if Bob is honest we have collusion resistance, If Bob is dishonest we don’t), and also provides the blockchain’s guarantees unconditionally (ie. Bob can’t cause the other guarantees to break by being dishonest).


#### Transparent Anonymity

The smart contracts paired with proof systems continue to emerge as a developments of safer, cheaper, more secure, more transparent, and easier-to-use e-voting systems. An e-voting system must be secure, as it should not allow duplicate votes and be fully transparent while protecting the privacy of the attendees. 

In this work, we have implemented and tested a sample e-voting Daisy’s smart contract for the Ethereum using the Ethereum based MKR wallets using Solidity and Circom. User privacy was preserved by encrypting the votes and key changes. 
Users can submit their votes from their wallets, and these transaction requests are handled with the consensus of every single Ethereum node. MakerDAO acting as the coordinator also is required to submit a verifiable proof for correctness of computation. This consensus creates a transparent environment for e-voting. In this way, the transparency of the system will be kept intact while maintaining user privacy and anonymity.


#### Delegation
Delegation of votes is the most risk-laden aspect of digital voting, however, can be done in three ways with the Daisy framework. 

The simplest way would be to give away the hot wallet key and secretly communicate the voting pin to the delegate. You retain control as you can revoke access by transferring MKR back to the cold wallet, effectively resetting. This is not ideal for a number of communicating your private keys and security reasons, but possible and can be made more secure with some smart contract safeguards. This is inherent with any digital secret sharing scheme or zk note swapping that doesn’t involve some sort of MPC or encryption protocol. 
  
Daisy’s single proxy contract with pooled voting balances offer an alternative solution to private delegation. This can be via transferring balances into accounts, liquid democracy style, but privacy implications and non-voting issues need to be thought out further, but compatible with the Daisy framework. It sufferers slightly from relying on of proxy talliers, like most delegation schemes, but easily solved with reputation and/or economic incentives. This would be a balance transfer in the Daisy proxy voting contract and a state update in the Merkle tree which can be done privately. 

It can also be done with nested proxy contracts, where a delegate will have their own proxy contract, and you join their voting pool, instead of the MKR private voting pool (Daisy main contract) in a very meta-proxy way. This is nice as you can always vore directly on the spell using the main contract for issues you care about or leave the delegation for day to day votes. 


## Issues
#### Key selling attack
It doesn’t solve the issue that you could have sold your keys to someone else. How do I know it you who signed that transaction? For every solution, keep asking “How?” and it always leads to more questions. We settle for if you signed with your private key, and the correct pin, it is most probably you. Only Vitalik has come close to thinking through this issue. 

#### Trusted Setup
We used SNARKs generated by the /circom-library.
Trusted setup is required - Currently underway for Semaphore, simple process with community participation.  Universal setups are being developed which will avoid this have been developed and are waiting for use-cases such as MKR voting to make this a reality. Proof systems being devloped include Starks, Halo, Sonic, Plonk and an explosion of others have emerged to choose from. 
