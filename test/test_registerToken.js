var GitTokenRegistry = artifacts.require("./GitTokenRegistry.sol");
var GitToken = artifacts.require("./GitToken.sol");
var Promise = require("bluebird")
const {
  admin,
  username,
  name,
  organization,
  symbol,
  decimals,
  signer,
} = require('../gittoken.config')


function initRegistry() {
  return new Promise((resolve, reject) => {
    GitTokenRegistry.new(
      signer
    ).then(function(registry) {
      resolve(registry)
    }).catch(function(error) {
      reject(error)
    })
  })
}

function initGitToken({ registry }) {
  return new Promise((resolve, reject) => {
    GitToken.new(
      organization,
      name,
      symbol,
      decimals,
      signer,
      admin,
      username
    ).then(function(gittoken) {
      resolve(gittoken)
    }).catch(function(error) {
      reject(error)
    })
  })
}

contract('GitTokenRegistry', function(accounts) {
  describe('GitTokenRegistry::registerToken', function() {

    it("Should register an organization token and emit a Registration event.", function() {
      var registry;
      var gittoken;
      return initRegistry().then((contract) => {
        registry = contract
        return registry.registerToken(
          organization,
          name,
          symbol,
          decimals,
          admin,
          username
        );
      }).then((event) => {
        const { logs } = event
        const { args: { _organization, _symbol } } = logs[0]
        console.log(JSON.stringify(logs, null, 2))

        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Registration", "Expected a `Registration` event")
        assert.equal(_organization, organization, `Expected registered organization, ${_organization} to equal, ${organization}`)
        assert.equal(_symbol, symbol, `Expected registered symbol, ${_symbol} to equal, ${symbol}`)
        
      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

  })
})
