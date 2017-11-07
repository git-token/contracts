pragma solidity ^0.4.15;

import './Admin.sol';
import './GitToken.sol';

contract Registry is Admin {

  struct Data {
    mapping(string => GitToken) organizations;
    mapping(string => bool) registered;
    mapping(string => mapping(address => bool)) verified;
    mapping(address => bool) blacklist;
    mapping(bytes32 => bool) activeRequests;
    address signer;
    uint256 registrationFee;
  }

  Data registry;

  event TokenRegistered(string _organization, address _token, string _symbol, address _registeredBy, uint _date);
  event TokenRequested(address _token, address _contributor, uint _value, uint _date, uint _expiration, bytes32 _requestId);
  event TokenRedeemed(address _token, address _contributor, uint _value, uint _date, bytes32 _requestId);
  event OrganizationVerified(string _organization, address _admin, string _username);

  function Registry(address _signer) public {
    registry = Data({
      signer: _signer,
      registrationFee: 30 * 10 ** 14 // This fee should cover signer tx costs (e.g. verifyOrganization())
    });
    admin[_signer] = true;
  }

  function verifyOrganization(
    string _organization,
    string _username,
    address _admin
  )
  signer
  public returns (bool success)
  {
    registry.verified[_organization][_admin] = true;
    OrganizationVerified(_organization, _admin, _username);
    return true;
  }

  function registerToken(
    string _organization,
    string _name,
    string _symbol,
    uint256 _decimals,
    address _admin,
    string _username
  )
  payable
  verified(_organization)
  unregistered(_organization)
  public returns (bool success)
  {
    /*require(msg.value >= registry.registrationFee);*/

    GitToken token = new GitToken(
      _organization,
      _name,
      _symbol,
      _decimals,
      address(this),
      _admin,
      _username
    );

    registry.organizations[_organization] = token;
    registry.registered[_organization] = true;
    TokenRegistered(_organization, token, _symbol, _admin, now);
    return true;
  }


  function requestToken(
    address _token,
    uint _value
  )
    public
    returns (bool success)
  {
    uint expiration = now + (60*60*15); // 15 minute expiration
    bytes32 requestId = keccak256(_token, msg.sender, _value, now, expiration);

    // Activate the Request
    registry.activeRequests[requestId] = true;
    TokenRequested(_token, msg.sender, _value, now, expiration, requestId);
    return true;
  }

  function redeemToken(
    address _token,
    address _contributor,
    uint _value,
    bytes32 _requestId
  )
    signer
    public
    returns (bool success)
  {
    // Request must be open
    require(registry.activeRequests[_requestId]);

    GitToken token = GitToken(_token);
    require(token.credit(_contributor, _value));

    // Set Request to inactive
    registry.activeRequests[_requestId] = false;
    TokenRedeemed(_token, _contributor, _value, now, _requestId);
    return true;
  }

  function getOrganizationToken(string _organization) public constant returns (address _token) {
    return registry.organizations[_organization];
  }

  function getSigner() public constant returns (address _signer) {
    return registry.signer;
  }

  function blacklist(address _token) onlyAdmin public returns (bool success) {
    registry.blacklist[_token] = true;
    return true;
  }

  function () public { revert(); }

  modifier signer() {
    require(registry.signer == msg.sender);
    _;
  }

  modifier unregistered(string _organization) {
    require(registry.registered[_organization] == false);
    _;
  }

  modifier registered(string _organization) {
    require(registry.registered[_organization] == true);
    _;
  }

  modifier verified(string _organization) {
    require(registry.verified[_organization][msg.sender] == true);
    _;
  }


  modifier blacklisted(address _token) {
    require(registry.blacklist[_token] == false);
    _;
  }

}
