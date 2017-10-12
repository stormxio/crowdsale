var Token = artifacts.require("./Token.sol");
var StormToken = artifacts.require("./StormToken.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");
var StormCrowdsale = artifacts.require("./StormCrowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(Token);
  deployer.link(Token, StormToken);
  deployer.deploy(StormToken);
  deployer.deploy(Crowdsale);
  deployer.link(Crowdsale, StormCrowdsale);
  deployer.deploy(StormCrowdsale);
};
