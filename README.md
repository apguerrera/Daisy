# DAISY - A decision gadget for DAI

Voting is notoriously hard. Ideally, everyone wants the option to be able to vote, without revealing who they voted for. At the same time, we want to trust our vote was counted and have full transparency in the final outcome. These two ideas are fundamentally opposed.

At the same time, trust in a system is needed for the validity of the decisions to hold. If everything is transparent and verifiable, then I can be bribed or sell my vote to the highest bidder.

### Zero Knowledge to the Rescue!

Not really. 

An interesting example is the attach on MolochDAO called SelloutDAO. Someone made a contract that worked like a voting vending machine, where for the price of 1ETH, anyone can control a huge chunk of the voting power and vote themselves in.

### Solving Sellouts
The only way to avoid this is to be able to vote multiple times. (Ignoring the fact that zcash vote transfers or tornado cash mixers dont allow you to double spend) No one is going to waste any amount of money on a vote that can be changed. Would you spend money if it could be swapped? 


### SuperSelloutDAO
Ok so now you voted three times, I saw on the blockchain you cheated me!! Until someone in the future makes SuperSelloutDAO, where you have to wait until the vote ends before claiming your reward. 
It gets even worse when the stakes are high when coercion is involved and people are watching accounts online for disobedience. Timing analysis gets involved with deanoymising tornado vote mixers. Now there has to be a way to prevent sell outs in your DAO, but how to do that securely, and if possible privately, where it’s not possible to see if or what you voted for, but also if you have changed your vote or not.  


## The Solution
#### Add a pin number. 
It is as simple as that. 

Under the covers, sure there is some fancy cryptography, but it doesn’t need to be more complicated than that. If for whatever reason, say you had a lot of MKR and were asked to vote one way or worse, coerced to do so, you can simply use a dummy pin. It will still work, they would never know, it just won’t be counted by Maker. 
Everything on-chain is encrypted, so neither your preference nor its validity can be checked by anyone else. There is also proof that Maker counted every message just to be sure.   

#### Multiple Voting
In reality, the real magic about Daisy is not in its pin, but its ability to broadcast multiple times, some of which can be decrypted as eligible Votes. 
In systems built with Daisy make collusion among participants difficult while retaining the censorship resistance and correct-execution are benefits of smart contracts. Although Daisy can provide collision resistance only if the coordinator is honest, a dishonest coordinator neither censors any of one message. nor tamper with the execution of the final tally.
