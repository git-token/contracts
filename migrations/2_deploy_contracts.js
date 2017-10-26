const GitTokenRegistry = artifacts.require('./GitTokenRegistry.sol');
const { signer } = require('../gittoken.config.js')

module.exports = function(deployer) {
  deployer.deploy(
    GitTokenRegistry,
    signer
  ).then((contract) => {
    console.log('contract', contract)
  }).catch((error) => {
    console.log('error', error)
  });

};
