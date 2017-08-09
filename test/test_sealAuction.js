var GitToken = artifacts.require("./GitToken.sol");
var Promise = require("bluebird")
const { contributorAddress, username, name, organization, symbol, decimals } = require('../gittoken.config')


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
  describe('GitToken::initializeAuction', function() {

    it("Should create a reserved supply of tokens, initialize a new auction, and seal the auction with a weighted average price.", function() {
      var gittoken;
      var auctionRound;
      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.verifyContributor(accounts[0], username)
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "ContributorVerified", "Expected a `ContributorVerified` event")

        return gittoken.rewardContributor(username, "organization", "member_added", 0, "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.initializeAuction(5000, 1, true)
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "NewAuction", "Expected a `NewAuction` event")
        assert.equal(logs[0]['args']['auctionRound'], 1, "Expected Auction Round to be 1")

        auctionRound = logs[0]['args']['auctionRound']

        return gittoken.rewardContributor(username, "organization", "member_added", 0, "00000000-0000-0000-0000-000000000001")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.sealAuction(auctionRound, 7230);
      }).then(function(event) {
        console.log(event)
        const { logs } = event
        console.log(logs[0]['args'])
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "SealAuction", "Expected a `SealAuction` event")

        return gittoken.balanceOf(accounts[0])
      }).then(function(balance) {
        assert(balance.toNumber(), 1000, "Expected the balance of the user to be 1000")
      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    }).timeout(20000);

  })
})
