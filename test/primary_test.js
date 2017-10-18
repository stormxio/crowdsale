var StormCrowdsale = artifacts.require('../contracts/StormCrowdsale');
var StormToken = artifacts.require('../contracts/StormToken');
const moment = require('moment');

contract('Pending State', function(accounts) {
	let crowdsale;
	let stm;

	// Check Accounts Address
	let account0 = web3.eth.accounts[0]; // Owner
	let account1 = web3.eth.accounts[1]; // Company Address
	let account2 = web3.eth.accounts[2];
	let account3 = web3.eth.accounts[3];
	let account4 = web3.eth.accounts[4];

	beforeEach(async function() {
		crowdsale = await StormCrowdsale.deployed();
		stm = await StormToken.deployed();
		console.log('crowdsale: ', crowdsale.address);
		console.log('stormtoken: ', stm.address);

		// Set StormCrowdsale Address to StormToken
		await StormToken(StormCrowdsale.address);
		let expected_crowdsale_address = StormCrowdsale.address;
		let current_crowdsale_address = await stm.crowdsaleContractAddress();
		assert.equal(expected_crowdsale_address, current_crowdsale_address, 'Check Crowdsale Address on StormToken Contract');
		
		// Set Company Address to StormCrowdsale
		let returnObject = await crowdsale.setCompanyAddress(account1);
		// TODO: ASSERTION ???
		// console.log(returnObject);
		// assert.notEqual(null, returnObject, 'Check if Set Company Address to StormCrowdsale worked');

		// Check Initial Crowdsale State
		let expected_state = 1; // Pending Start
		let curr_state = await crowdsale.getCrowdsaleState();
		assert.equal(expected_state, curr_state, 'Checking if state is in Pending State');
	});	

	it('just to check before each', async function() {
		console.log('just to check before each');
	});

	it('Sending transaction', async function() {
		
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

	// it('Sending Payment to Crowdsale during Community Round', async function() {
	// 	// Create a StormToken instance with the StormCrowdsale address
	// 	// console.log('crowdsale address: ', crowdsale.address);
	// 	let expected_address = await stm.crowdsaleContractAddress();
	// 	console.log('expected address: ', expected_address);
	// 	assert.equal(expected_address, crowdsale.address, 'check Crowdsale contract address');

	// 	let currTimestamp = moment.utc().valueOf()/1000;
	// 	await crowdsale.setCrowdsaleDates(currTimestamp - 100, currTimestamp + 9000000, currTimestamp + 900000001);
	// 	let currState = await crowdsale.getCrowdsaleState();
	// 	currState_number = new web3.BigNumber(currState).toString();
	// 	let expectedState = 2; // Community Round = 2
	// 	assert.equal(currState_number, expectedState, 'check state == community round');


	// 	// Set Token on StormCrowdsale
	// 	await crowdsale.setToken(StormToken.address);
	// 	let tokenAddress = await crowdsale.getToken();
	// 	assert.equal(StormToken.address, tokenAddress, 'check set token');
	// 	// Add accounts into white list
	// 	let accounts = [];
	// 	accounts.push(account1);

	// 	let bools = [];
	// 	bools.push(true);
	// 	await crowdsale.WhiteListContributors(accounts, bools);
	// 	let contributorData = await crowdsale.contributorList(account1);
	// 	// console.log('contributorData: ', contributorData);
	// 	let expectedData = true;
	// 	assert.equal(expectedData, contributorData[0], 'check contributor list and data');

	// 	// Send Payment transaction
	// 	// Check before and after balance of the account, tokenSold, ethRaised
	// 	let initial_balance = await web3.eth.getBalance(account1);
	// 	let initial_balance_number = new web3.BigNumber(initial_balance).toString();
	// 	let initial_token = await crowdsale.tokenSold();
	// 	let initial_token_number = new web3.BigNumber(initial_token).toString();
	// 	let initial_eth = await crowdsale.ethRaised();
	// 	let initial_eth_number = new web3.BigNumber(initial_eth).toString();
	// 	console.log('initial balance: ', initial_balance);
	// 	console.log('initial token: ', initial_token);
	// 	console.log('initial eth in crowdsale: ', initial_eth);
	// 	console.log('initial balance number: ', initial_balance_number);
	// 	console.log('initial token number: ', initial_token_number);
	// 	console.log('initial eth number in crowdsale: ', initial_eth_number);

	// 	// let value = web3.toWei(1, 'wei');
	// 	// let value_number = new web3.BigNumber(value).toString();
	// 	// console.log('value: ', value);
	// 	// console.log('value number: ', value_number);
	// 	let value = 100; // 1 eth
		

	// 	console.log('address: ', StormCrowdsale.address);
	// 	let initial_storm = await stm.balanceOf(account1);
	// 	let initial_storm_number = new web3.BigNumber(initial_storm).toString();
	// 	console.log('token balance: ', initial_storm);
	// 	console.log('token balance number: ', initial_storm_number);

	// 	web3.eth.sendTransaction({
	// 		from: account1,
	// 		to: StormCrowdsale.address,
	// 		value: value,
	// 		gas: 4500000 //4,500,000
	// 	});

	// 	let post_balance = await web3.eth.getBalance(account1);
	// 	let post_balance_number = new web3.BigNumber(post_balance).toString();

	// 	let post_token = await crowdsale.tokenSold();
	// 	let post_token_number = new web3.BigNumber(post_token).toString();

	// 	let post_ethRaised = await crowdsale.ethRaised();
	// 	let post_ethRaised_number = new web3.BigNumber(post_ethRaised).toString();

	// 	console.log('test post_balance: ', big2Number(await web3.eth.getBalance(account1)));

	// 	console.log('post balance: ', post_balance);
	// 	console.log('post token: ', post_token);
	// 	console.log('post eth in crowdsale: ', post_ethRaised);

	// 	console.log('post balance number: ', post_balance_number);
	// 	console.log('post token number: ', post_token_number);
	// 	console.log('post eth number in crowdsale: ', post_ethRaised_number);
	// });
});

function big2Number(bigNumber) {
	let web3Big = new web3.BigNumber(bigNumber);
	return web3Big.toString();
}

// web3.eth.sendTransaction({from:accounts[0], to:"YOUR_CONTRACT_ADDRESS", value: web3.toWei(1, "ether")});
// await timeTravel(86400 * 3) //3 days later
// await mineBlock() // workaround for https://github.com/ethereumjs/testrpc/issues/336
