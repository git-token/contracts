pragma solidity ^0.4.15;

import './GitToken.sol';

contract GitTokenAuction {

  GitToken token;

  function GitTokenAuction(address _GitTokenContract) {
    token = GitToken(_GitTokenContract);
  }

  function getSupply() constant returns (uint) {
    return token.totalSupply();
  }

}
