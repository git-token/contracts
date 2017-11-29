const Registry = artifacts.require('./Registry.sol');
const { registrationFee } = require('../gittoken.config.js')

module.exports = function(deployer) {
  deployer.deploy(
    Registry,
    registrationFee
  ).then((contract) => {
    console.log('contract', contract)
  }).catch((error) => {
    console.log('error', error)
  });

};
