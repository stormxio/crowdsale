# STORM Crowdsale
This repository contains the smart contracts for the crowdsale of STORM tokens developed by [Rui Maximo](https://www.linkedin.com/in/maximo/) and co-authored by [Reo Shibatsuji](https://www.linkedin.com/in/reo-shibatsuji-a22716132/), recommendations provided by [Yudi Levi](https://www.linkedin.com/in/yudi-levi-4bb91911/). Test cases were developed by Reo Shibatsuji. 

Auditing of the smart contracts performed by the [HOSHO GROUP](https://hosho.io).

# Resources

Official Site: https://stormtoken.com

Link to 28x28png STORM icon: https://github.com/StormX-Inc/crowdsale/blob/master/images/LOGO.png

Official Contact Email Address: info@stormtoken.com

Link to blog: https://blog.stormtoken.com/

Link to reddit: https://www.reddit.com/r/stormtoken/

Link to facebook: https://www.facebook.com/stormtoken

Link to twitter: https://twitter.com/Storm_Token

Link to bitcointalk: https://bitcointalk.org/index.php?topic=2006999.msg21584885#msg21584885


# Architecture
The following diagram illustrates the design and dependencies between the smart contracts. 

![STORM smart contract architecture](https://github.com/StormX-Inc/crowdsale/blob/Gold/images/architecture.png)

# Smart Contract Design

The smart contracts are composed of two main smart contracts: StormCrowdsale and StormToken. 

The StormToken inherits from the Token, which is an ERC-20 smart contract that mints tokens and allows users to transfer tokens. The StormToken adds additional logic specific to Bancor and a bulk transfers function to make it easier to reward STORM PLAY users (previously BitMaker). Wallets such as Jaxx, MyEtherWallet (i.e. MEW) call the StormToken smart contract to show users how many STORM tokens they own.

The StormCrowdsale smart contract handles the logic of the Crowdsale, and becomes obsolete once the Crowdsale ends. When the StormCrowdsale smart contract is deployed, the initial state is PENDING until the Community Appreciation Period begins on Nov 7th, 2017 @ 6am PST (2pm UTC). 

There are 4 states:
1.  pendingStart
2.  communityRound
3.  crowdsaleStarted
4.  crowdsaleEnded

All participants must be registered in the StormCrowdsale contributor’s list regardless of whether they are approved for the community appreciation period or the crowdsale period. If they are registered (i.e. whitelisted), they can participate and purchase STORM tokens.

When the Community Appreciation Period starts, only registered participants approved for the Community Appreciation Sale Period can participate. All other participants attempting to send ETH to the StormCrowdsale will be rejected and refunded. 

A Community Appreciation Period approved participant can send any amount of ETH. If the participant sends more than 100 ETH (say 500 ETH), only 100 ETH worth of tokens plus the 15% bonus from the Community Appreciation Period will be minted, and the remaining ETH (i.e. 400 ETH) will be immediately applied to purchase Crowdsale tokens. The STORM tokens are minted immediately, but will be locked until the Crowdsale ends – meaning participants cannot transfer their tokens to another address. 

There are several mutually exclusive sub-scenarios:

•   If the Community Appreciation Period STORM tokens are sold out, then all of the participant’s ETH (i.e. 500 ETH) will be applied to purchasing Crowdsale tokens. 
•   If the Crowdsale period is sold out, then whatever is left over from buying Community Appreciation Period STORM tokens (i.e. 400 ETH) is refunded to the participant.

The StormCrowdsale smart contract changes state from Community Appreciation Sale Period to the Crowdsale period when one of the following conditions are met:

•   24 hours has elapsed from the start of the Community Appreciation Period (Nov 7th 2017 @ 6am PST).
•   All the Community Appreciation period STORM tokens (including the 15% bonus amount) are sold out.

This implies that the Community Appreciation period could last less than 24 hours, but no more than 24 hours. Should 24 hours elapse without selling out all the Community Appreciation period STORM tokens, then any remaining STORM tokens convert to be available as Crowdsale tokens and become eligible for purchase by any approved participant during the Crowdsale period at a 0% bonus rate.

When the StormCrowdsale smart contract enters the Crowdsale period, all approved participants (including Community Appreciation approved participants) are eligible to participate. 

During the Community Appreciation Period and Crowdsale Period, all transfers of tokens will be disallowed. The contract owner (i.e. CakeCodes Global SEZC, Inc.) manually unlocks token transfer at the end of the Crowdsale. At which point, participants can transfer their tokens as they please to another address.

As soon as the StormCrowdsale smart contract receives ETH from participants, it immediately transfers the ETH received to a company wallet address for security reasons.

The state of the StormCrowdsale changes from the Crowdsale period to ended when all STORM tokens are sold out or when 1 month and 12 hours have elapsed from the start of the Community Appreciation period (Crowdsale end date is Dec 7th, 2017 @ 6pm PST). If there are STORM tokens remaining after the Crowdsale end, the company (i.e. CakeCodes Global SEZC, Inc) can claim the remaining tokens.





Storm Play™, Storm Gigs™, Storm Market™, Storm Task™, StormX™ and STORM Token™ are trademarks (™) of CakeCodes Global SEZC, Inc.
