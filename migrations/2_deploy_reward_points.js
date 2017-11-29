const RewardPoints = artifacts.require('./RewardPoints.sol');
const { admin } = require('../gittoken.config.js')

module.exports = function(deployer) {
  deployer.deploy(
    RewardPoints,
    admin
  ).then((contract) => {
    console.log('contract', contract)
  }).catch((error) => {
    console.log('error', error)
  });

};
