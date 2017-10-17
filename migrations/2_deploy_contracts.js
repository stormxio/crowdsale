
var StormToken = artifacts.require("./StormToken.sol");
var StormCrowdsale = artifacts.require("./StormCrowdsale.sol");

module.exports = async function(deployer) {
  // deployer.deploy(StormCrowdsale).then(function() {
  //   console.log('StormCrowdsale contract address: ', StormCrowdsale.address);
  //   deployer.deploy(StormToken, StormCrowdsale.address);
  // });
  await deployer.deploy(StormCrowdsale);
  console.log('>>>>>inside deployer');
  await deployer.deploy(StormToken, StormCrowdsale.address);
};
