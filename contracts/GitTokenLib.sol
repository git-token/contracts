pragma solidity ^0.4.11;

import './SafeMath.sol';

library GitTokenLib {

  using SafeMath for uint;

  struct Data {
    uint totalSupply;
    uint decimals;
    string organization;
    string symbol;
    mapping(string => uint256) rewardValues;
    mapping(address => string) contributorEmails;
    mapping(string => address) contributorAddresses;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) balances;
    mapping(string => uint) unclaimedRewards;
    mapping(string => bytes32) emailVerification;
  }

  /**/
  function _transfer(
    Data storage self,
    address _to,
    uint _value
  ) internal returns (bool) {
    self.balances[msg.sender] = self.balances[msg.sender].sub(_value);
    self.balances[_to] = self.balances[_to].add(_value);
    return true;
  }

  /**/
  function _transferFrom(
    Data storage self,
    address _from,
    address _to,
    uint _value
  ) internal returns (bool) {
    // Check if msg.sender has sufficient allowance;
    // Check is handled by SafeMath library _allowance.sub(_value);
    uint _allowance = self.allowed[_from][msg.sender];
    self.allowed[_from][msg.sender] = _allowance.sub(_value);

    // Update balances
    self.balances[_to] = self.balances[_to].add(_value);
    self.balances[_from] = self.balances[_from].sub(_value);

    return true;
  }

  function _rewardContributor (
    Data storage self,
    string _email,
    string _rewardType,
    uint _rewardBonus
  ) internal returns (bool) {
    uint _value = self.rewardValues[_rewardType].add(_rewardBonus);
    address _contributor = self.contributorAddresses[_email];

    if(_value == 0) {
      throw;
    } else {
      self.totalSupply = self.totalSupply.add(_value);

      if (_contributor == 0x0){
        self.unclaimedRewards[_email] = self.unclaimedRewards[_email].add(_value);
      } else {
        self.balances[_contributor] = self.balances[_contributor].add(_value);
      }

      return true;
    }
  }

  function _verifyContributor(
    Data storage self,
    address _contributor,
    string _email
  ) internal returns (bool) {
    if (_contributor == 0x0) {
      throw;
    }

    if (self.unclaimedRewards[_email] > 0) {
      // Transfer all previously unclaimed rewards of an email to an address;
      // Add to existing balance in case contributor has multiple emails
      self.balances[_contributor] = self.balances[_contributor].add(self.unclaimedRewards[_email]);
      self.unclaimedRewards[_email] = 0;
    }
    self.contributorEmails[_contributor] = _email;
    self.contributorAddresses[_email] = _contributor;
    return true;
  }


  function _setContributor(
    Data storage self,
    string _email,
    bytes _code
  ) internal returns (bool) {
    if (self.emailVerification[_email] != keccak256(_code)) {
      throw;
    }

    if (self.unclaimedRewards[_email] > 0) {
      // Transfer all previously unclaimed rewards of an email to an address;
      // Add to existing balance in case contributor has multiple emails
      self.balances[msg.sender] = self.balances[msg.sender].add(self.unclaimedRewards[_email]);
      self.unclaimedRewards[_email] = 0;
    }
    self.contributorEmails[msg.sender] = _email;
    self.contributorAddresses[_email] = msg.sender;
    return true;
  }

}
