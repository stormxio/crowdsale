pragma solidity ^0.4.13;

import "./Utils/ReentrancyHandling.sol";
import "./Utils/Owned.sol";
import "./Utils/SafeMath.sol";
import "./Interfaces/IToken.sol";
import "./Interfaces/IERC20Token.sol";

contract Crowdsale is ReentrancyHandling, Owned{

  using SafeMath for uint256;
  
  struct ContributorData{
    bool isWhiteListed;
    bool isCommunityRoundApproved;
    uint contributionAmount;
    uint tokensIssued;
  }

  mapping(address => ContributorData) public contributorList;

  enum state { pendingStart, communityRound, crowdsaleStarted, crowdsaleEnded }
  state public crowdsaleState = state.pendingStart;

  uint communityRoundStartDate;
  uint crowdsaleStartDate;
  uint crowdsaleEndDate;

  event CommunityRoundStarted(uint timestamp);
  event CrowdsaleStarted(uint timestamp);
  event CrowdsaleEnded(uint timestamp);

  IToken token = IToken(0x0);
  uint ethToTokenConversion;

  uint maxCommunityRoundCap;
  uint maxContribution;

  uint maxCrowdsaleCap;
  uint256 maxEthCap;

  uint256 public tokenSold = 0;
  uint256 public ethRaised = 0;

  address internal companyAddress;   // StormX company wallet address in cold/hardware storage 

  uint maxTokenSupply;
  uint companyTokens;
  bool ownerHasClaimedTokens = false;
  bool ownerHasClaimedCompanyTokens = false;


  // validates address is the crowdsale owner
  modifier onlyCrowdsaleOwner {
    require(msg.sender == companyAddress);
    _;
  }

  // validates sender is whitelisted
  modifier onlyWhiteListUser {
    require(contributorList[msg.sender].isWhiteListed == true);
    _;
  }

  // limit gas price to 50 Gwei (about 5-10x the normal amount)
  modifier onlyLowGasPrice {
	  require(tx.gasprice <= 50*10**9);
	  _;
  }

  //
  // Unnamed function that runs when eth is sent to the contract
  //
  function() public noReentrancy onlyWhiteListUser onlyLowGasPrice payable {
    require(msg.value != 0);                                         // Throw if value is 0
    require(crowdsaleState != state.crowdsaleEnded);                 // Check if crowdsale has ended

    bool stateChanged = checkCrowdsaleState();                       // Calibrate crowdsale state

    if (crowdsaleState == state.communityRound) {
      if (contributorList[msg.sender].isCommunityRoundApproved) {    // Check if contributor is approved for community round.
        processTransaction(msg.sender, msg.value);                   // Process transaction and issue tokens
      }
      else {
        refundTransaction();                                         // Set state and return funds or throw
      }
    }
    else if(crowdsaleState == state.crowdsaleStarted){
      processTransaction(msg.sender, msg.value);                     // Process transaction and issue tokens
    }
    else{
      refundTransaction();                                           // Set state and return funds or throw
    }
  }

  // 
  // return crowdsale state
  //
  function getCrowdsaleState() public constant returns (uint) {
    uint currentState = 0;

    checkCrowdsaleState();                          // Calibrate crowdsale state

    if (crowdsaleState == state.pendingStart) {
      currentState = 1;
    }
    else if (crowdsaleState == state.communityRound) {
      currentState = 2;
    }
    else if (crowdsaleState == state.crowdsaleStarted) {
      currentState = 3;
    }
    else if (crowdsaleState == state.crowdsaleEnded) {
      currentState = 4;
    }
    return currentState;
  }

  //
  // Check crowdsale state and calibrate it
  //
  function checkCrowdsaleState() internal returns (bool) {
    bool _stateChanged = false;

    // end crowdsale once all tokens are sold or run out of time
    if (now > crowdsaleEndDate || tokenSold >= maxCrowdsaleCap || ethRaised >= maxEthCap) {
      if (crowdsaleState != state.crowdsaleEnded) {
        crowdsaleState = state.crowdsaleEnded;
        CrowdsaleEnded(now);
        _stateChanged = true;
      }
    }
    else if (now > crowdsaleStartDate) { // move into crowdsale round
      if (crowdsaleState != state.crowdsaleStarted) {
        crowdsaleState = state.crowdsaleStarted;
        CrowdsaleStarted(now);
        _stateChanged = true;
      }
    }
    else if (now > communityRoundStartDate) {
      if (tokenSold < maxCommunityRoundCap) {
        if (crowdsaleState != state.communityRound) {
          crowdsaleState = state.communityRound;
          CommunityRoundStarted(now);
          _stateChanged = true;
        }
      }
      // automatically start crowdsale when all community round tokens are sold out 
      else {  
        if (crowdsaleState != state.crowdsaleStarted) {
          crowdsaleState = state.crowdsaleStarted;
          CrowdsaleStarted(now);
          _stateChanged = true;
        }
      }
    }

    return _stateChanged;
  }

  //
  // Decide if throw or only return ether
  //
  function refundTransaction() internal {
    msg.sender.transfer(msg.value);
  }

  //
  // Issue tokens and return if there is overflow
  //
  function processTransaction(address _contributor, uint256 _amount) internal {
    uint256 contributionAmount = _amount;
    uint256 communityAmount = 0;
    uint256 refundAmount = 0;
    uint256 bonusTokenAmount = 0;

//    if (ethRaised + contributionAmount > maxEthCap) {                            // limit contribution to not go over the maximum cap of ETH to raise
    if (ethRaised.add(contributionAmount) > maxEthCap) {                            // limit contribution to not go over the maximum cap of ETH to raise
//      contributionAmount = maxEthCap - ethRaised;
      contributionAmount = maxEthCap.sub(ethRaised);

//      refundAmount = _amount - contributionAmount;
      refundAmount = _amount.sub(contributionAmount);
    }

    uint amountContributed = contributorList[_contributor].contributionAmount;  // retrieve previous contributions

    // Add contribution amount to existing contributor
//    contributorList[_contributor].contributionAmount += contributionAmount;      
    contributorList[_contributor].contributionAmount = contributorList[_contributor].contributionAmount.add(contributionAmount);
//    ethRaised += contributionAmount;                                             // Add contribution amount to ETH raised
    ethRaised = ethRaised.add(contributionAmount);                              // Add contribution amount to ETH raised

    // community round ONLY: check that _amount sent plus previous contributions is less than or equal to the maximum contribution allowed
    if (crowdsaleState == state.communityRound && 
        contributorList[_contributor].isCommunityRoundApproved == true && 
//        maxContribution < contributionAmount + amountContributed) { 
        maxContribution < contributionAmount.add(amountContributed)) { 
//      communityAmount = maxContribution - amountContributed;                    // limit the contribution amount to the maximum allowed
      communityAmount = maxContribution.sub(amountContributed);                 // limit the contribution amount to the maximum allowed

//      bonusTokenAmount = (communityAmount * ethToTokenConversion) * 15 / 100;
      bonusTokenAmount = communityAmount.mul(ethToTokenConversion);
      bonusTokenAmount = bonusTokenAmount.mul(15);
      bonusTokenAmount = bonusTokenAmount.div(100);
    }
      
    // Calculate how many tokens participant receives
//    uint tokenAmount = (contributionAmount * ethToTokenConversion) + bonusTokenAmount;     
    uint tokenAmount = contributionAmount.mul(ethToTokenConversion);
    tokenAmount = tokenAmount.add(bonusTokenAmount);

    token.mintTokens(_contributor, tokenAmount);                              // Issue new tokens

    // log token issuance
//    contributorList[_contributor].tokensIssued += tokenAmount;                // log token issuance
    contributorList[_contributor].tokensIssued = contributorList[_contributor].tokensIssued.add(tokenAmount);                

//    tokenSold += tokenAmount;                                                 // track how many tokens are sold
    tokenSold = tokenSold.add(tokenAmount);                                   // track how many tokens are sold

    if (refundAmount > 0) {
      _contributor.transfer(refundAmount);                                    // refund contributor amount behind the maximum ETH cap
    }

    require(companyAddress != 0x0);
    companyAddress.transfer(contributionAmount);                              // send ETH to company
  }

  //
  // whitelist validated participants.
  //
  function WhiteListContributors(address[] _contributorAddresses, bool[] _contributorCommunityRoundApproved) public onlyOwner {
    require(_contributorAddresses.length == _contributorCommunityRoundApproved.length); // Check if input data is correct

    for (uint cnt = 0; cnt < _contributorAddresses.length; cnt++) {
      contributorList[_contributorAddresses[cnt]].isWhiteListed = true;
      contributorList[_contributorAddresses[cnt]].isCommunityRoundApproved = _contributorCommunityRoundApproved[cnt];
    }
  }

  //
  // Method is needed for recovering tokens accidentally sent to token address
  //
  function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) public onlyOwner {
    IERC20Token(_tokenAddress).transfer(_to, _amount);
  }

  //
  // If there were any issue/attach with refund owner can withraw eth at the end for manual recovery
  //
  function withdrawRemainingBalanceForManualRecovery() public onlyOwner {
    require(this.balance != 0);                                   // Check if there are any eth to claim
    require(now > crowdsaleEndDate);                              // Check if crowdsale is over
    companyAddress.transfer(this.balance);                        // Withdraw to company address 
  }

  //
  // Owner can set multisig address for crowdsale
  //
  function setCompanyAddress(address _newAddress) public onlyOwner {
    companyAddress = _newAddress;
  }

  //
  // Owner can set token address where mints will happen
  //
  function setToken(address _newAddress) public onlyOwner {
    token = IToken(_newAddress);
  }

  function getToken() public constant returns (address) {
    return address(token);
  }

  //
  // Claims company tokens
  //
  function claimCompanyTokens(address _to) public onlyCrowdsaleOwner {
    require(!ownerHasClaimedCompanyTokens);                     // Check if owner has already claimed tokens

    token.mintTokens(_to, companyTokens);                       // Issue company tokens 
    ownerHasClaimedCompanyTokens = true;                        // Block further mints from this method
  }

  //
  // Claim remaining tokens when crowdsale ends
  //
  function claimRemainingTokens(address _to) public onlyCrowdsaleOwner {
    require(crowdsaleState == state.crowdsaleEnded);              // Check crowdsale has ended
    require(!ownerHasClaimedTokens);                              // Check if owner has already claimed tokens

//    uint remainingTokens = maxTokenSupply - token.totalSupply();
    uint256 remainingTokens = maxTokenSupply.sub(token.totalSupply());

    token.mintTokens(_to, remainingTokens);                       // Issue tokens to company
    ownerHasClaimedTokens = true;                                 // Block further mints from this method
  }

  //
  //  Owner can calibrate crowdsale dates
  //
  function setCrowdsaleDates( uint _communityRoundStartDate, uint _crowdsaleStartDate, uint _crowdsaleEndDate) public onlyOwner {
    require(_communityRoundStartDate != 0);                       // Check if any value is 0
    require(_crowdsaleStartDate != 0);                            // Check if any value is 0
    require(_crowdsaleEndDate != 0);                              // Check if any value is 0
    require(_communityRoundStartDate < _crowdsaleStartDate);      // Check if crowdsaleStartDate is set properly
    require(_crowdsaleStartDate < _crowdsaleEndDate);             // Check if crowdsaleEndDate is set properly

    communityRoundStartDate = _communityRoundStartDate;
    crowdsaleStartDate = _crowdsaleStartDate;
    crowdsaleEndDate = _crowdsaleEndDate;
  }
}
