var Registry = artifacts.require("./Registry.sol");
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
    Registry.new(
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

contract('Registry', function(accounts) {
  describe('Registry::registerToken', function() {

    it(`Should create and register an organization token and emit a 'Registration' event.`, function() {
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
        const { args: { _organization, _symbol, _token } } = logs[0]
        console.log(JSON.stringify(logs, null, 2))

        gittoken = _token

        assert.equal(logs.length, 1, "Expect a logged event")
        assert.equal(logs[0]['event'], "Registration", "Expected a `Registration` event")
        assert.equal(_organization, organization, `Expected registered organization, ${_organization} to equal, ${organization}`)
        assert.equal(_symbol, symbol, `Expected registered symbol, ${_symbol} to equal, ${symbol}`)

        return registry.getOrganizationToken(organization)
      }).then((token) => {
        assert.equal(gittoken, token, `Expected registered token, ${gittoken} to equal, ${token}`)
      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })

  })
})
