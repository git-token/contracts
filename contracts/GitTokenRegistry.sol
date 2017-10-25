pragma solidity ^0.4.15;

import './Ownable.sol';
import './GitToken.sol';

contract GitTokenRegistry {

  struct Registry {
    mapping(string => GitToken) organizations;
    address signer;
  }

  Registry registry;

  event Registration(string _organization, address _token, string _symbol, address _registeredBy, uint date);


  function GitTokenRegistry(address _signer) public {
    registry = Registry({ signer: _signer });
  }


  function registerToken(
    string _organization,
    string _name,
    string _symbol,
    uint256 _decimals,
    address _admin,
    string _username
  ) public returns (bool success) {

    GitToken token = new GitToken(
      _organization,
      _name,
      _symbol,
      _decimals,
      registry.signer,
      _admin,
      _username
    );

    registry.organizations[_organization] = token;
    Registration(_organization, token, _symbol, _admin, now);
    return success;
  }


  function getOrganizationToken(string _organization) public constant returns (address _token) {
    return registry.organizations[_organization];
  }

}
