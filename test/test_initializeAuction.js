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

    it("Should create a reserved supply of tokens, initialize a new auction, and lock external token transfers.", function() {
      var gittoken;
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

        return gittoken.initializeAuction(5000 * Math.pow(10, decimals), 0, true)
      }).then(function(event){
        const { logs } = event
        console.log(event)
        console.log(logs[0]['args'])
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "NewAuction", "Expected a `NewAuction` event")

        return gittoken.transfer("0x8CB2CeBB0070b231d4BA4D3b747acAebDFbbD142", 100e8)
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs.length, 0, "Expected the transfer event to fail until auction end date has passed")

        return gittoken.balanceOf(accounts[0])
      }).then(function(balance) {
        assert(balance.toNumber(), 1000 * Math.pow(10, decimals), "Expected the balance of the user to be 1000 * Math.pow(10, decimals)")
      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

    it("Should create a reserved supply of tokens, initialize a new auction, and allow external token transfers.", function() {
      var gittoken;
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

        return gittoken.initializeAuction(5000 * Math.pow(10, decimals), 0, false)
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "NewAuction", "Expected a `NewAuction` event")

        return gittoken.transfer("0x8CB2CeBB0070b231d4BA4D3b747acAebDFbbD142", 100e8)
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Transfer", "Expected a `Transfer` event")

        return gittoken.balanceOf(accounts[0])
      }).then(function(balance) {
        assert(balance.toNumber(), 1000 * Math.pow(10, decimals), "Expected the balance of the user to be 1000")
      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

    it("Should not allow an exchange rate greater than the total token supply", function() {
      var gittoken;
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

        return gittoken.initializeAuction(20000 * Math.pow(10, decimals), 0, false)
      }).then(function(event){
        console.log(event)
        const { logs } = event
        assert.equal(logs.length, 0, "Expected no events from transaction")

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

  })
})
