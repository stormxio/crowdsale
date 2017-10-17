const StormCrowdsale = artifacts.require('StormCrowdsale')

contract('StormCrowdsale', function(accounts) {
  it("should assert true", function(done) {
    var storm_crowdsale = StormCrowdsale.deployed();
    assert.isTrue(true);
    done();
  });

  it('sets the first account as the contract creator', async function() {
    const contract = await StormCrowdsale.deployed();
    const creator = await contract.getCreator();
    assert.equal(creator, accounts[0], 'main account is the creator');
    done();
  });

  it('check initial community round start date', async function() {
    const contract = await StormCrowdsale.deployed();
    const communityRoundStartDate = await contract.communityRoundStartDate();
    assert.equal(communityRoundStartDate, 1508504400, 'community round start date is set');
    done();
  });

  it('check initial state of the contract', async function() {
    const contract = await StormCrowdsale.deployed();
    enum contract_state = await contract.crowdsaleState();
    assert.equal(contract_state, state.pendingStart, 'initial contract state');
    done();
  });

})
