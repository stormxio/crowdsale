var StormCrowdsale = artifacts.require('../contracts/StormCrowdsale');
var StormToken = artifacts.require('../contracts/StormToken');

contract('Check Initial value of Storm Crowdsale', function(accounts) {
	let crowdsale;
	let token;

	beforeEach(async function() {
		// crowdsale = await StormCrowdsale.deployed();
		crowdsale = await StormCrowdsale.new();
	});	

	it('check initial state of the contract', async function() {
	    const contract_state = await crowdsale.getCrowdsaleState();
	    const state_pendingStart = 1;
	    assert.equal(contract_state, state_pendingStart, 'initial contract state');
  });

	it('check initial token sold', async function() {
		const tokenSold = await crowdsale.tokenSold();
		const tokenSold_number = new web3.BigNumber(tokenSold).toString();
		const expected = 0;
		assert.equal(tokenSold_number, expected, 'check tokens sold at contract deployment');
	});	

	it('check initial eth raised', async function() {
		const ethRaised = await crowdsale.ethRaised();
		const ethRaised_number = new web3.BigNumber(ethRaised).toString();
		const expected = 0;
		assert.equal(ethRaised_number, expected, 'check initial eth raised');
	});

	it('sending payment', async function() {
		crowdsale = await StormCrowdsale.deployed();
		console.log('contract address: ', crowdsale.address);
		// token = await new StormToken(crowdsale.address).deployed();
		// token = await StormToken.deployed();
		console.log('web3 eth accounts[0]: ', web3.eth.accounts[0]);
		console.log('web3 eth accounts[1]: ', web3.eth.accounts[1]);
		const initialBalance = web3.eth.getBalance(web3.eth.accounts[1]);
		console.log('initialBalance: ', initialBalance);
		const initialBalance_number = new web3.BigNumber(initialBalance).toString();
		console.log('initialBalance number: ', initialBalance_number);

		const value = web3.toWei(0.5, 'eth');
		const transaction = await web3.eth.sendTransaction({
			to: crowdsale.address, 
			from: accounts[1], 
			value: value
		});
		console.log('transaction: ', transaction);

		const ethRaised = await crowdsale.ethRaised();
		const ethRaised_number = new web3.BigNumber(ethRaised).toString();
		console.log('eth raised: ', ethRaised_number);

		const tokenSold = await crowdsale.tokenSold();
		const tokenSold_number = new web3.BigNumber(tokenSold).toString();
		console.log('token sold: ', tokenSold_number);

		assert.equal(ethRaised_number, value, 'check eth raised after transaction');
	});


// web3.eth.sendTransaction({from:accounts[0], to:"YOUR_CONTRACT_ADDRESS", value: web3.toWei(1, "ether")});
// await timeTravel(86400 * 3) //3 days later
    // await mineBlock() // workaround for https://github.com/ethereumjs/testrpc/issues/336

	// it('check fallback function', async function() {

	// });
})