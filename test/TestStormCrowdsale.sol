pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/StormToken.sol";
import "../contracts/StormCrowdsale.sol";

contract TestStormCrowdsale {

/*
  function testInitialState() {
    uint _expected = 0;

    StormCrowdsale.deployed().then(function(instance) {
      _crowdsale=instance;
      console.log(StormToken.deployed().address);
    });

    Assert.equal(_crowdsale.tokenSold(), _expected, "check tokens sold at contract deployment");
    Assert.equal(stormSale.ethRaised(), _expected, "check ETH raised at contract deployment");
  }
  */

  function testBuyingTokens() {
    uint _expected = 1;
    StormCrowdsale _crowdsale = StormCrowdsale(DeployedAddresses.StormCrowdsale());

    _crowdsale.send(1);

    Assert.equal(_crowdsale.ethRaised(), _expected, "check buying tokens");
  }
}
