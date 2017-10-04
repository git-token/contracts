var GitTokenRegistry = artifacts.require("./GitTokenRegistry.sol");
var Promise = require("bluebird")
const { contributorAddress } = require('../gittoken.config')


function initContract() {
  return new Promise((resolve, reject) => {
    GitTokenRegistry.new(contributorAddress).then(function(registry) {
      resolve(registry)
    }).catch(function(error) {
      reject(error)
    })
  })
}

contract('GitTokenRegistry', function(accounts) {
  describe('GitTokenRegistry::registerToken', function() {

    it("Should register an organization token and emit a Registration event.", function() {
      var registry;
      return initContract().then((contract) => {
        registry = contract
        return registry.registerToken('git-token', '0x8CB2CeBB0070b231d4BA4D3b747acAebDFbbD142')
      }).then(function(event) {
        const { logs } = event
        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Registration", "Expected a `Registration` event")

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

  })
})
