pragma solidity ^0.4.13;

import "./Token.sol";

contract StormToken is Token {

  /* Initializes contract */
  function StormToken(address _crowdsaleAddress, uint256 _startTime) {
    standard = "Storm Token v1.0";
    name = "Storm Token";
    symbol = "STORM"; // token symbol
    decimals = 18;
    crowdsaleContractAddress = _crowdsaleAddress;
    lockFromSelf(_startTime, "Lock before crowdsale starts");
  }
}
