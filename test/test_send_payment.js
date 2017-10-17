var StormCrowdsale = artifacts.require('../contracts/StormCrowdsale');
var StormToken = artifacts.require('../contracts/StormToken');

contract('Check Transaction', function(accounts) {
	let crowdsale;
	let token;

	beforeEach(async function() {
		// crowdsale = await StormCrowdsale.deployed();
		crowdsale = await StormCrowdsale.new();
	});	

	it('sending payment', async function() {
		let account0 = web3.eth.accounts[0];
		let account1 = web3.eth.accounts[1];
		console.log('accounts[0]: ', account0);
		console.log('accounts[1]: ', account1);
		crowdsale = await StormCrowdsale.new();
		await crowdsale.setCompanyAddress(account0);
		console.log('crowdsale address: ', crowdsale.address);
		console.log('crowdsale contract: ', crowdsale);
		token = StormToken.at(crowdsale.address);
		// console.log('token: ', token);
		const value = web3.toWei(0.01, "ether");
		console.log('value: ', value);
		const accountBalance = web3.eth.getBalance(web3.eth.accounts[1]);
		const accountBalance_number = new web3.BigNumber(accountBalance);
		console.log('balance of account1: ', accountBalance_number.toString());
		crowdsale.sendTransaction({
			from: account1, 
			to: crowdsale.address, 
			value: value
		});

		// console.log('Transaction: ', transaction);
		let ethRaised = await crowdsale.ethRaised();
		let ethRaised_number = new web3.BigNumber(ethRaised);
		console.log('eth raised: ', ethRaised.toString());
		

		let tokenSold = await crowdsale.tokenSold();
		console.log('token sold: ', tokenSold);

		assert.equal(ethRaised, value, 'check eth raised after one transaction');
	});

	// it('sending payment', async function() {
	// 	crowdsale = await StormCrowdsale.deployed();
	// 	token = await StormToken.deployed();
	// 	await crowdsale.setToken(token.address);
	// 	console.log('contract address: ', crowdsale.address);
	// 	// token = await new StormToken(crowdsale.address).deployed();
	// 	// token = await StormToken.deployed();
	// 	console.log('web3 eth accounts[0]: ', web3.eth.accounts[0]);
	// 	console.log('web3 eth accounts[1]: ', web3.eth.accounts[1]);
	// 	let account_address_1 = web3.eth.accounts[1];
	// 	const initialBalance = web3.eth.getBalance(web3.eth.accounts[1]);
	// 	console.log('initialBalance of web3.eth.accounts[1]: ', initialBalance);
	// 	const initialBalance_number = new web3.BigNumber(initialBalance).toString();
	// 	console.log('initialBalance number: ', initialBalance_number);
	// 	const value = web3.toWei(1, "ether");
	// 	console.log('FROM web3.eth.accounts[0]: ', web3.eth.accounts[1]);
	// 	console.log('TO   	 crowdsale.address: ', crowdsale.address);
	// 	console.log('VALUE               value: ', value);
	// 	const loadup = {
	// 		from: web3.eth.accounts[1], 
	// 		to: crowdsale.address, 
	// 		value: value
	// 	};
	// 	const transactionReceipt = await crowdsale.sendTransaction(loadup);
	// 	// const value = 1000000000;
	// 	// const transaction = await web3.eth.sendTransaction({
	// 	// 	to: crowdsale.address, 
	// 	// 	from: account_address_1, 
	// 	// 	value: value
	// 	// });
	// 	console.log('transaction: ', transactionReceipt);

	// 	const ethRaised = await crowdsale.ethRaised();
	// 	const ethRaised_number = new web3.BigNumber(ethRaised).toString();
	// 	console.log('eth raised: ', ethRaised_number);

	// 	const tokenSold = await crowdsale.tokenSold();
	// 	const tokenSold_number = new web3.BigNumber(tokenSold).toString();
	// 	console.log('token sold: ', tokenSold_number);

	// 	assert.equal(ethRaised_number, value, 'check eth raised after transaction');
	// });
})

// web3.eth.sendTransaction({from:accounts[0], to:"YOUR_CONTRACT_ADDRESS", value: web3.toWei(1, "ether")});
// await timeTravel(86400 * 3) //3 days later
// await mineBlock() // workaround for https://github.com/ethereumjs/testrpc/issues/336
