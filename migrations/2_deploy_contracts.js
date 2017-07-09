const GitTokenLib = artifacts.require('./GitTokenLib.sol');
const GitToken = artifacts.require('./GitToken.sol');

const {
  contributorAddress,
  email,
  organization,
  symbol,
  decimals
} = require('../gittoken.config')

module.exports = function(deployer) {
  deployer.deploy(GitTokenLib);
  deployer.link(GitTokenLib, GitToken);
  GitToken.new(
    contributorAddress,
    email,
    organization,
    symbol,
    decimals
  ).then((instance) => {
    console.log(`GitToken Contract Deployed at ${instance.address}`)
  }).catch((error) => {
    console.log('error', error)
  });
};
