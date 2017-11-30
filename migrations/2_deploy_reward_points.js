const RewardPoints = artifacts.require('./RewardPoints.sol');
const { decimals } = require('../gittoken.config.js')

module.exports = function(deployer) {
  deployer.deploy(
    RewardPoints,
    decimals
  ).then((contract) => {
    console.log('contract', contract)
  }).catch((error) => {
    console.log('error', error)
  });

};
