
var StormToken = artifacts.require("./StormToken.sol");
var StormCrowdsale = artifacts.require("./StormCrowdsale.sol");

module.exports = function(deployer) {
  // deployer.deploy(StormCrowdsale).then(function() {
  //   console.log('StormCrowdsale contract address: ', StormCrowdsale.address);
  //   deployer.deploy(StormToken, StormCrowdsale.address);
  // });
  deployer.deploy(StormCrowdsale).then(function() {
    console.log('crowdsale address: ', StormCrowdsale.address);
    // deployer.deploy(StormToken, StormCrowdsale.address).then(function() {
    // deployer.deploy(StormToken, ).then(function() {
    //   console.log('token address: ', StormToken.address);
    // });
  });
};
