pragma solidity ^0.4.11;

import './SafeMath.sol';
import './GitTokenLib.sol';
import './Ownable.sol';


/**
 * @title GitToken Contract for distributing ERC20 tokens for Git contributions;
 * @author Ryan Michael Tate
 */
contract GitToken is Ownable {

  using SafeMath for uint;
  using GitTokenLib for GitTokenLib.Data;
  GitTokenLib.Data gittoken;

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
   * Contribution Event | Emitted when a GitHub contribution is broadcasted by web hook,
   * @param contributor   address Ethereum address of contributor,
   * @param username      string  GitHub username of contributor,
   * @param value         uint    Number of tokens created and distributed to contributor,
   * @param reservedValue uint    Number of tokens created and reserved for auction,
   * @param date          uint    Unix timestamp of when the contributor was rewarded,
   * @param rewardType    string  GitHub web hook event type (e.g. push, pull_request)
   */
  event Contribution(address indexed contributor, string username, uint value, uint reservedValue, uint date, string rewardType);

  /**
   * ContributionVerified Event | Emitted when a user verifies themselves on the UI using GitHub OAuth
   * @param contributor address Ethereum address of verified contributor,
   * @param username    string  GitHub username associated with contributor Ethereum address,
   * @param date        uint    Unix timestamp when user was verified;
   */
  event ContributorVerified(address indexed contributor, string username, uint date);

  /**
   * RewardValueSet Event | Emitted when the reward and reserved type values are changed
   * @param rewardType   string GitHub web hook event type,
   * @param reservedType string GitHub web hook action type (a subtype of rewardType; e.g. organization -> member_added),
   * @param value        uint   Updated value of reward or reserved Type
   * @param date         uint   Unix timestamp when reward values are reset
   * NOTE: This event is used by `setRewardValue()` and `setReservedValue()` methods
   */
  event RewardValueSet(string rewardType, string reservedType, uint value, uint date);

  /**
   * @dev Constructor method for GitToken Contract,
   * @param _contributor  address Ethereum Address of the primary contributor or organization owner,
   * @param _name         string  Name of the GitToken contract (name of organization),
   * @param _username     string  GitHub username of the primary contributor or organization owner,
   * @param _organization string  GitHub Organization as it appears in the GitHub organization URL (e.g. https://GitHub.com/git-token),
   * @param _symbol       string  Symbol of the GitToken contract,
   * @param _decimals     uint    Number of decimal representation for token balances;
   */
  function GitToken(
    address _contributor,
    string _name,
    string _username,
    string _organization,
    string _symbol,
    uint _decimals
  ) {
    if (_contributor != 0x0) { owner[_contributor] = true; }
    gittoken.totalSupply = 0;
    gittoken.name = _name;
    gittoken.organization = _organization;
    gittoken.symbol = _symbol;
    gittoken.decimals = _decimals;
    // Set initial contributor username & address
    gittoken.contributorUsernames[msg.sender] = _username;
    gittoken.contributorUsernames[_contributor] = _username;
    gittoken.contributorAddresses[_username] = _contributor;

    /*if(!gittoken._initRewardValues(_decimals)) {
      throw;
    } else if(!gittoken._initReservedValues(_decimals)) {
      throw;
    }*/

  }

  /**
   * @dev Returns the current total supply of tokens issued
   * @return _supply uint Supply of tokens currently issued
   * NOTE: Remember to adjust supply for decimals representation (e.g. supply / 10 ** decimals)
   */
  function totalSupply() constant returns (uint _supply) {
    return gittoken.totalSupply;
  }

  /**
   * @dev Returns the number of decimal places to adjust token values
   * @return _decimals uint Number of decimal places
   * NOTE: Remember to adjust token values for decimals representation (e.g. value / 10 ** decimals)
   */
  function decimals() constant returns (uint _decimals) {
    return gittoken.decimals;
  }

  /**
   * @dev Returns the string of the GitHub organization associated with the contract
   * @return _organization string GitHub organization (e.g. git-token)
   * NOTE: This value is used to make GitHub API calls; it must be associated with
   * the GitHub organization the web hook has been configured for.
   */
  function organization() constant returns (string _organization) {
    return gittoken.organization;
  }

  /**
   * @dev Returns the string of the token contract name
   * @return _name string Name of the token contract
   */
  function name() constant returns (string _name) {
    return gittoken.name;
  }

  /**
   * @dev Returns the string of the token contract symbol
   * @return _symbol string Symbol of the token contract
   */
  function symbol() constant returns (string _symbol) {
    return gittoken.symbol;
  }

  /**
   * @dev ERC20 `balanceOf` Method | Returns the balance of tokens associated with the address provided
   * @param  _holder      address Ethereum address to find token balance for
   * @return _balance     uint    Value of tokens held by ethereum address
   */
  function balanceOf(address _holder) constant returns (uint _balance) {
    return gittoken.balances[_holder];
  }

  /**
   * @dev ERC20 `transfer` Method | Transfer tokens to account from sender account
   * @param  _to      address Ethereum address to transfer tokens to,
   * @param  _value   uint    Number of tokens to transfer,
   * @return          bool    Returns boolean value if method is called
   */
  function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool) {
    if(!gittoken._transfer(_to, _value)) {
      throw;
    } else {
      Transfer(msg.sender, _to, _value);
      return true;
    }
  }

  /**
   * @dev ERC20 `transferFrom` Method | Allow approved spender (msg.sender) to transfer tokens from one account to another
   * @param  _from  address Ethereum address to move tokens from,
   * @param  _to    address Ethereum address to move tokens to,
   * @param  _value uint    Number of tokens to move between accounts,
   * @return        bool    Retrusn boolean value if method is called
   */
  function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) returns (bool) {
    if(!gittoken._transferFrom(_from, _to, _value)) {
      throw;
    } else {
      Transfer(_from, _to, _value);
      return true;
    }
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
  function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) returns (bool){
    if(_value > 0 && gittoken.allowed[msg.sender][_spender] > 0) {
      throw;
    } else {
      gittoken.allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
    }
  }

  /**
   * ERC20 `allowance` Method | Check the spender allowance for a token owner
   * @param  _owner     address Ethereum address of token owner,
   * @param  _spender   address Ethereum address of spender,
   * @return _allowance uint    Number of tokens allowed by the owner to be
   * moved by the spender
   */
  function allowance(address _owner, address _spender) constant returns (uint _allowance) {
    return gittoken.allowed[_owner][_spender];
  }


  /**
   * GitToken Setter (State Changing) Functions
   */
  function setRewardValue(
    uint256 _rewardValue,
    string _rewardType
  ) onlyOwner public returns (bool) {
    gittoken.rewardValues[_rewardType] = _rewardValue;
    RewardValueSet(_rewardType, '', _rewardValue, now);
    return true;
  }

  function setReservedValue(
    uint256 _reservedValue,
    string _rewardType,
    string _reservedType
  ) onlyOwner public returns (bool) {
    gittoken.reservedValues[_rewardType][_reservedType] = _reservedValue;
    RewardValueSet(_rewardType, _reservedType, _reservedValue, now);
    return true;
  }

  function verifyContributor(address _contributor, string _username) onlyOwner public returns (bool) {
    /*gittoken.usernameVerification[_username] = keccak256(_code);
    return true;*/
    if(!gittoken._verifyContributor(_contributor, _username)) {
      throw;
    } else {
      ContributorVerified(_contributor, _username, now);
      return true;
    }

  }

  function setContributor(string _username, bytes _code) public returns (bool) {
    if (!gittoken._setContributor(_username, _code)) {
      throw;
    } else {
      return true;
    }
  }

  function rewardContributor(
    string _username,
    string _rewardType,
    string _reservedType,
    uint _rewardBonus,
    string _deliveryID
  ) onlyOwner public returns (bool) {
    if(!gittoken._rewardContributor(_username, _rewardType, _reservedType, _rewardBonus, _deliveryID)) {
      throw;
    } else {
      address _contributor = gittoken.contributorAddresses[_username];
      uint _value = gittoken.rewardValues[_rewardType].add(_rewardBonus);
      uint _reservedValue = gittoken.reservedValues[_rewardType][_reservedType];
      Contribution(_contributor, _username, _value, _reservedValue, now, _rewardType);
      return true;
    }
  }


  /**
   * GitToken Getter Functions
   */

  function getRewardDetails(string _rewardType) constant returns (uint256) {
    return gittoken.rewardValues[_rewardType];
  }

  function getContributorAddress(string _username) constant returns (address) {
    return gittoken.contributorAddresses[_username];
  }

  function getContributorUsername(address _contributorAddress) constant returns (string) {
    return gittoken.contributorUsernames[_contributorAddress];
  }

  function getUnclaimedRewards(string _username) constant returns (uint) {
    return gittoken.unclaimedRewards[_username];
  }

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }


}
