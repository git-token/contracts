pragma solidity ^0.4.15;

import './Ownable.sol';
/* Abstract Contract */

contract RewardPointsInterface is Ownable {
  function getRewardDetails(string _event, string _subtype) public constant returns (uint _rewardValue, uint _reserveValue);

  function setRewardDetails(string _event, string _subtype, uint _rewardValue, uint _reserveValue) onlyOwner public returns (bool success);

}
