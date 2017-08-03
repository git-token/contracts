const GitTokenLib = artifacts.require('./GitTokenLib.sol');
const GitToken = artifacts.require('./GitToken.sol');

module.exports = function(deployer) {
  deployer.deploy(GitTokenLib);
  deployer.link(GitTokenLib, GitToken);
};
