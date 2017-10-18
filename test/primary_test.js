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

	it('Check Contributor List non address', async function() {
		let result = await crowdsale.contributorList(account3);
		console.log('Contributor Data: ', result);
	});

	it('Sending Transaction = User is refunded', async function() {
		let initialEthBalanceOfUser = big2Number(await web3.eth.getBalance(account1));
		let initialStormBalanceOfUser = big2Number(await stm.balanceOf(account1));
		console.log('initial eth balance of user: ', initialEthBalanceOfUser);
		console.log('initial storm balance of user: ', initialStormBalanceOfUser);

		let initialTokenOfCrowdsale = big2Number(await crowdsale.tokenSold());
		let initialEthOfCrowdsale = big2Number(await crowdsale.ethRaised());
		console.log('initial token of crowdsale: ', initialTokenOfCrowdsale);
		console.log('initial eth of crowdsale: ', initialEthOfCrowdsale);

		let num_eth = 1; // 1 Eth

		let receiptAddress = await web3.eth.sendTransaction({
			from: account1,
			to: StormCrowdsale.address,
			value: num_eth,
			gas: 4500000
		});
		console.log('Transaction should refund');
		let transactionReceipt = await web3.eth.getTransactionReceipt(receiptAddress);
		let gasUsed = transactionReceipt.gasUsed;
		console.log('Transaction receipt: ', transactionReceipt);
		console.log('Gas used: ', transactionReceipt.gasUsed);

		let postEthBalanceOfUser = big2Number(await web3.eth.getBalance(account1));
		let postStormBalanceOfUser = big2Number(await stm.balanceOf(account1));
		console.log('post eth balance of user: ', postEthBalanceOfUser);
		console.log('post storm balance of user: ', postStormBalanceOfUser);

		let postTokenOfCrowdsale = big2Number(await crowdsale.tokenSold());
		let postEthOfCrowdsale = big2Number(await crowdsale.ethRaised());
		console.log('post token of crowdsale: ', postTokenOfCrowdsale);
		console.log('post eth of crowdsale: ', postEthOfCrowdsale);

		assert.equal(initialEthBalanceOfUser, postEthBalanceOfUser - gasUsed, 'check eth balance of user. should not change');
		assert.equal(initialStormBalanceOfUser, postStormBalanceOfUser, 'check storm balance of user. should not change');
		assert.equal(initialTokenOfCrowdsale, postTokenOfCrowdsale, 'check token balance of crowdsale. should not change');
		assert.equal(initialEthOfCrowdsale, postEthOfCrowdsale, 'check eth raised of crowdsale. should not change');
	});
});

function big2Number(bigNumber) {
	let web3Big = new web3.BigNumber(bigNumber);
	return web3Big.toString();
}

// web3.eth.sendTransaction({from:accounts[0], to:"YOUR_CONTRACT_ADDRESS", value: web3.toWei(1, "ether")});
// await timeTravel(86400 * 3) //3 days later
// await mineBlock() // workaround for https://github.com/ethereumjs/testrpc/issues/336
