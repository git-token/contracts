/**
 Copyright 2017-2018 GitToken

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.15;


/**
 * @title GitToken Contract for distributing ERC20 tokens for Git contributions;
 * @author Ryan Michael Tate <ryan.tate@gittoken.io>
 */
contract GitToken {

  struct Data {
    uint totalSupply;
    uint decimals;
    string name;
    string organization;
    string symbol;
    address signer;
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

  function GitToken(
    string _organization,
    string _name,
    string _symbol,
    uint256 _decimals,
    address _signer,
    address _admin,
    string _username
  ) public {

    // Set Token Details
    data.totalSupply = 0;
    data.decimals = _decimals;
    data.name = _name;
    data.organization = _organization;
    data.symbol = _symbol;

    // Set Operator Settings
    data.signer = _signer;
    data.admin[_admin] = true;
    data.username = _username;
  }

  /**
   * @dev Returns the current total supply of tokens issued
   * @return _supply uint Supply of tokens currently issued
   * NOTE: Remember to adjust supply for decimals representation (e.g. supply / 10 ** decimals)
   */
  function totalSupply() public constant returns (uint _supply) {
    return data.totalSupply;
  }

  /**
   * @dev Returns the number of decimal places to adjust token values
   * @return _decimals uint Number of decimal places
   * NOTE: Remember to adjust token values for decimals representation (e.g. value / 10 ** decimals)
   */
  function decimals() public constant returns (uint _decimals) {
    return data.decimals;
  }

  /**
   * @dev Returns the string of the GitHub organization associated with the contract
   * @return _organization string GitHub organization (e.g. git-token)
   * NOTE: This value is used to make GitHub API calls; it must be associated with
   * the GitHub organization the web hook has been configured for.
   */
  function organization() public constant returns (string _organization) {
    return data.organization;
  }

  /**
   * @dev Returns the string of the token contract name
   * @return _name string Name of the token contract
   */
  function name() public constant returns (string _name) {
    return data.name;
  }

  /**
   * @dev Returns the string of the token contract symbol
   * @return _symbol string Symbol of the token contract
   */
  function symbol() public constant returns (string _symbol) {
    return data.symbol;
  }

  /**
   * @dev ERC20 `balanceOf` Method | Returns the balance of tokens associated with the address provided
   * @param  _holder      address Ethereum address to find token balance for
   * @return _balance     uint    Value of tokens held by ethereum address
   */
  function balanceOf(address _holder) public constant returns (uint _balance) {
    return data.balances[_holder];
  }

  /**
   * @dev ERC20 `transfer` Method | Transfer tokens to account from sender account
   * @param  _to      address Ethereum address to transfer tokens to,
   * @param  _value   uint    Number of tokens to transfer,
   * @return          bool    Returns boolean value if method is called
   */
  function transfer(address _to, uint _value ) public returns (bool) {
    /*require(gittoken._transfer(_to, _value));*/
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev ERC20 `transferFrom` Method | Allow approved spender (msg.sender) to transfer tokens from one account to another
   * @param  _from  address Ethereum address to move tokens from,
   * @param  _to    address Ethereum address to move tokens to,
   * @param  _value uint    Number of tokens to move between accounts,
   * @return        bool    Retrusn boolean value if method is called
   */
  function transferFrom(address _from, address _to, uint _value)
    public
    onlyPayloadSize(3)
    returns (bool)
  {
    /*require(gittoken._transferFrom(_from, _to, _value));*/
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev ERC20 `approve` Method | Approve spender to transfer an amount of
   * tokens on behalf of another account
   * @param  _spender address Ethereum address of spender to approve,
   * @param  _value   uint    Number of tokens to approve spender to transfer,
   * @return          bool    Returns boolean value is method is called;
   * NOTE: Explicitly check if the approved address already has an allowance,
   * Ensure the approver must reset the approved value to 0 before changing to the desired amount.
   * see: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   */
  function approve (
    address _spender,
    uint _value
    )
    public
    onlyPayloadSize(2)
    returns (bool)
  {
    require(_value == 0 && data.allowed[msg.sender][_spender] == 0);
    data.allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev ERC20 `allowance` Method | Check the spender allowance for a token owner
   * @param  _owner     address Ethereum address of token owner,
   * @param  _spender   address Ethereum address of spender,
   * @return _allowance uint    Number of tokens allowed by the owner to be
   * moved by the spender
   */
  function allowance(address _owner, address _spender)
    public
    constant
    returns (uint _allowance)
  {
    return data.allowed[_owner][_spender];
  }

  /**
   * Fallback function; does nothing; reverts the transaction
   */
  function () public {
    revert();
  }

  /**
   * @dev This modifier checks the data length to ensure that it matches the padded
   * length of the input data provided to the method.
   */
  modifier onlyPayloadSize(uint inputLength) {
     require(msg.data.length == inputLength * 32 + 4);
     _;
  }
}
