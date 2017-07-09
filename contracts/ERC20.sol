pragma solidity ^0.4.11;

/**
 * @title ERC20 Interface
 * @dev Interface version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function transfer(address to, uint value);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);

  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
}
