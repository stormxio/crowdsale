pragma solidity ^0.4.13;

import "./Crowdsale.sol";

contract StormCrowdsale is Crowdsale {
  function StormCrowdsale() public {
    communityRoundStartDate = 1508504400;   // Oct 20, 2017 @ 6am PST
    crowdsaleStartDate = 1508590800;        // 24 hours later
    crowdsaleEndDate = 1511182800;          // Nov 20, 2017 @ 6am PST

    ethToTokenConversion = 26950;           // 1 ETH == 26,950 STORM tokens

    maxTokenSupply = 10000000000;           // 10,000,000,000
    companyTokens = 5799117100;             // allocation to company, private presale and users (marketing)
    maxTokenSupply -= companyTokens;        // reduce token supply after company allocation

    maxCommunityRoundCap = 945000000;       // without 15% bonus of 141,750,000
    maxCrowdsaleCap = 3114132900;           // tokens allocated to crowdsale 

    maxEthCap = 206295;                     // maximum ETH to raise
    maxContribution = 100;                  // maximum contribution during community round
  }
}
