pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/StormCrowdsale.sol";

contract TestStormCrowdsale {

  function testOwnerAddress() {
    StormCrowdsale stormSale = new StormCrowdsale();

    address expected = 0x180cbd8a4e227d9a7ac9b91f75c3004cab187b6a;

    Assert.equal(stormSale.multisigAddress(), expected, "check owner address");
  }

  function testTokenSold() {
    StormCrowdsale stormSale = new StormCrowdsale();

    uint expected = 0;

    Assert.equal(stormSale.tokenSold(), expected, "check tokens sold at contract deployment");
  }

  function testCrowdsaleStateStart() {
    StormCrowdsale stormSale = new StormCrowdsale();

    uint expected = 1;

    Assert.equal(stormSale.getCrowdsaleState(), expected, "check crowdsale state");
  }

  function testDefaultVariables() {
    StormCrowdsale stormSale = new StormCrowdsale();

    uint expected_communityRoundStartDate = 1508504400;
    uint expected_crowdsaleStartDate = 1508590800;
    uint expected_crowdsaleEndDate = 15111182800;

    uint expected_ethToTokenConversion = 26950;
    uint expected 
  }

/*
  function testMaxTokenSupply() {
    StormCrowdsale stormSale = new StormCrowdsale();

    uint expected = 3224707682;

    Assert.equal(stormSale.maxTokenSupply(), expected, "check maximum token supply");
  }
  */
}
