pragma solidity ^0.4.13;

import "./Utils/ReentrancyHandling.sol";
import "./Utils/Owned.sol";
import "./Interfaces/IToken.sol";
import "./Interfaces/IERC20Token.sol";

contract Crowdsale is ReentrancyHandling, Owned{

  struct ContributorData{
    bool isCommunityRoundApproved;
    uint contributionAmount;
    uint tokensIssued;
  }

  mapping(address => ContributorData) public contributorList;
  uint nextContributorIndex;
  mapping(uint => address) contributorIndexes;

  enum state { pendingStart, communityRound, crowdsaleStarted, crowdsaleEnded }
  state crowdsaleState = state.pendingStart;

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
  uint maxEthCap;

  uint public tokenSold = 0;
  uint public ethRaised = 0;

  address internal companyAddress;   // StormX company wallet address in cold/hardware storage 

  uint maxTokenSupply;
  uint companyTokens;
  bool ownerHasClaimedTokens = false;
  bool ownerHasClaimedCompanyTokens = false;

  //
  // Unnamed function that runs when eth is sent to the contract
  //
  function() public noReentrancy payable {
    require(msg.value != 0);                        // Throw if value is 0
    require(crowdsaleState != state.crowdsaleEnded);// Check if crowdsale has ended

    bool stateChanged = checkCrowdsaleState();      // Calibrate crowdsale state

    if (crowdsaleState == state.communityRound) {
      if (contributorList[msg.sender].isCommunityRoundApproved) {    // Check if contributor is approved for community round.
        processTransaction(msg.sender, msg.value);  // Process transaction and issue tokens
      }
      else {
        refundTransaction(stateChanged);            // Set state and return funds or throw
      }
    }
    else if(crowdsaleState == state.crowdsaleStarted){
      processTransaction(msg.sender, msg.value);    // Process transaction and issue tokens
    }
    else{
      refundTransaction(stateChanged);              // Set state and return funds or throw
    }
  }

  // 
  // return crowdsale state
  //
  function getCrowdsaleState() public constant returns (uint) {
    uint _state = 0;

    checkCrowdsaleState();                          // Calibrate crowdsale state

    if (crowdsaleState == state.pendingStart) {
      _state = 1;
    }
    else if (crowdsaleState == state.communityRound) {
      _state = 2;
    }
    else if (crowdsaleState == state.crowdsaleStarted) {
      _state = 3;
    }
    else if (crowdsaleState == state.crowdsaleEnded) {
      _state = 4;
    }
    return _state;
  }

  //
  // Check crowdsale state and calibrate it
  //
  function checkCrowdsaleState() internal returns (bool) {
    bool _stateChanged = false;

    // end crowdsale once all tokens are sold or run out of time
    if (now > crowdsaleEndDate || tokenSold >= maxCrowdsaleCap) {
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
  function refundTransaction(bool _stateChanged) internal {
    if (_stateChanged){
      msg.sender.transfer(msg.value);
    }else{
      revert();
    }
  }

  //
  // Issue tokens and return if there is overflow
  //
  function processTransaction(address _contributor, uint _amount) internal {
    uint contributionAmount = _amount;
    uint refundAmount = 0;
    uint bonusTokenAmount = 0;

    if (ethRaised + contributionAmount > maxEthCap) {                            // limit contribution to not go over the maximum cap of ETH to raise
      contributionAmount = maxEthCap - ethRaised;
      refundAmount = _amount - contributionAmount;
    }

    if (contributorList[_contributor].contributionAmount == 0) {                 // Check if contributor has already contributed
      contributorIndexes[nextContributorIndex] = _contributor;                   // Set contributors index
      nextContributorIndex++;
    }
    
    uint _amountContributed = contributorList[_contributor].contributionAmount;  // retrieve previous contributions

    contributorList[_contributor].contributionAmount += contributionAmount;      // Add contribution amount to existing contributor
    ethRaised += contributionAmount;                                             // Add contribution amount to ETH raised

    // community round ONLY: check that _amount sent plus previous contributions is less than or equal to the maximum contribution allowed
    if (crowdsaleState == state.communityRound && 
        contributorList[_contributor].isCommunityRoundApproved == true && 
        maxContribution < contributionAmount + _amountContributed) { 
      contributionAmount = maxContribution - _amountContributed;                // limit the contribution amount to the maximum allowed

      bonusTokenAmount = (contributionAmount * ethToTokenConversion) * 15 / 100;
    }
      
    uint tokenAmount = (contributionAmount * ethToTokenConversion) + bonusTokenAmount;     // Calculate how many tokens participant receives

    token.mintTokens(_contributor, tokenAmount);                              // Issue new tokens
    contributorList[_contributor].tokensIssued += tokenAmount;                // log token issuance
    tokenSold += tokenAmount;                                                 // track how many tokens are sold

    if (refundAmount > 0) {
      _contributor.transfer(refundAmount);                                    // refund contributor amount behind the maximum ETH cap
    }
  }

  //
  // whitelist validated participants.
  //
  function WhiteListContributors(address[] _contributorAddresses, bool[] _contributorCommunityRoundApproved) public onlyOwner {
    require(_contributorAddresses.length == _contributorCommunityRoundApproved.length); // Check if input data is correct

    for (uint cnt = 0; cnt < _contributorAddresses.length; cnt++) {
      contributorList[_contributorAddresses[cnt]].isCommunityRoundApproved = _contributorCommunityRoundApproved[cnt];
    }
  }

  function getContributor(address _contributorAddress) public onlyOwner returns (ContributorData) {
    require(_contributorAddress != 0x0); // Check if input data is correct

    return contributorList[_contributorAddress];
  }


  //
  // Method is needed for recovering tokens accidentally sent to token address
  //
  function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) public onlyOwner {
    IERC20Token(_tokenAddress).transfer(_to, _amount);
  }

  uint pendingEthWithdrawal;
  
  //
  // withdraw ETH by owner
  //
  function withdrawEth() public onlyOwner{
    require(this.balance != 0);

    pendingEthWithdrawal = this.balance;
  }

  function pullBalance() public {
    require(msg.sender == companyAddress);
    require(pendingEthWithdrawal > 0);

    companyAddress.transfer(pendingEthWithdrawal);
    pendingEthWithdrawal = 0;
  }

  //
  // If there were any issue/attach with refund owner can withraw eth at the end for manual recovery
  //
  function withdrawRemainingBalanceForManualRecovery() public onlyOwner {
    require(this.balance != 0);                                   // Check if there are any eth to claim
    require(now > crowdsaleEndDate);                              // Check if crowdsale is over
    companyAddress.transfer(this.balance);                       // Withdraw to multisig
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
  function claimCompanyTokens(address _to) public {
    require(msg.sender == companyAddress);
    require(!ownerHasClaimedCompanyTokens);                     // Check if owner has already claimed tokens

    token.mintTokens(_to, companyTokens);                       // Issue company tokens 
    ownerHasClaimedCompanyTokens = true;                        // Block further mints from this method
  }

  //
  // Claim remaining tokens when crowdsale ends
  //
  function claimRemainingTokens(address _to) public {
    require(msg.sender == companyAddress);
    require(crowdsaleState == state.crowdsaleEnded);              // Check crowdsale has ended
    require(!ownerHasClaimedTokens);                              // Check if owner has already claimed tokens

    uint remainingTokens = maxTokenSupply - token.totalSupply();
    token.mintTokens(_to, remainingTokens);                       // Issue tokens to company
    ownerHasClaimedTokens = true;                                 // Block further mints from this method
  }

  //
  //  Before crowdsale starts owner can calibrate blocks of crowdsale stages
  //
  function setCrowdsaleDates( uint _communityRoundStartDate, uint _crowdsaleStartDate, uint _crowdsaleEndDate) public onlyOwner {
//    require(crowdsaleState == state.pendingStart);                // Check if crowdsale has started
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
