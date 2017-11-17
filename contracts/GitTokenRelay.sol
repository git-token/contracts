pragma solidity ^0.4.15;

import './RewardPoints.sol';


contract GitTokenRelay {

  struct Data {
    uint totalSupply;
    uint decimals;
    string name;
    string organization;
    string symbol;
    address registry;
    string username;
    mapping(address => bool) admin;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) balances;
  }

  Data public data;

  /**
   * ERC20 Approval Event | Emitted when a spender is approved by an owner
   * @param owner   address Ethereum address of owner of tokens,
   * @param spender address Ethereum address of approved spender of tokens,
   * @param value   uint    Number of tokens to approve spender for;
   */
  event Approval(address indexed owner, address indexed spender, uint value);

  /**
   * ERC20 Transfer Event | Emitted when a transfer is made between accounts
   * @param from  address Ethereum address of tokens sent from,
   * @param to    address Ethereum address of tokens sent to,
   * @param value uint    Number of tokens to transfer;
   */
  event Transfer(address indexed from, address indexed to, uint value);


  function GitTokenRelay(
    string _organization,
    string _name,
    string _symbol,
    uint256 _decimals,
    address _registry, // Torvalds Registry
    address _admin, // GitHub Organization Admin Ethereum Address (Used on both networks)
    string _username // GitHub Organization Admin Username
  ) RewardPoints(_decimals) public {

    // Set Token Details
    data.totalSupply = 0;
    data.decimals = _decimals;
    data.name = _name;
    data.organization = _organization;
    data.symbol = _symbol;

    // Set Operator Settings
    data.registry = _registry;
    data.admin[_admin] = true;
    data.username = _username;
  }

}
