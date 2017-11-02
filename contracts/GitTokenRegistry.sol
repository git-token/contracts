pragma solidity ^0.4.15;

import './Admin.sol';
import './GitToken.sol';

contract GitTokenRegistry is Admin {

  struct Registry {
    mapping(string => GitToken) organizations;
    mapping(string => bool) registered;
    mapping(address => bool) blacklist;
    mapping(bytes32 => bool) activeRequests;
    address signer;
    uint256 registrationFee;
  }

  Registry registry;

  event TokenRegistered(string _organization, address _token, string _symbol, address _registeredBy, uint _date);
  event TokenRequested(address _token, address _contributor, uint _value, uint _date, uint _expiration, bytes32 _requestId);
  event TokenRedeemed(address _token, address _contributor, uint _value, uint _date, bytes32 _requestId);
  event OrganizationVerified(string _organization, address _admin, string _name, uint _decimals, string _symbol, string _username);

  function GitTokenRegistry(address _signer) public {
    registry = Registry({ signer: _signer, registrationFee: 30 * 10 ** 14 });
    admin[_signer] = true;
  }

  function verifyOrginization(
    string _organization,
    string _username,
    string _name,
    uint _decimals,
    string symbol
  ) payable isRegistered(_organization) public returns (bool success) {
    require(msg.value >= registry.registrationFee);
    registry.register[_organization] = true;
    registry.signer.transfer(msg.value);
    OrganizationVerified(_organization, msg.sender, _name, _decimals, _symbol, _username);
    return true;
  }

  function registerToken(
    string _organization,
    string _name,
    string _symbol,
    uint256 _decimals,
    address _admin,
    string _username
  ) onlySigner public returns (bool success) {
    
    require(registry.registered[_organization]);

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
    onlySigner
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

  function blacklist(address _token) onlyAdmin public returns (bool success) {
    registry.blacklist[_token] = true;
    return true;
  }

  function () public { revert(); }

  modifier onlySigner() {
    require(registry.signer == msg.sender);
    _;
  }

  modifier isRegistered(string _organization) {
    require(registry.registered[_organization] == false);
    _;
  }

  modifier isBlacklisted(address _token) {
    require(registry.blacklist[_token] == false);
    _;
  }

}
