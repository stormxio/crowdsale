# STORM Crowdsale
This repository contains the smart contracts for the crowdsale of STORM tokens developed by Rui Maximo and co-authored by Reo Shibatsuji, recommendations provided by Yudi Levi. Test cases were developed by Reo Shibatsuji. 

Auditing of the smart contracts performed by the HOSHO GROUP (https://hosho.io).

# Smart Contract Design

The smart contracts are composed of two main smart contracts: StormCrowdsale and StormToken. 

The StormToken inherits from the Token, which is an ERC-20 smart contract that mints tokens and allows users to transfer tokens. The StormToken adds additional logic specific to Bancor and a bulk transfers function to make it easier to pay out STORM PLAY users (previously BitMaker). Wallets such as Jaxx, MyEtherWallet (i.e. MEW) call the StormToken smart contract to show users how many STORM tokens they own.

The StormCrowdsale smart contract handles the logic of the crowdsale, and becomes obsolete once the crowdsale ends. When the StormCrowdsale smart contract is deployed, the initial state is PENDING until the community appreciation period begins on Nov 7th, 2017 @ 6am PST. 

There are 4 states:
1.  pendingStart
2.  communityRound
3.  crowdsaleStarted
4.  crowdsaleEnded

All participants must be registered in the StormCrowdsale contributor’s list regardless of whether they are approved for the community appreciation period or the crowdsale period. If they are registered (i.e. whitelisted), they can participate and purchase STORM tokens.

When the community appreciation period starts, only registered participants approved for the community appreciation can participate. All other participants attempting to send ETH to the StormCrowdsale will be rejected and refunded. 

A community appreciation approved participant can send any amount of ETH. If the participant sends more than 100 ETH (say 500 ETH), only 100 ETH worth of tokens plus the 15% bonus from the community appreciation period will be minted, and the remaining ETH (i.e. 400 ETH) will be immediately applied to purchase crowdsale tokens. The tokens are minted immediately, but will be locked until the crowdsale ends – meaning users cannot transfer (i.e. sell) their tokens. 

There are several mutually exclusive sub-scenarios:

•   If the community appreciation tokens are sold out, then all of the user’s ETH (i.e. 500 ETH) will be applied to purchasing crowdsale tokens. 
•   If the crowdsale period is sold out, then whatever is left over from buying community appreciation tokens (i.e. 400 ETH) is refunded to the user.

The StormCrowdsale smart contract changes state from community appreciation period to the crowdsale period when one of the following conditions are met:

•   24 hours has elapsed from the start of the community appreciation period (Nov 8th 2017 @ 6am PST).
•   All the community appreciation tokens (including the 15% bonus amount) are sold out.

This implies that the community round could last less than 24 hours, but no more than 24 hours. Should 24 hours elapse without selling out all the community appreciation tokens, then any remaining tokens convert to crowdsale tokens and become eligible for purchase by any approved participant during the crowdsale period at a 0% bonus rate.

When the StormCrowdsale smart contract enters the crowdsale period, all approved participants (including community appreciation approved participants) can participate. 

During the community appreciation period and crowdsale period, all transfers of tokens will be disallowed. The contract owner (i.e. CakeCodes Global SEZC, Inc.) manually unlocks token transfer at the end of the crowdsale. At which point, users can transfer their tokens as they please.

As soon as the StormCrowdsale smart contract receives ETH from users, it immediately transfers those funds to a company wallet address for security reasons.

The state of the StormCrowdsale changes from the crowdsale period to ended when all tokens are sold out or 1 month and 12 hours have elapsed from the start of the community appreciation period (Dec 7th, 2017 @ 6pm PST). If there are tokens remaining after the crowdsale end, the company (i.e. CakeCodes Global SEZC, Inc) can claim the remaining tokens.


