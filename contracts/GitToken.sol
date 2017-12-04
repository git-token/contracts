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

import './Signed.sol';
import './SafeMath.sol';

/**
 * @title GitToken Contract for distributing ERC20 tokens for Git contributions;
 * @author Ryan Michael Tate <ryan.tate@gittoken.io>
 */
contract GitToken is Signed {

  using SafeMath for uint;
  using SafeMath for uint[];

  string public name;
  string public symbol;
  string public organization;
  uint256 public decimals;
  uint256 public supply;
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  mapping(address => bool) admins;
  mapping(string => address) contributors;

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

  /**
   * Distribute Event | Emitted when the signer Distributes tokens to contributors;
   * Event is called when a token distribution event is triggered (e.g. milestone reached)
   * @param to address Ethereum address of tokens to distribute to
   * @param value Number of tokens distributed to Ethereum address
   */
  event Distributed(address to, uint value);

  function GitToken(
    string _organization,
    string _name,
    string _symbol,
    uint256 _decimals,
    address _admin,
    string _adminUsername
  ) Signed(msg.sender) public {

    // Set Token Details
    supply = 0;
    decimals = _decimals;
    name = _name;
    organization = _organization;
    symbol = _symbol;

    // Set Admin Settings
    admins[_admin] = true;
    contributors[_adminUsername] = _admin;
  }

  /**
   * @dev Returns the current total supply of tokens issued
   * returns _supply uint Supply of tokens currently issued
   * NOTE: Remember to adjust supply for decimals representation (e.g. supply / 10 ** decimals)
   */
  function totalSupply() public constant returns (uint _supply) {
    return supply;
  }

  /**
   * @dev Returns the number of decimal places to adjust token values
   * returns _decimals uint Number of decimal places
   * NOTE: Remember to adjust token values for decimals representation (e.g. value / 10 ** decimals)
   */
  function decimals() public constant returns (uint _decimals) {
    return decimals;
  }

  /**
   * @dev Returns the string of the GitHub organization associated with the contract
   * returns _organization string GitHub organization (e.g. git-token)
   * NOTE: This value is used to make GitHub API calls; it must be associated with
   * the GitHub organization the web hook has been configured for.
   */
  function organization() public constant returns (string _organization) {
    return organization;
  }

  /**
   * [contributor description]
   * @param  _username string GitHub Username
   * returns _contributor address associated with GitHub username
   */
  function contributor(string _username) public view returns (address _contributor) {
    return  contributors[_username];
  }

  /**
   * External method to check if an Ethereum address is an admin of this contract
   * @param  _contributor  address of contributor
   * returns
   */
  function isAdmin(address _contributor) public view returns(bool) {
    return admins[_contributor];
  }

  /**
   * External method to check if an Ethereum address is the signer of this contract
   * @param  _signer  address of contributor
   * returns
   */
  function isSigner(address _signer) public view returns(bool) {
    return signer == _signer;
  }

  /**
   * @dev Returns the string of the token contract name
   * returns _name string Name of the token contract
   */
  function name() public constant returns (string _name) {
    return name;
  }

  /**
   * @dev Returns the string of the token contract symbol
   * returns _symbol string Symbol of the token contract
   */
  function symbol() public constant returns (string _symbol) {
    return symbol;
  }

  /**
   * @dev ERC20 `balanceOf` Method | Returns the balance of tokens associated with the address provided
   * @param  _holder      address Ethereum address to find token balance for
   * returns _balance     uint    Value of tokens held by ethereum address
   */
  function balanceOf(address _holder) public constant returns (uint _balance) {
    return balances[_holder];
  }

  /**
   * @dev ERC20 `allowance` Method | Check the spender allowance for a token owner
   * @param  _owner     address Ethereum address of token owner,
   * @param  _spender   address Ethereum address of spender,
   * returns _allowance uint    Number of tokens allowed by the owner to be
   * moved by the spender
   */
  function allowance(address _owner, address _spender) public constant returns (uint _allowance) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev ERC20 `transfer` Method | Transfer tokens to account from sender account
   * @param  _to      address Ethereum address to transfer tokens to,
   * @param  _value   uint    Number of tokens to transfer,
   * returns          bool    Returns boolean value if method is called
   */
  function transfer(address _to, uint _value ) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev ERC20 `transferFrom` Method | Allow approved spender (msg.sender) to transfer tokens from one account to another
   * @param  _from  address Ethereum address to move tokens from,
   * @param  _to    address Ethereum address to move tokens to,
   * @param  _value uint    Number of tokens to move between accounts,
   * returns        bool    Retrusn boolean value if method is called
   */
  function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3) returns (bool) {
    // Check if msg.sender has sufficient allowance;
    // Check is handled by SafeMath library _allowance.sub(_value);
    // Set new allowance after subtracting the value from the allowance
    uint _allowance = allowed[_from][msg.sender];
    allowed[_from][msg.sender] = _allowance.sub(_value);

    // Update balances
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev ERC20 `approve` Method | Approve spender to transfer an amount of
   * tokens on behalf of another account
   * @param  _spender address Ethereum address of spender to approve,
   * @param  _value   uint    Number of tokens to approve spender to transfer,
   * returns          bool    Returns boolean value is method is called;
   * NOTE: Explicitly check if the approved address already has an allowance,
   * Ensure the approver must reset the approved value to 0 before changing to the desired amount.
   * see: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   */
  function approve(address _spender,uint _value) public onlyPayloadSize(2) returns (bool success) {
    require(_value == 0 || allowed[msg.sender][_spender] == 0);
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * Distribute GitTokens to contributors; Method is only used by the authorized signer
   * @param  _recipients address[] Array of addresses to distribute tokens to
   * @param  _values uint[]    Array of token values to distribute to contributors
   * returns bool
   */
  function distribute(address[] _recipients, uint256[] _values) onlySigner public returns (bool success) {
    require(_recipients.length == _values.length);
    for (uint i = 0; i < _recipients.length; i++) {
        balances[_recipients[i]] = balances[_recipients[i]].add(_values[i]);
        Distributed(_recipients[i], _values[i]);
    }

    supply = supply.add(_values.sum());

    return true;
  }


  /**
   * Fallback function; does nothing; reverts the transaction
   */
  function() public {
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
