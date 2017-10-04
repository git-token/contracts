const GitTokenLib = artifacts.require('./GitTokenLib.sol');
const GitToken = artifacts.require('./GitToken.sol');

module.exports = function(deployer) {
  deployer.deploy(GitTokenLib);
  deployer.link(GitTokenLib, GitToken);
  deployer.deploy(
    GitToken,
    "0x8da299e2184ea12624cd588006e24a78f2f90594",
    "GitToken",
    "ryanmtate",
    "git-token",
    "GTK",
    8
  )
};
