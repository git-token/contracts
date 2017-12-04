pragma solidity ^0.4.15;

/*

Requires a method for sending funds to another address after collecting
a registration fee.


 */

import './Ownable.sol';

contract Registry is Ownable {

  struct Organization {
    string api;
    address admin;
    address gittoken;
    string name;
  }

  event OrganizationRegistered(
    string _name,
    address _gittoken,
    address _admin,
    string _api
  );

  mapping(string => Organization) organizations;
  uint registrationFee;

  function Registry(uint _registrationFee) public {
    registrationFee = _registrationFee > 0 ? _registrationFee : 10**16; // 0.01 ETH
  }

  function registerOrganization(
    string _name,
    address _gittoken,
    string _api
  ) payable public returns (bool success) {
    require(msg.value == registrationFee);

    organizations[_name] = Organization({
      api: _api,
      admin: msg.sender,
      gittoken: _gittoken,
      name: _name
    });

    OrganizationRegistered(_name, _gittoken, msg.sender, _api);
    return true;
  }

  function getOrganization(
    string _name
  ) constant public returns (
    string _orgName,
    address _gittoken,
    address _admin,
    string _api
  ) {
    return (
      _name,
      organizations[_name].gittoken,
      organizations[_name].admin,
      organizations[_name].api
    );
  }

}
