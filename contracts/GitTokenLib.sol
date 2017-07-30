pragma solidity ^0.4.11;

import './SafeMath.sol';

library GitTokenLib {

  using SafeMath for uint;

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
    mapping(string => bytes32) usernameVerification;
    mapping(string => bool) receivedDelivery;
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
    string _username,
    string _rewardType,
    string _reservedType,
    uint _rewardBonus,
    string _deliveryID
  ) internal returns (bool) {
    uint _value = self.rewardValues[_rewardType].add(_rewardBonus);
    uint _reservedValue = self.reservedValues[_rewardType][_reservedType];
    address _contributor = self.contributorAddresses[_username];

    if(_value == 0) {
      throw;
    } else if (self.receivedDelivery[_deliveryID] == true) {
      throw;
    } else {
      self.totalSupply = self.totalSupply.add(_value).add(_reservedValue);
      self.balances[address(this)] = self.balances[address(this)].add(_reservedValue);

      if (_contributor == 0x0){
        self.unclaimedRewards[_username] = self.unclaimedRewards[_username].add(_value);
      } else {
        self.balances[_contributor] = self.balances[_contributor].add(_value);
      }

      self.receivedDelivery[_deliveryID] = true;
      return true;
    }
  }

  function _verifyContributor(
    Data storage self,
    address _contributor,
    string _username
  ) internal returns (bool) {
    if (_contributor == 0x0) {
      throw;
    }

    if (self.unclaimedRewards[_username] > 0) {
      // Transfer all previously unclaimed rewards of an username to an address;
      // Add to existing balance in case contributor has multiple usernames
      self.balances[_contributor] = self.balances[_contributor].add(self.unclaimedRewards[_username]);
      self.unclaimedRewards[_username] = 0;
    }
    self.contributorUsernames[_contributor] = _username;
    self.contributorAddresses[_username] = _contributor;
    return true;
  }


  function _setContributor(
    Data storage self,
    string _username,
    bytes _code
  ) internal returns (bool) {
    if (self.usernameVerification[_username] != keccak256(_code)) {
      throw;
    }

    if (self.unclaimedRewards[_username] > 0) {
      // Transfer all previously unclaimed rewards of an username to an address;
      // Add to existing balance in case contributor has multiple usernames
      self.balances[msg.sender] = self.balances[msg.sender].add(self.unclaimedRewards[_username]);
      self.unclaimedRewards[_username] = 0;
    }
    self.contributorUsernames[msg.sender] = _username;
    self.contributorAddresses[_username] = msg.sender;
    return true;
  }

  function _initReservedValues(Data storage self, uint _decimals) internal returns (bool) {

    self.reservedValues['milestone']['created']  = 15000 * 10**_decimals;

    self.reservedValues['organization']['member_added']  = 15000 * 10**_decimals;

    return true;
  }

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
