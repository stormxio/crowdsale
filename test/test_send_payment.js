var StormCrowdsale = artifacts.require('../contracts/StormCrowdsale');
var StormToken = artifacts.require('../contracts/StormToken');
const moment = require('moment');

contract('Check Transaction', function(accounts) {
	let crowdsale;
	let stm;

	// Check Accounts Address
	let account0 = web3.eth.accounts[0];
	let account1 = web3.eth.accounts[1];
	let account2 = web3.eth.accounts[2];

	// beforeEach(async function() {
	// 	crowdsale = StormCrowdsale.address;
	// 	stm = StormToken.address;
	// 	console.log('crowdsale address: ', crowdsale);
	// 	console.log('stm address: ', stm);
	// });	

	it('Setting StormCrowdsale contract address to StormToken contract', async function() {
		stm = await StormToken.deployed();
		return StormToken(StormCrowdsale.address);
	});

	it('Setting company address to StormCrowdsale', async function() {
		crowdsale = await StormCrowdsale.deployed();
		return crowdsale.setCompanyAddress(account0);
	});

	it('Check Initial Crowdsale State', async function() {
		crowdsale = await StormCrowdsale.deployed();
		let curr_state = await crowdsale.getCrowdsaleState();
		let expected_state = 1; // Pending Start
		assert.equal(expected_state, curr_state, 'Checking Pending Start State');
	});

	// it('Setting Crowdsale Dates', async function() {
	// 	// TODO: For all 3 States
	// 	// Set the Community Round Start Date to before now
	// 	//   => State is now Community Round
	// 	crowdsale = await StormCrowdsale.deployed();
	// 	let new_cRSD = 1608504400; // Change Epoch time to before now
	// 	let new_cSD = 1608590800; // Change Epoch time to before now
	// 	let new_cED = 1611182800; // Change Epoch time to after now
	// 	await crowdsale.setCrowdsaleDates(new_cRSD, new_cSD, new_cED);
		
	// 	let currState = await crowdsale.getCrowdsaleState();
	// 	// assert.equal()
	// });

	it('Sending Payment to Crowdsale during Community Round', async function() {
		crowdsale = await StormCrowdsale.deployed();
		let currTimestamp = moment.utc().valueOf()/1000;
		await crowdsale.setCrowdsaleDates(currTimestamp - 100, currTimestamp + 9000000, currTimestamp + 900000001);
		let currState = await crowdsale.getCrowdsaleState();
		currState_number = new web3.BigNumber(currState).toString();
		let expectedState = 2; // Community Round = 2
		assert.equal(currState_number, expectedState, 'check state == community round');

		// Set Token on StormCrowdsale
		await crowdsale.setToken(StormToken.address);
		let tokenAddress = await crowdsale.getToken();
		assert.equal(StormToken.address, tokenAddress, 'check set token');
		// Add accounts into white list
		let accounts = [];
		accounts.push(account1);

		let bools = [];
		bools.push(true);
		await crowdsale.WhiteListContributors(accounts, bools);
		let contributorData = await crowdsale.contributorList(account1);
		console.log('contributorData: ', contributorData);
		let expectedData = true;
		assert.equal(expectedData, contributorData[0], 'check contributor list and data');

		// Send Payment transaction
		// Check before and after balance of the account, tokenSold, ethRaised
		let initial_balance = new web3.BigNumber(web3.eth.getBalance(account1)).toString();
		let initial_token = await crowdsale.tokenSold();
		let initial_eth = await crowdsale.ethRaised();
		console.log('initial balance: ', initial_balance);
		console.log('initial token: ', initial_token);
		console.log('initial eth: ', initial_eth);
		let value = web3.toWei(0.5, 'ether');
		
		crowdsale = await crowdsale.set.sendTransaction({
			from: account1,
			value: value
		});
		let post_balance = new web3.BigNumber(web3.eth.getBalance(account1)).toString();
		let post_token = await crowdsale.tokenSold();
		let post_ethRaised = await crowdsale.ethRaised();
		console.log('post balance: ', post_balance);
		console.log('post token: ', post_token);
		console.log('post eth: ', post_eth);
	});

	// it('Appending eth address to Contributor List', async function() {
	// 	crowdsale = await StormCrowdsale.deployed();
	// 	return crowdsale.
	// });

	// it('Sending payment to StormCrowdsale', async function() {
	// 	crowdsale = await StormCrowdsale.deployed();
	// 	stm = await StormToken.deployed();
	// 	crowdsale.sendTransaction({
	// 		from: 
	// 	});
	// });

	// it('Next test: ', async function() {
	// 	// Setting Company Address
	// 	crowdsale = await StormCrowdsale.new();
	// 	await crowdsale.setCompanyAddress(account0);


	// 	console.log('Setting White List Contributors');
	// 	let addresses = [account0, account1, account2];
	// 	let bools = [true, true, true];
	// 	console.log('addresses length: ', addresses.length);
	// 	console.log('bools length: ', bools.length);

	// 	let add = await crowdsale.WhiteListContributors(addresses, bools);
	// 	console.log('event add: ', add);

	// 	let contributorData = await crowdsale.isCommunityRoundApproved(account0);
	// 	console.log('result of get contributor: ');
	// 	console.log(`contributor: ${account0} , ${contributorData.toString()}`);

	// 	console.log('Grab Contributor List from contract');
	// 	let contributorList = await crowdsale.contributorList(account0);
	// 	console.log('Got Contributor List!');

	// 	let keys = Object.keys(contributorList);
	// 	console.log('Contributor List Keys: ', keys.toString());

	// 	console.log('crowdsale address: ', crowdsale.address);
	// 	// console.log('crowdsale contract: ', crowdsale);

	// 	crowdsale.claimCompanyTokens(account0);
	// 	const accountBalance_company = web3.eth.getBalance(web3.eth.accounts[0]);
	// 	const accountBalance_company_number = new web3.BigNumber(accountBalance_company);
	// 	console.log('balance of company eth: ', accountBalance_company_number.toString());

	// 	// token = await StormToken.at(crowdsale.address);
	// 	console.log('1');
	// 	console.log('account0: ', account0);
	// 	console.log('account0 address: ', account0.address);
	// 	console.log('stm standard: ', await stm.standard());
	// 	console.log('stm name: ', await stm.name());
	// 	console.log('stm symbol: ', await stm.symbol());
	// 	console.log('stm decimals: ', await stm.decimal());
	// 	const balance = await stm.balanceOf(account0);
	// 	console.log('2');
	// 	const balance_number = new web3.BigNumber(balance);
	// 	console.log('3');
	// 	console.log('balance of company token: ', balance_number.toString());

	// 	// Time skip
	// 	const crowdsalesStartDate = 1508280057;  
	// 	await crowdsale.setCrowdsaleDates(1508280056, 1508280057, 1508280057+900000000);
	// 	const currState = await crowdsale.getCrowdsaleState();
	// 	const currState_number = new web3.BigNumber(currState);
	// 	console.log('current state: ', currState.toString());

	// 	const value = web3.toWei(0.01, "ether");
	// 	console.log('value: ', value);

	// 	const accountBalance = web3.eth.getBalance(web3.eth.accounts[1]);
	// 	const accountBalance_number = new web3.BigNumber(accountBalance);
	// 	console.log('balance of account1: ', accountBalance_number.toString());

	// 	crowdsale.sendTransaction({
	// 		from: account1, 
	// 		to: crowdsale.address, 
	// 		value: value
	// 	});

	// 	// console.log('Transaction: ', transaction);
	// 	let ethRaised = await crowdsale.ethRaised();
	// 	let ethRaised_number = new web3.BigNumber(ethRaised);
	// 	console.log('eth raised: ', ethRaised.toString());
		

	// 	let tokenSold = await crowdsale.tokenSold();
	// 	console.log('token sold: ', tokenSold);

	// 	assert.equal(ethRaised, value, 'check eth raised after one transaction');
	// });

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
