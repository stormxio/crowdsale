var StormCrowdsale = artifacts.require('../contracts/StormCrowdsale');

contract('Check Initial value of Storm Crowdsale', function(accounts) {
	let crowdsale;

	beforeEach(async function() {
		crowdsale = await StormCrowdsale.new()
	});	

	it('check initial token sold', async function() {
		let expected = 0;
		assert.equal(crowdsale.tokenSol(), expected, 'check tokens sold at contract deployment');
		done();
	});	
})