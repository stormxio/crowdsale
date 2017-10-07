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

  state public crowdsaleState = state.pendingStart;
  enum state { pendingStart, communityRound, crowdsale, crowdsaleEnded }

  uint public communityRoundStartDate;
  uint public crowdsaleStartDate;
  uint public crowdsaleEndDate;

  event CommunityRoundStarted(uint timestamp);
  event CrowdsaleStarted(uint timestamp);
  event CrowdsaleEnded(uint timestamp);

  IToken token = IToken(0x0);
  uint ethToTokenConversion;

  uint maxCommunityRoundCap;
  uint maxContribution;

  uint maxCrowdsaleCap;

  uint tokenSold;
  uint public ethRaised;

  address public multisigAddress;

  uint maxTokenSupply;
  bool ownerHasClaimedTokens;

  //
  // Unnamed function that runs when eth is sent to the contract
  //
  function() noReentrancy payable {
    require(msg.value != 0);                        // Throw if value is 0
    require(crowdsaleState != state.crowdsaleEnded);// Check if crowdsale has ended

    bool stateChanged = checkCrowdsaleState();      // Check blocks and calibrate crowdsale state

    if (crowdsaleState == state.communityRound) {
      if (contributorList[msg.sender].isCommunityRoundApproved) {    // Check if contributor is approved for community round.
        processTransaction(msg.sender, msg.value);  // Process transaction and issue tokens
      }
      else {
        refundTransaction(stateChanged);            // Set state and return funds or throw
      }
    }
    else if(crowdsaleState == state.crowdsale){
      processTransaction(msg.sender, msg.value);    // Process transaction and issue tokens
    }
    else{
      refundTransaction(stateChanged);              // Set state and return funds or throw
    }
  }

  //
  // Check crowdsale state and calibrate it
  //
  function checkCrowdsaleState() internal returns (bool) {
    bool _stateChanged = false;

    // end crowdsale once all tokens are sold or run out of time
    if (block.timestamp > crowdsaleEndDate || tokenSold >= maxCrowdsaleCap) {
      if (crowdsaleState != state.crowdsaleEnded) {
        crowdsaleState = state.crowdsaleEnded;
        CrowdsaleEnded(block.timestamp);
        _stateChanged = true;
      }
    }
    else if (block.timestamp > crowdsaleStartDate) { // move into crowdsale round
      if (crowdsaleState != state.crowdsale) {
        crowdsaleState = state.crowdsale;
        CrowdsaleStarted(block.timestamp);
        _stateChanged = true;
      }
    }
    else if (block.timestamp > communityRoundStartDate) {
      if (tokenSold < maxCommunityRoundCap) {
        if (crowdsaleState != state.communityRound) {
          crowdsaleState = state.communityRound;
          CommunityRoundStarted(block.timestamp);
          _stateChanged = true;
        }
      }
      else {  // automatically start crowdsale when all community round tokens are sold out
        if (crowdsaleState != state.crowdsale) {
          crowdsaleState = state.crowdsale;
          CrowdsaleStarted(block.timestamp);
          _stateChanged = true;
        }
      }
    }

    return _stateChanged;
  }

  //
  // Decide if throw or only return ether
  //
  function refundTransaction(bool _stateChanged) internal{
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
    uint returnAmount = 0;

    if (contributorList[_contributor].contributionAmount == 0) {                 // Check if contributor has already contributed
      contributorIndexes[nextContributorIndex] = _contributor;                   // Set contributors index
      nextContributorIndex++;
    }
    
    uint _amountContributed = contributorList[_contributor].contributionAmount;

    // community round ONLY: check that _amount sent plus previous contributions is less than or equal to the maximum contribution allowed
    if (crowdsaleState == state.communityRound && contributorList[_contributor].isCommunityRoundApproved == true && maxContribution < _amount + _amountContributed) { 
      contributionAmount = maxContribution - _amountContributed;               // limit the contribution amount to the maximum allowed
      returnAmount = _amount - contributionAmount;                             // Calculate how much the participant must get back
    }
      
    contributorList[_contributor].contributionAmount += contributionAmount;     // Add contribution amount to existing contributor

    ethRaised += contributionAmount;                                            // Add to eth raised

    uint256 tokenAmount = contributionAmount * ethToTokenConversion;            // Calculate how much tokens must contributor get

    if (crowdsaleState == state.communityRound) {                               
      tokenAmount = tokenAmount * 15 / 100 + tokenAmount;                       // 15% discount for community round
    }

    if (tokenAmount > 0) {
      token.mintTokens(_contributor, tokenAmount);                              // Issue new tokens
      contributorList[_contributor].tokensIssued += tokenAmount;                // log token issuance

      tokenSold += tokenAmount;                                                 // track how many tokens are sold
    }
    if (returnAmount != 0) _contributor.transfer(returnAmount);                 // Return overflow of ETH to sender
  }

  //
  // whitelist validated participants.
  //
  function WhiteListContributors(address[] _contributorAddresses, bool[] _contributorCommunityRoundApproved) onlyOwner {
    require(_contributorAddresses.length == _contributorCommunityRoundApproved.length); // Check if input data is correct

    for (uint cnt = 0; cnt < _contributorAddresses.length; cnt++) {
      contributorList[_contributorAddresses[cnt]].isCommunityRoundApproved = _contributorCommunityRoundApproved[cnt];
    }
  }

  //
  // Method is needed for recovering tokens accidentally sent to token address
  //
  function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) onlyOwner{
    IERC20Token(_tokenAddress).transfer(_to, _amount);
  }

  uint pendingEthWithdrawal;
  
  //
  // withdraw ETH by owner
  //
  function withdrawEth() onlyOwner{
    require(this.balance != 0);

    pendingEthWithdrawal = this.balance;
  }

  function pullBalance(){
    require(msg.sender == multisigAddress);
    require(pendingEthWithdrawal > 0);

    multisigAddress.transfer(pendingEthWithdrawal);
    pendingEthWithdrawal = 0;
  }

  //
  // If there were any issue/attach with refund owner can withraw eth at the end for manual recovery
  //
  function withdrawRemainingBalanceForManualRecovery() onlyOwner {
    require(this.balance != 0);                                  // Check if there are any eth to claim
    require(block.timestamp > crowdsaleEndDate);                 // Check if crowdsale is over
    multisigAddress.transfer(this.balance);                      // Withdraw to multisig
  }

  //
  // Owner can set multisig address for crowdsale
  //
  function setMultisigAddress(address _newAddress) onlyOwner{
    multisigAddress = _newAddress;
  }

  //
  // Owner can set token address where mints will happen
  //
  function setToken(address _newAddress) onlyOwner{
    token = IToken(_newAddress);
  }

  //
  // Owner can claim remaining tokens when crowdsale has successfully ended
  //
  function claimCompanyTokens(address _to) onlyOwner {
    require(crowdsaleState == state.crowdsaleEnded);              // Check if crowdsale has ended
    require(!ownerHasClaimedTokens);                              // Check if owner has already claimed tokens

    uint remainingTokens = maxTokenSupply - token.totalSupply();
    token.mintTokens(_to, remainingTokens);                       // Issue tokens to company
    ownerHasClaimedTokens = true;                                 // Block further mints from this method
  }

  function getTokenAddress() constant returns(address) {
    return address(token);
  }

  //
  //  Before crowdsale starts owner can calibrate blocks of crowdsale stages
  //
  function setCrowdsaleDates( uint _communityRoundStartDate, uint _crowdsaleStartDate, uint _crowdsaleEndDate) onlyOwner {
    require(crowdsaleState == state.pendingStart);                // Check if crowdsale has started
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
