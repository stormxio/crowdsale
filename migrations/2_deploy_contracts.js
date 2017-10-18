
var StormToken = artifacts.require("./StormToken.sol");
var StormCrowdsale = artifacts.require("./StormCrowdsale.sol");

module.exports = function(deployer) {
  // deployer.deploy(StormCrowdsale).then(function() {
  //   console.log('StormCrowdsale contract address: ', StormCrowdsale.address);
  //   deployer.deploy(StormToken, StormCrowdsale.address);
  // });
  console.log('>>>deploying storm crowdsale')
  deployer.deploy(StormCrowdsale).then(function() {
    console.log('>>>deployed storm crowdsale');
    console.log('>>>deploying storm token');
    deployer.deploy(StormToken, StormCrowdsale.address).then(function() {
      console.log('>>>deployed storm token'); 
    });
  });
};
