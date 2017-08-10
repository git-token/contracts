var GitToken = artifacts.require("./GitToken.sol");
var Promise = require("bluebird")
const { contributorAddress, username, name, organization, symbol, decimals } = require('../gittoken.config')
const { networks: { development: { host, port } } } = require('../truffle.js');

var Web3 = require('web3')
var web3 = new Web3(new Web3.providers.HttpProvider(`http://${host}:${port}`))

function initContract() {
  return new Promise((resolve, reject) => {
    GitToken.new(
      contributorAddress,
      username,
      name,
      organization,
      symbol,
      decimals
    ).then(function(gittoken) {
      resolve(gittoken)
    }).catch(function(error) {
      reject(error)
    })
  })
}

contract('GitToken', function(accounts) {
  describe('GitToken::executeBid', function() {

    it("Should create a reserved supply of tokens, initialize a new auction, and seal the auction with a weighted average price, and attempt to execute a bid at the weighted average price.", function() {
      var gittoken;
      var auctionRound;
      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.verifyContributor(contributorAddress, username)
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "ContributorVerified", "Expected a `ContributorVerified` event")

        return gittoken.rewardContributor(username, "organization", "member_added", 0, "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.initializeAuction(5000 * Math.pow(10, decimals), 1, true)
      }).then(function(event){
        const { logs } = event

        console.log(logs[0]['args'])

        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "NewAuction", "Expected a `NewAuction` event")
        assert.equal(logs[0]['args']['auctionRound'], 1, "Expected Auction Round to be 1")

        auctionRound = logs[0]['args']['auctionRound']

        return gittoken.rewardContributor(username, "organization", "member_added", 0, "00000000-0000-0000-0000-000000000001")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.sealAuction(auctionRound, 7230 * Math.pow(10, decimals));
      }).then(function(event) {
        console.log(event)
        const { logs } = event
        console.log(logs[0]['args'])
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "SealAuction", "Expected a `SealAuction` event")

        return gittoken.executeBid(auctionRound, { from: accounts[1], value: 50e18 })
      }).then(function(event) {
        console.log(event)
        const { logs } = event
        console.log(logs[0]['args'])
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Transfer", "Expected a `Transfer` event")

        return gittoken.balanceOf(accounts[1])
      }).then(function(balance) {
        assert.isAtLeast(balance.toNumber(), 15000 * Math.pow(10, decimals), "Expected the balance of the user to be 15000 * Math.pow(10, decimals)")

        return web3.eth.getBalance(gittoken.address)
      }).then(function(balance) {
        var fundLimit = (15000 * Math.pow(10, decimals)) * (1e18 / (7230 * Math.pow(10, decimals))) / 1e18
        assert.isAtLeast((parseInt(balance.toString()) / 1e18).toFixed(3), fundLimit.toFixed(3), "Expected the balance of the user to be 15000 * Math.pow(10, decimals)")

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    }).timeout(20000);

  })
})
