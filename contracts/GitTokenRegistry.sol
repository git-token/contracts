pragma solidity ^0.4.15;

import './Admin.sol';
import './GitToken.sol';

contract GitTokenRegistry is Admin {

  struct Registry {
    mapping(string => GitToken) organizations;
    mapping(string => bool) registered;
    address signer;
  }

  Registry registry;

  event Registration(string _organization, address _token, string _symbol, address _registeredBy, uint date);


  function GitTokenRegistry(address _signer) public {
    registry = Registry({ signer: _signer });
    admin[_signer] = true;
  }


  function registerToken(
    string _organization,
    string _name,
    string _symbol,
    uint256 _decimals,
    address _admin,
    string _username
  ) isRegistered(_organization) public returns (bool success) {

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
    registry.registered[_organization] = true;
    Registration(_organization, token, _symbol, _admin, now);
    return success;
  }


  function getOrganizationToken(string _organization) public constant returns (address _token) {
    return registry.organizations[_organization];
  }

  function () public { revert(); }

  modifier isRegistered(string _organization) {
    require(!registry.registered[_organization]);
    _;
  }

}
