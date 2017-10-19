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
  state public crowdsaleState;

  uint communityRoundStartDate;
  uint crowdsaleStartDate;
  uint crowdsaleEndDate;

  event CommunityRoundStarted(uint timestamp);
  event CrowdsaleStarted(uint timestamp);
  event CrowdsaleEnded(uint timestamp);

  IToken token = IToken(0x0);
  uint ethToTokenConversion;

  uint256 maxCrowdsaleCap;
  uint256 maxCommunityCap;
  uint256 maxContribution;


  uint256 public tokenSold = 0;
  uint256 public communityTokenSold = 0;
  uint256 public crowdsaleTokenSold = 0;
  uint256 public ethRaised = 0;

  address public companyAddress;   // company wallet address in cold/hardware storage 

  uint maxTokenSupply;
  uint companyTokens;
  bool treasuryLocked = false;
  bool ownerHasClaimedTokens = false;
  bool ownerHasClaimedCompanyTokens = false;


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
        refundTransaction(stateChanged);                             // Set state and return funds or throw
      }
    }
    else if(crowdsaleState == state.crowdsaleStarted){
      processTransaction(msg.sender, msg.value);                     // Process transaction and issue tokens
    }
    else{
      refundTransaction(stateChanged);                               // Set state and return funds or throw
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
    if (now > crowdsaleEndDate || token.totalSupply() >= maxTokenSupply) {
      if (crowdsaleState != state.crowdsaleEnded) {
        crowdsaleState = state.crowdsaleEnded;
        CrowdsaleEnded(now);
        _stateChanged = true;
      }
    }
    else if (now > crowdsaleStartDate) { // move into crowdsale round
      if (crowdsaleState != state.crowdsaleStarted) {
        // apply any remaining tokens from community round to crowdsale round
        uint256 communityTokenRemaining = maxCommunityCap.sub(communityTokenSold);
        maxCrowdsaleCap.add(communityTokenRemaining);
        // change state
        crowdsaleState = state.crowdsaleStarted;
        CrowdsaleStarted(now);
        _stateChanged = true;
      }
    }
    else if (now > communityRoundStartDate) {
      if (communityTokenSold < maxCommunityCap) {
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
    if (_stateChanged) {
      msg.sender.transfer(msg.value);
    }
    else {
      revert();
    }
  }

  //
  // Issue tokens and return if there is overflow
  //
  function processTransaction(address _contributor, uint256 _amount) internal {
    uint256 newContribution = _amount;
    uint256 communityAmount = 0;
    uint256 communityTokenAmount = 0;
    uint256 bonusTokenAmount = 0;

    uint previousContribution = contributorList[_contributor].contributionAmount;  // retrieve previous contributions

    // community round ONLY
    if (crowdsaleState == state.communityRound && 
        contributorList[_contributor].isCommunityRoundApproved == true && 
        previousContribution < maxContribution) {
        communityAmount = newContribution;

        // limit the contribution ETH amount to the maximum allowed for the community round
        if (communityAmount.add(previousContribution) > maxContribution) {
          communityAmount = maxContribution.sub(previousContribution);                 
        }

        // compute community tokens without bonus
        communityTokenAmount = communityAmount.mul(ethToTokenConversion);
        
        // compute bonus tokens
        bonusTokenAmount = communityTokenAmount.mul(15);
        bonusTokenAmount = bonusTokenAmount.div(100);

        // add bonus to community tokens
        communityTokenAmount = communityTokenAmount.add(bonusTokenAmount);

        // verify community tokens do not go over the max cap for community round 
        if (communityTokenSold.add(communityTokenAmount) > maxCommunityCap) {
          // cap the tokens to the max allowed for the community round
          communityTokenAmount = maxCommunityCap.sub(communityTokenSold);

          // remove bonus tokens
          uint256 communityTokenWithoutBonus = communityTokenAmount.mul(100);
          communityTokenWithoutBonus = communityTokenWithoutBonus.div(115);

          // recalculate the corresponding ETH amount
          communityAmount = communityTokenWithoutBonus.div(ethToTokenConversion);
        }
        // track tokens sold during community round
        communityTokenSold.add(communityTokenAmount);
    }
      
    // compute ETH amount for crowdsale portion only
    uint256 crowdsaleAmount = newContribution.sub(communityAmount);

    // compute crowdsale tokens
    uint256 crowdsaleTokenAmount = crowdsaleAmount.mul(ethToTokenConversion);

    // verify crowdsale tokens do not go over the max cap for crowdsale round
    if (crowdsaleTokenSold.add(crowdsaleTokenAmount) > maxCrowdsaleCap) {
      // cap the tokens to the max allowed for the crowdsale round
      crowdsaleTokenAmount = maxCrowdsaleCap.sub(crowdsaleTokenSold);
      // recalculate the corresponding ETH amount
      crowdsaleAmount = crowdsaleTokenAmount.div(ethToTokenConversion);
    }
    // track tokens sold during crowdsale round
    crowdsaleTokenSold.add(crowdsaleTokenAmount);

    // add up crowdsale tokens + community tokens
    uint256 tokenAmount = crowdsaleTokenAmount.add(communityTokenAmount);

    // Issue new tokens
    token.mintTokens(_contributor, tokenAmount);                              

    // log token issuance
    contributorList[_contributor].tokensIssued = contributorList[_contributor].tokensIssued.add(tokenAmount);                

    // Add contribution amount to existing contributor
    newContribution = crowdsaleAmount.add(communityAmount);
    contributorList[_contributor].contributionAmount = contributorList[_contributor].contributionAmount.add(newContribution);

    ethRaised = ethRaised.add(newContribution);                              // Add contribution amount to ETH raised
    tokenSold = tokenSold.add(tokenAmount);                                  // track how many tokens are sold

    // compute any refund if applicable
    uint256 refundAmount = _amount.sub(newContribution);

    if (refundAmount > 0) {
      _contributor.transfer(refundAmount);                                    // refund contributor amount behind the maximum ETH cap
    }

    require(companyAddress != 0x0);
    companyAddress.transfer(newContribution);                                // send ETH to company
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
    require(!treasuryLocked);                              // Check if owner has already claimed tokens
    companyAddress = _newAddress;
    treasuryLocked = true;
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
  function claimCompanyTokens(address _to) public onlyOwner {
    require(!ownerHasClaimedCompanyTokens);                     // Check if owner has already claimed tokens
    require(_to == companyAddress);

    token.mintTokens(_to, companyTokens);                       // Issue company tokens 
    ownerHasClaimedCompanyTokens = true;                        // Block further mints from this method
  }

  //
  // Claim remaining tokens when crowdsale ends
  //
  function claimRemainingTokens(address _to) public onlyOwner {
    require(crowdsaleState == state.crowdsaleEnded);              // Check crowdsale has ended
    require(!ownerHasClaimedTokens);                              // Check if owner has already claimed tokens
    require(_to == companyAddress);
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
    checkCrowdsaleState();                                        // update state
  }
}
