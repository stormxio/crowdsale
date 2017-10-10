var Crowdsale = artifacts.require("./Crowdsale.sol");
var StormCrowdsale = artifacts.require("./StormCrowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(Crowdsale);
  deployer.link(Crowdsale, StormCrowdsale);
  deployer.deploy(StormCrowdsale);
};
