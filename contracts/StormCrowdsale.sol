pragma solidity ^0.4.13;

import "./Crowdsale.sol";

contract StormCrowdsale is Crowdsale {
    string public officialWebsite;
    string public officialFacebook;
    string public officialTelegram;
    string public officialEmail;

  function StormCrowdsale() public {
    officialWebsite = "https://www.stormtoken.com";
    officialFacebook = "https://www.facebook.com/stormtoken/";
    officialTelegram = "https://t.me/joinchat/GHTZGQwsy9mZk0KFEEjGtg";
    officialEmail = "info@stormtoken.com";

    communityRoundStartDate = 1510063200;                       // Nov 7, 2017 @ 6am PST
    crowdsaleStartDate = communityRoundStartDate + 24 hours;    // 24 hours later
    crowdsaleEndDate = communityRoundStartDate + 30 days + 12 hours; // 30 days + 12 hours later: Dec 7th, 2017 @ 6pm PST [1512698400]

    crowdsaleState = state.pendingStart;

    ethToTokenConversion = 26950;                 // 1 ETH == 26,950 STORM tokens

    maxTokenSupply = 10000000000 ether;           // 10,000,000,000
    companyTokens = 8124766171 ether;             // allocation for company pool, private presale, user pool 
                                                  // 2,325,649,071 tokens from the company pool are voluntarily locked for 2 years

    maxCommunityWithoutBonusCap = 945000000 ether;
    maxCommunityCap = 1086750000 ether;           // 945,000,000 with 15% bonus of 141,750,000
    maxCrowdsaleCap = 788483829 ether;            // tokens allocated to crowdsale 

    maxContribution = 100 ether;                  // maximum contribution during community round
  }
}
