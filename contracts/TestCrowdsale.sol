pragma solidity ^0.4.13;

import "./Crowdsale.sol";

contract TestCrowdsale is Crowdsale {
  function TestCrowdsale() public {
    communityRoundStartDate = now;   
    crowdsaleStartDate = communityRoundStartDate + 1 hours;
    crowdsaleEndDate = crowdsaleStartDate + 4 hours;

    crowdsaleState = state.communityRound;

    ethToTokenConversion = 1;

    maxTokenSupply = 10.3 ether;
    companyTokens = 5 ether;             // allocation to company, private presale and users (marketing)

    maxCommunityWithoutBonusCap = 2 ether;
    maxCommunityCap = 2.3 ether;
    maxCrowdsaleCap = 3 ether;

    maxContribution = 1 ether;                  // maximum contribution during community round
  }
}
