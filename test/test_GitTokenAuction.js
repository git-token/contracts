var Promise = require("bluebird")
var toPowerOf = require('../utils/toPowerOf.js')
var GitToken = artifacts.require("./GitToken.sol");
var GitTokenAuction = artifacts.require("./GitTokenAuction.sol");

const { organization, name, symbol, decimals, admin, username } = require('../gittoken.config')

function initGitToken() {
  return new Promise((resolve, reject) => {
    GitToken.new(
      organization,
      name,
      symbol,
      decimals,
      admin,
      username
    ).then(function(gittoken) {
      resolve(gittoken)
    }).catch(function(error) {
      reject(error)
    })
  })
}

function initAuction() {
  return new Promise((resolve, reject) => {
    GitTokenAuction.new().then(function(auction) {
      resolve(auction)
    }).catch(function(error) {
      reject(error)
    })
  })
}

contract('GitTokenAuction', function(accounts) {
  describe('GitTokenAuction::init', function() {
    it("Should distribute tokens to the auction contract and initialize a new auction", function() {
      var gittoken;
      var auction;
      return initGitToken().then((_gittoken) => {
        gittoken = _gittoken;
        return initAuction()
      }).then((_auction) => {
        auction = _auction;
        return gittoken.distribute([ auction.address ], [ toPowerOf(1000, decimals) ])
      }).then((result) => {
        const { logs } = result
        assert.equal(logs.length, 1, "Expected Logs")

        return gittoken.balanceOf(auction.address)
      }).then((balance) => {
        assert.equal(balance.toNumber(), toPowerOf(1000, decimals), `Expected Balance to equal ${toPowerOf(1000, decimals)}`)

        return auction.init(gittoken.address, 1e15)
      }).then((result) => {
        const { logs } = result
        const tokens = logs[0]['args']['tokensOffered'].toNumber()
        assert.equal(tokens, toPowerOf(1000, decimals), `Expected tokens offerred to equal ${toPowerOf(1000, decimals)}`)

        return auction.bid(gittoken.address, 1e15, { value: 5e17 })
      }).then((result) => {
        const { logs } = result

        console.log(JSON.stringify(result, null, 2))
      }).catch((error) => {
        assert.equal(error, null, error)
      })
    }).timeout(20000);
  })
})
