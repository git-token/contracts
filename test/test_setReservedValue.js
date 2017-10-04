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
  describe('GitToken::setReservedValue', function() {

    it("Should set the reserve value from `0` to `15000` for `milestone` `created` event", function() {
      var gittoken;
      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.setReservedValue(15000 * Math.pow(10, decimals), "milestone", "created")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "RewardValueSet", "Expected a `RewardValueSet` event")

        return gittoken.rewardContributor(username, "milestone", "created", 0, "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.balanceOf(gittoken.address)
      }).then(function(balance) {
        assert.equal(balance.toNumber(), 15000 * Math.pow(10, decimals), "Expected Unclaimed Rewards of contributor to be 15000 * Math.pow(10, decimals)")

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })
  })
})
