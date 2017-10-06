pragma solidity ^0.4.13;

import "./Crowdsale.sol";

contract StormCrowdsale is Crowdsale {
  function StormCrowdsale() {
    presaleStartBlock; //TODO: set block
    crowdsaleEndedBlock; //TODO: set block

    ethToTokenConversion = 26950;       // 1 ETH == 26,950 STORM tokens

    maxTokenSupply = 10000000000;       // 10,000,000,000
    maxCommunityRoundCap = 945000000;   // without 15% bonus of 141,750,000
    
    maxCrowdsaleCap = 2137957682; 
    maxContribution = 350;              // maximum contribution during community round is ~$100,000 USD

    uint256 companyTokens = 6775292318; // allocation to company, private presale and users (marketing)
    maxTokenSupply = maxTokenSupply.sub(companyTokens);     // reduce token supply after company allocation
    token.mintTokens(msg.sender, companyTokens);            // allocate tokens to company and users for marketing
  }
}
