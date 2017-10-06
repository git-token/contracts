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

function toBigNumber(value, decimals) {
  return value * Math.pow(10, decimals)
}

contract('GitToken', function(accounts) {
  describe('GitToken::rewardContributor', function() {
    it("Should reward a non-verified contributor for organization_member_added, verify the contributor, update the contributor's balance, then show 0 unclaimed rewards for the contributor", function() {
      var gittoken;
      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.rewardContributor('NewUser', "organization_member_added", toBigNumber(2500, decimals), toBigNumber(2500, decimals), "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        // console.log('logs', JSON.stringify(logs, null, 2))
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.getUnclaimedRewards('NewUser')
      }).then(function(unclaimedRewards) {
        assert.equal(unclaimedRewards.toNumber(), toBigNumber(2500, decimals), "Expected Unclaimed Rewards of contributor to be 2500")

        return gittoken.verifyContributor(contributorAddress, 'NewUser')
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs[0]['event'], "ContributorVerified", "Expected a `ContributorVerified` event")

        return gittoken.balanceOf.call(contributorAddress)
      }).then(function(balance) {
        assert.equal(balance.toNumber(), toBigNumber(2500, decimals), "Expected balance of contributor to be 2500")

        return gittoken.getUnclaimedRewards('NewUser')
      }).then(function(unclaimedRewards) {
        assert.equal(unclaimedRewards.toNumber(), 0, "Expected Unclaimed Rewards of contributor to be 0")

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

    it("Should reward a pre-verified contributor for organization_member_added, update the contributor's balance, then show 0 unclaimed rewards for the contributor", function() {
      var gittoken;
      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.rewardContributor(username, "organization_member_added", toBigNumber(2500, decimals), toBigNumber(2500, decimals), "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        // console.log('logs', JSON.stringify(logs, null, 2))
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.balanceOf.call(contributorAddress)
      }).then(function(balance) {
        assert.equal(balance.toNumber(), toBigNumber(2500, decimals), "Expected balance of contributor to be 2500")

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

        return gittoken.rewardContributor(username, "organization_member_added", toBigNumber(2500, decimals), toBigNumber(2500, decimals), "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.rewardContributor(username, "organization_member_added", toBigNumber(2500, decimals), toBigNumber(2500, decimals), "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 0, "Expected a thrown event")

        return gittoken.balanceOf(contributorAddress)
      }).then(function(balance) {
        assert.equal(balance.toNumber(), toBigNumber(2500, decimals), "Expected balance to be 2500")

      }).catch(function(error) {
        assert.notEqual(error, null, error.message)
      })
    })

  })
})
