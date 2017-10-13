pragma solidity ^0.4.13;

import "./Crowdsale.sol";

contract StormCrowdsale is Crowdsale {
  function StormCrowdsale() public {
    communityRoundStartDate = 1508504400;   // Oct 20, 2017 @ 6am PST
    crowdsaleStartDate = 1508590800;        // 24 hours later
    crowdsaleEndDate = 1511182800;          // Nov 20, 2017 @ 6am PST

    ethToTokenConversion = 26950;           // 1 ETH == 26,950 STORM tokens

    maxTokenSupply = 10000000000;           // 10,000,000,000
    companyTokens = 6775292318;             // allocation to company, private presale and users (marketing)
    maxTokenSupply -= companyTokens;        // reduce token supply after company allocation

    maxCommunityRoundCap = 945000000;       // without 15% bonus of 141,750,000
    maxCrowdsaleCap = 3114132901;           // tokens allocated to crowdsale 
    maxContribution = 100;                  // maximum contribution during community round

    /******** WARNING DO NOT DEPLOY ********/
//    multisigAddress = 0x180cbd8a4e227d9a7ac9b91f75c3004cab187b6a;   // TODO: SET A VALID WALLET ADDRESS OWNED BY CAKECODES
//    token = IToken(multisigAddress);
  }
}
