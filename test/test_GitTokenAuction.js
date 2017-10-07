var GitToken = artifacts.require("./GitToken.sol");
var GitTokenAuction = artifacts.require("./GitTokenAuction.sol");
var Promise = require("bluebird")
const { contributorAddress, username, name, organization, symbol, decimals } = require('../gittoken.config')


function initGitTokenContract() {
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

function initGitTokenAuctionContract(GitTokenContract) {
  return new Promise((resolve, reject) => {
    GitTokenAuction.new(
      GitTokenContract
    ).then(function(contract) {
      resolve(contract)
    }).catch(function(error) {
      reject(error)
    })
  })
}

function toBigNumber(value, decimals) {
  return value * Math.pow(10, decimals)
}

contract('GitTokenAuction', function(accounts) {
  describe('GitTokenAuction::getSupply', function() {

    it("It should get the supply of the GitToken contract from with the GitTokenAuction contract", function() {
      var gittoken;
      var gittokenAuction
      return initGitTokenContract().then((contract) => {
        gittoken = contract

        return gittoken.rewardContributor(username, "organization_member_added", toBigNumber(2500, decimals), toBigNumber(2500, decimals), "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        // console.log('logs', JSON.stringify(logs, null, 2))
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return initGitTokenAuctionContract(gittoken.address)
      }).then((contract) => {
        gittokenAuction = contract
        return gittokenAuction.getSupply()
      }).then((supply) => {
        assert.equal(supply.toNumber(), toBigNumber(5000, decimals), `Expected supply to equal ${toBigNumber(5000, decimals)}`)
      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

  })
})
