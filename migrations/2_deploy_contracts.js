var IToken = artifacts.require("./Interfaces/IToken.sol");
var ITokenRecipient = artifacts.require("./Interfaces/ITokenRecipient.sol");
var IERC20Token = artifacts.require("./Interfaces/IERC20Token.sol");
var ReentrancyHandling = artifacts.require("./Utils/ReentrancyHandling.sol");
var SafeMath = artifacts.require("./Utils/SafeMath.sol");
var Owned = artifacts.require("./Utils/Owned.sol");
var Lockable = artifacts.require("./Utils/Lockable.sol");
var Token = artifacts.require("./Token.sol");
var StormToken = artifacts.require("./StormToken.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");
var StormCrowdsale = artifacts.require("./StormCrowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(IToken);
  deployer.deploy(ITokenRecipient);
  deployer.deploy(IERC20Token);
  deployer.deploy(ReentrancyHandling);
  deployer.deploy(SafeMath);
  deployer.deploy(Owned);
  deployer.deploy(Lockable);
  deployer.deploy(Token);
  deployer.deploy(StormToken, <companyAddress>, <start time>);
  deployer.deploy(Crowdsale);
  deployer.deploy(StormCrowdsale);
};
