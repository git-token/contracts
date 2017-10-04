pragma solidity ^0.4.11;

import './Ownable.sol';

contract GitTokenRegistry is Ownable {

  struct Registry {
    mapping(string => address) organizations;
  }

  Registry registry;

  event Registration(string _organization, address _token, uint date);

  function GitTokenRegistry(address _owner) {
    registry = Registry({});
    owner[_owner] = true;
  }

  function registerToken(string _organization, address _token) returns (bool success) {
    registry.organizations[_organization] = _token;
    Registration(_organization, _token, now);
    return success;
  }

}
