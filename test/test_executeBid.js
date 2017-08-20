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

    it("Should create a reserved supply of tokens, initialize a new auction, and execute a bid.", function() {
      var gittoken;
      var auctionRound;
      var startDate;
      var endDate;
      var tokensOffered;
      var initialExRate;
      var fundLimit;
      var fundsCollected;

      var exRate;
      var wtdAvgExRate;
      var tokensTransferred;
      var etherPaid;
      var refundAmount;

      return initContract().then((contract) => {
        gittoken = contract

        return gittoken.verifyContributor(contributorAddress, username)
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "ContributorVerified", "Expected a `ContributorVerified` event")

        return gittoken.rewardContributor(username, "milestone", "closed", 0, "00000000-0000-0000-0000-000000000000")
      }).then(function(event){
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Contribution", "Expected a `Contribution` event")

        return gittoken.initializeAuction(5000 * Math.pow(10, decimals), 1, 20, true)
      }).then(function(event){
        const { logs } = event


        auctionRound  = logs[0]['args']['auctionDetails'][0]
        startDate     = logs[0]['args']['auctionDetails'][1]
        endDate       = logs[0]['args']['auctionDetails'][2]
        tokensOffered = logs[0]['args']['auctionDetails'][4]
        initialExRate = logs[0]['args']['auctionDetails'][5]
        fundLimit     = logs[0]['args']['auctionDetails'][6]


        assert.equal(8, logs[0]['args']['auctionDetails'].length, "Expected the length of auctionDetails to be 9")
        assert.equal(fundLimit, tokensOffered * (1e18 / initialExRate), "Expected the fund limit to equal tokensOffered * (1e18 / initialExRate)")
        assert.equal(logs.length, 1, "Expected a logged event")
        assert.equal(logs[0]['event'], "Auction", "Expected a `Auction` event")
        assert.equal(auctionRound, 1, "Expected Auction Round to be 1")

        let delay = new Date(startDate * 1000).getTime() - new Date().getTime()
        return Promise.delay(delay, gittoken.executeBid(auctionRound.toNumber(), 5000 * Math.pow(10, decimals), {
          from: accounts[1],
          value: 1e18,
          gasPrice: 1e9
        }))

      }).then(function(event) {
        const { logs } = event

        auctionRound      = logs[0]['args']['bidDetails'][0]
        exRate            = logs[0]['args']['bidDetails'][1]
        wtdAvgExRate      = logs[0]['args']['bidDetails'][2]
        tokensTransferred = logs[0]['args']['bidDetails'][3]
        etherPaid         = logs[0]['args']['bidDetails'][4]
        refundAmount      = logs[0]['args']['bidDetails'][5]
        fundsCollected    = logs[0]['args']['bidDetails'][6]
        fundLimit         = logs[0]['args']['bidDetails'][7]
        date              = logs[0]['args']['bidDetails'][8]

        assert.equal(9, logs[0]['args']['bidDetails'].length, "Expected the length of bidDetails to be 9")
        assert.equal(logs.length, 1, "Expected a logged event")
        assert.equal(logs[0]['event'], "AuctionBid", "Expected a `AuctionBid` event")
        assert.equal(fundsCollected, 4e17, "Expected funds collected to be equal to 0.4 ETH")
        assert.isAtLeast(date.toNumber(), startDate.toNumber(), "Expected bid date to be greater than or equal to the start date")

        return gittoken.balanceOf(accounts[1])
      }).then(function(balance) {
        assert.equal(balance, tokensTransferred.toNumber(), `Expected the ${balance} of the user to be ${tokensTransferred}`)

        return web3.eth.getBalance(gittoken.address)
      }).then(function(balance) {

        assert.equal(balance, fundsCollected, `Expected the ${balance} of the contract to be ${fundsCollected}`)

        return gittoken.getAuctionDetails(auctionRound.toNumber())
      }).then((auctionDetails) => {

        assert.equal(wtdAvgExRate, auctionDetails[0][6].toNumber(), "Expected wtdAvgExRate to equal auction details value");
        assert.equal(fundsCollected, auctionDetails[0][7].toNumber(), "Expected funds collected to equal auction details value");
        assert.equal(fundLimit, auctionDetails[0][8].toNumber(), "Expected fund limit to equal auction details value");

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    }).timeout(20000);

  })
})
