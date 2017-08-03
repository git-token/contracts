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
  describe('GitToken::rewardContributor', function() {

    it("Should reward a pre-verified contributor for creating a repo, verify the contributor, update the contributor's balance, then show 0 unclaimed rewards for the contributor", function() {
      var gittoken;
      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.rewardContributor(username, "create", "", 0, "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.getUnclaimedRewards(username)
      }).then(function(unclaimedRewards) {
        assert.equal(unclaimedRewards.toNumber(), 2500 * Math.pow(10, decimals), "Expected Unclaimed Rewards of contributor to be 2500 * Math.pow(10, decimals)")

        return gittoken.verifyContributor(contributorAddress, username)
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs[0]['event'], "ContributorVerified", "Expected a `ContributorVerified` event")

        return gittoken.balanceOf.call(contributorAddress)
      }).then(function(balance) {
        assert.equal(balance.toNumber(), 2500 * Math.pow(10, decimals), "Expected balance of contributor to be 2500 * Math.pow(10, decimals)")

        return gittoken.getUnclaimedRewards(username)
      }).then(function(unclaimedRewards) {
        assert.equal(unclaimedRewards.toNumber(), 0, "Expected Unclaimed Rewards of contributor to be 0")

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

    it("Should prevent duplicate GitHub web hook events from rewarding tokens", function() {
      var gittoken;
      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.verifyContributor(contributorAddress, username)
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs[0]['event'], "ContributorVerified", "Expected a `ContributorVerified` event")

        return gittoken.rewardContributor(username, "create", "", 0, "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.rewardContributor(username, "create", "", 0, "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 0, "Expected a thrown event")

        return gittoken.balanceOf(contributorAddress)
      }).then(function(balance) {
        assert.equal(balance.toNumber(), 2500 * Math.pow(10, decimals), "Expected balance to be 2500")

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

  })
})
