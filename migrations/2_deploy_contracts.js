const Registry = artifacts.require('./Registry.sol');
const { signer } = require('../gittoken.config.js')

module.exports = function(deployer) {
  deployer.deploy(
    Registry,
    signer
  ).then((contract) => {
    console.log('contract', contract)
  }).catch((error) => {
    console.log('error', error)
  });

};
