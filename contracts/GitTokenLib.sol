/**
 Copyright 2017 GitToken

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

pragma solidity ^0.4.11;

import './SafeMath.sol';
/**
 * @title GitTokenLib Library for implementing GitToken contract methods
 * @author Ryan Michael Tate
 */
library GitTokenLib {

  using SafeMath for uint;

  /**
   * @dev Data Solidity struct for data storage reference
   * @notice totalSupply    uint   Total supply of tokens issued;
   * @notice decimals       uint   Decimal representation of token values;
   * @notice name           string Name of token;
   * @notice organization   string GitHub organization name;
   * @notice symbol         string Symbol of token;
   * @notice rewardValues   mapping(string => uint256) Mapping of GitHub web hook
   * events to reward values;
   * @notice reservedValues mapping(string => mapping(string => uint256)) Double
   * mapping of GitHub web hook events and subtypes to reward values;
   * @notice contributorUsernames mapping(address => string) Mapping of Ethereum
   * addresses to GitHub usernames;
   * @notice contributorAddresses mapping(string => address) Mapping of GitHub
   * usernames to Ethereum addresses;
   * @notice allowed mapping(address => mapping(address => uint)) Double mapping
   *of Ethereum address to address of spender of an uint amount of tokens;
   * @notice balances mapping(address => uint) Mapping of Ethereum address to an
   * amount of tokens held;
   * @notice unclaimedRewards mapping(string => uint) Mapping of GitHub usernames
   * unclaimed (pre-verified) amount of tokens;
   * @notice receivedDelivery mapping(string => bool) Mapping of GitHub delivery
   * web hook IDs to boolean values; used to prevent/mitigate replay attack risk;
   */
  struct Data {
    uint totalSupply;
    uint decimals;
    string name;
    string organization;
    string symbol;
    mapping(string => uint256) rewardValues;
    mapping(string => mapping(string => uint256)) reservedValues;
    mapping(address => string) contributorUsernames;
    mapping(string => address) contributorAddresses;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) balances;
    mapping(string => uint) unclaimedRewards;
    mapping(string => bool) receivedDelivery;
  }

  /**
   * @dev Internal transfer method for GitToken ERC20 transfer method
   * @param  self   Data    Use the Data struct as the contract storage and reference
   * @param   _to   address Ethereum address of account to transfer tokens to
   * @param  _value uint    Amount of tokens to transfer
   * @return        bool    Returns boolean value when called from the parent contract;
   */
  function _transfer(
    Data storage self,
    address _to,
    uint _value
  ) internal returns (bool) {
    self.balances[msg.sender] = self.balances[msg.sender].sub(_value);
    self.balances[_to] = self.balances[_to].add(_value);
    return true;
  }

  /**
   * @dev Internal transferFrom method for GitToken ERC20 transfer method
   * @param  self   Data    Use the Data struct as the contract storage and reference
   * @param  _from  address Ethereum address to move tokens from,
   * @param  _to    address Ethereum address to move tokens to,
   * @param  _value uint    Number of tokens to move between accounts,
   * @return        bool    Returns boolean value when called from the parent contract;
   */
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

  /**
   * @dev Internal rewardContributor method for GitToken contract rewardContributor method
   * @param  self   Data    Use the Data struct as the contract storage and reference
   * @param  _username     string GitHub username of contributor
   * @param  _rewardType   string GitHub web hook event
   * @param  _reservedType string GitHub web hook event subtype (action; e.g. `organization` -> `member_added`)
   * @param  _rewardBonus  uint   Number of tokens to send to contributor as a bonus (used for off-chain calculated values)
   * @param  _deliveryID   string GitHub delivery ID of web hook request
   * @return               bool   Returns boolean value when called from the parent contract;
   */
  function _rewardContributor (
    Data storage self,
    string _username,
    string _rewardType,
    string _reservedType,
    uint _rewardBonus,
    string _deliveryID
  ) internal returns (bool) {
    // Calculate total reward value for contribution event
    uint _value = self.rewardValues[_rewardType].add(_rewardBonus);

    // Calculate reserved value for contribution event
    uint _reservedValue = self.reservedValues[_rewardType][_reservedType];

    // Get the contributor Ethereum address from GitHub username
    address _contributor = self.contributorAddresses[_username];

    // If no value is created, then throw the transaction;
    if(_value == 0 && _reservedValue == 0) {
      throw;
      // If the GitHub web hook event ID has already occured, then throw the transaction;
    } else if (self.receivedDelivery[_deliveryID] == true) {
      throw;
    } else {
      // Update totalSupply with the added values created, including the reserved supply for auction;
      self.totalSupply = self.totalSupply.add(_value).add(_reservedValue);

      // Add to the balance of reserved tokens held for auction by the contract
      self.balances[address(this)] = self.balances[address(this)].add(_reservedValue);

      // If the contributor is not yet verified, increase the unclaimed rewards for the user until the user verifies herself/himself;
      if (_contributor == 0x0){
        self.unclaimedRewards[_username] = self.unclaimedRewards[_username].add(_value);
      } else {
        // If the contributor's address is set, update the contributor's balance;
        self.balances[_contributor] = self.balances[_contributor].add(_value);
      }

      // Finally, set the received deliveries for this event to true to prevent/mitigate event replay attacks;
      self.receivedDelivery[_deliveryID] = true;

      // Return true to parent contract
      return true;
    }
  }

  /**
   * @dev Internal method for GitToken contract verifyContributor method
   * @param  self         Data    Use the Data struct as the contract storage and reference
   * @param  _contributor address Ethereum address of GitHub organization contributor,
   * @param  _username    string  GitHub username of contributor,
   * @return              bool    Returns boolean value when called from the parent contract;
   */
  function _verifyContributor(
    Data storage self,
    address _contributor,
    string _username
  ) internal returns (bool) {

    // If the contributor address does not exist, then throw the transaction
    if (_contributor == 0x0) {
      throw;
    }

    if (self.unclaimedRewards[_username] > 0) {
      // Transfer all previously unclaimed rewards of an username to an address;
      // Add to existing balance in case contributor has multiple usernames
      self.balances[_contributor] = self.balances[_contributor].add(self.unclaimedRewards[_username]);
      self.unclaimedRewards[_username] = 0;
    } else if (
      self.contributorAddresses[_username] != _contributor &&
      self.balances[self.contributorAddresses[_username]] > 0
    ) {
      // Update the contributor address for the user
      self.contributorUsernames[_contributor] = _username;
      self.contributorAddresses[_username] = _contributor;

      // if the user switches his/her registered account to another account,
      // the balance of the prior account should be moved to the new account
      self.balances[_contributor] = self.balances[self.contributorAddresses[_username]];

      // Set the balance of the prior account to 0 after moving the balance;
      self.balances[self.contributorAddresses[_username]] = 0;
    } else {
      // establish username and address with contract;
      self.contributorUsernames[_contributor] = _username;
      self.contributorAddresses[_username] = _contributor;
    }
    return true;
  }


  /**
   * @dev Initialize reserved type mapped to reserved value
   * @param  self      Data    Use the Data struct as the contract storage and reference
   * @param  _decimals uint    Decimal places to represent token values in
   * @return           bool    Returns boolean value when called from the parent contract
   */
  function _initReservedValues(Data storage self, uint _decimals) internal returns (bool) {

    /* NOTE: change to when the milestone is reached */
    self.reservedValues['milestone']['created'] = 0;

    // Anytime a new member is invited to an organization
    self.reservedValues['organization']['member_invited']  = 0;
    // Anytime a new member is added to an organization
    self.reservedValues['organization']['member_added']  = 15000 * 10**_decimals;
    return true;
  }

  /**
   * @dev Initialize reward type (GitHub web hook event) mapped to reward value
   * @param  self      Data    Use the Data struct as the contract storage and reference
   * @param  _decimals uint    Decimal places to represent token values in
   * @return           bool    Returns boolean value when called from the parent contract
   */
  function _initRewardValues(Data storage self, uint _decimals) internal returns (bool) {
    // Set default rewardValues -- Note, these values are not solidified and are untested as to their effectiveness of incentivization;
    // These values are customizable using setRewardValue(uint256 value, string type)

    // Use when setting up the webhook for github
    self.rewardValues['ping']                        = 2500 * 10**_decimals;

    // Any time a Commit is commented on.
    self.rewardValues['commit_comment']              = 250 * 10**_decimals;

     // Any time a Branch or Tag is created.
    self.rewardValues['create']                      = 2500 * 10**_decimals;

    // Any time a Branch or Tag is deleted.
    self.rewardValues['delete']                      = 0 * 10**_decimals;

     // Any time a Repository has a new deployment created from the API.
    self.rewardValues['deployment']                  = 5000 * 10**_decimals;

    // Any time a deployment for a Repository has a status update
    self.rewardValues['deployment_status']           = 100 * 10**_decimals;

    // Any time a Repository is forked.
    self.rewardValues['fork']                        = 5000 * 10**_decimals;

     // Any time a Wiki page is updated.
    self.rewardValues['gollum']                      = 100 * 10**_decimals;

    // Any time a GitHub App is installed or uninstalled.
    self.rewardValues['installation']                = 250 * 10**_decimals;

    // Any time a repository is added or removed from an organization (? check this)
    self.rewardValues['installation_repositories']   = 1000 * 10**_decimals;

     // Any time a comment on an issue is created, edited, or deleted.
    self.rewardValues['issue_comment']               = 250 * 10**_decimals;

    // Any time an Issue is assigned, unassigned, labeled, unlabeled, opened, edited,
    self.rewardValues['issues']                      = 500 * 10**_decimals;

    // Any time a Label is created, edited, or deleted.
    self.rewardValues['label']                       = 100 * 10**_decimals;

    // Any time a user purchases, cancels, or changes their GitHub
    self.rewardValues['marketplace_purchases']       = 0 * 10**_decimals;

    // Any time a User is added or removed as a collaborator to a Repository, or has
    self.rewardValues['member']                      = 1000 * 10**_decimals;

    // Any time a User is added or removed from a team. Organization hooks only.
    self.rewardValues['membership']                  = 1000 * 10**_decimals;

    // Any time a Milestone is created, closed, opened, edited, or deleted.
    self.rewardValues['milestone']                   = 250 * 10**_decimals;

    // Any time a user is added, removed, or invited to an Organization.
    self.rewardValues['organization']                = 1000 * 10**_decimals;

    // Any time an organization blocks or unblocks a user. Organization hooks only.
    self.rewardValues['org_block']                    = 0 * 10**_decimals;

     // Any time a Pages site is built or results in a failed build.
    self.rewardValues['page_build']                   = 500 * 10**_decimals;

    // Any time a Project Card is created, edited, moved, converted to an issue,
    self.rewardValues['project_card']                 = 250 * 10**_decimals;

    // Any time a Project Column is created, edited, moved, or deleted.
    self.rewardValues['project_column']               = 50 * 10**_decimals;

    // Any time a Project is created, edited, closed, reopened, or deleted.
    self.rewardValues['project']                     = 1000 * 10**_decimals;

    // Any time a Repository changes from private to public.
    self.rewardValues['public']                      = 10000 * 10**_decimals;

    // Any time a comment on a pull request's unified diff is created, edited, or deleted (in the Files Changed tab).
    self.rewardValues['pull_request_review_comment'] = 250 * 10**_decimals;

    // Any time a pull request review is submitted, edited, or dismissed.
    self.rewardValues['pull_request_review']         = 250 * 10**_decimals;

    // Any time a pull request is assigned, unassigned, labeled, unlabeled, opened, edited, closed, reopened, or synchronized (updated due to a new push in the branch that the pull request is tracking). Also any time a pull request review is requested, or a review request is removed.
    self.rewardValues['pull_request']                = 2500 * 10**_decimals;

    // Any Git push to a Repository, including editing tags or branches. Commits via API actions that update references are also counted. This is the default event.
    self.rewardValues['push']                        = 1000 * 10**_decimals;

    // Any time a Repository is created, deleted (organization hooks only), made public, or made private.
    self.rewardValues['repository']                  = 2500 * 10**_decimals;

    // Any time a Release is published in a Repository.
    self.rewardValues['release']                     = 5000 * 10**_decimals;

    // Any time a Repository has a status update from the API
    self.rewardValues['status']                      = 200 * 10**_decimals;

    // Any time a team is created, deleted, modified, or added to or removed from a repository. Organization hooks only
    self.rewardValues['team']                        = 2000 * 10**_decimals;

    // Any time a team is added or modified on a Repository.
    self.rewardValues['team_add']                    = 2000 * 10**_decimals;

    // Any time a User stars a Repository.
    self.rewardValues['watch']                       = 100 * 10**_decimals;

    return true;
  }

}
