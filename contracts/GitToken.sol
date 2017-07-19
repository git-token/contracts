pragma solidity ^0.4.11;

import './SafeMath.sol';
import './GitTokenLib.sol';
import './Ownable.sol';

contract GitToken is Ownable {

  using SafeMath for uint;
  using GitTokenLib for GitTokenLib.Data;
  GitTokenLib.Data gittoken;

  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
  event Contribution(address indexed contributor, string username, uint value, uint date, string rewardType);
  event ContributorVerified(address indexed contributor, string username, uint date);
  /*event ConfigUpdated();*/

  function GitToken(
    address _contributor,
    string _name,
    string _username,
    string _organization,
    string _symbol,
    uint _decimals
  ) {
    if (_contributor != 0x0) { owner[_contributor] = true; }
    gittoken.totalSupply = 0;
    gittoken.name = _name;
    gittoken.organization = _organization;
    gittoken.symbol = _symbol;
    gittoken.decimals = _decimals;
    // Set initial contributor username & address
    gittoken.contributorUsernames[msg.sender] = _username;
    gittoken.contributorUsernames[_contributor] = _username;
    gittoken.contributorAddresses[_username] = _contributor;

    // Set default rewardValues -- Note, these values are not solidified and are untested as to their effectiveness of incentivization;
    // These values are customizable using setRewardValue(uint256 value, string type)

    // Use when setting up the webhook for github
    gittoken.rewardValues['ping']                        = 2500 * 10**_decimals;

    // Any time a Commit is commented on.
    gittoken.rewardValues['commit_comment']              = 250 * 10**_decimals;

     // Any time a Branch or Tag is created.
    gittoken.rewardValues['create']                      = 2500 * 10**_decimals;

    // Any time a Branch or Tag is deleted.
    gittoken.rewardValues['delete']                      = 0 * 10**_decimals;

     // Any time a Repository has a new deployment created from the API.
    gittoken.rewardValues['deployment']                  = 5000 * 10**_decimals;

    // Any time a deployment for a Repository has a status update
    gittoken.rewardValues['deployment_status']           = 100 * 10**_decimals;

    // Any time a Repository is forked.
    gittoken.rewardValues['fork']                        = 5000 * 10**_decimals;

     // Any time a Wiki page is updated.
    gittoken.rewardValues['gollum']                      = 250 * 10**_decimals;

    // Any time a GitHub App is installed or uninstalled.
    gittoken.rewardValues['installation']                = 250 * 10**_decimals;

    // Any time a repository is added or removed from an organization (? check this)
    gittoken.rewardValues['installation_repositories']   = 1000 * 10**_decimals;

     // Any time a comment on an issue is created, edited, or deleted.
    gittoken.rewardValues['issue_comment']               = 250 * 10**_decimals;

    // Any time an Issue is assigned, unassigned, labeled, unlabeled, opened, edited,
    gittoken.rewardValues['issues']                      = 500 * 10**_decimals;

    // Any time a Label is created, edited, or deleted.
    gittoken.rewardValues['label']                       = 100 * 10**_decimals;

    // Any time a user purchases, cancels, or changes their GitHub
    gittoken.rewardValues['marketplace_purchases']       = 0 * 10**_decimals;

    // Any time a User is added or removed as a collaborator to a Repository, or has
    gittoken.rewardValues['member']                      = 1000 * 10**_decimals;

    // Any time a User is added or removed from a team. Organization hooks only.
    gittoken.rewardValues['membership']                  = 1000 * 10**_decimals;

    // Any time a Milestone is created, closed, opened, edited, or deleted.
    gittoken.rewardValues['milestone']                   = 15000 * 10**_decimals;

    // Any time a user is added, removed, or invited to an Organization.
    gittoken.rewardValues['organization']                = 1000 * 10**_decimals;

    // Any time an organization blocks or unblocks a user. Organization hooks only.
    gittoken.rewardValues['orgBlock']                    = 0 * 10**_decimals;

     // Any time a Pages site is built or results in a failed build.
    gittoken.rewardValues['pageBuild']                   = 500 * 10**_decimals;

    // Any time a Project Card is created, edited, moved, converted to an issue,
    gittoken.rewardValues['projectCard']                 = 250 * 10**_decimals;

    // Any time a Project Column is created, edited, moved, or deleted.
    gittoken.rewardValues['projectColumn']               = 50 * 10**_decimals;

    // Any time a Project is created, edited, closed, reopened, or deleted.
    gittoken.rewardValues['project']                     = 1000 * 10**_decimals;

    // Any time a Repository changes from private to public.
    gittoken.rewardValues['public']                      = 10000 * 10**_decimals;

    // Any time a comment on a pull request's unified diff is created, edited, or deleted (in the Files Changed tab).
    gittoken.rewardValues['pull_request_review_comment'] = 250 * 10**_decimals;

    // Any time a pull request review is submitted, edited, or dismissed.
    gittoken.rewardValues['pull_request_review']         = 100 * 10**_decimals;

    // Any time a pull request is assigned, unassigned, labeled, unlabeled, opened, edited, closed, reopened, or synchronized (updated due to a new push in the branch that the pull request is tracking). Also any time a pull request review is requested, or a review request is removed.
    gittoken.rewardValues['pull_request']                = 250 * 10**_decimals;

    // Any Git push to a Repository, including editing tags or branches. Commits via API actions that update references are also counted. This is the default event.
    gittoken.rewardValues['push']                        = 1000 * 10**_decimals;

    // Any time a Repository is created, deleted (organization hooks only), made public, or made private.
    gittoken.rewardValues['repository']                  = 2500 * 10**_decimals;

    // Any time a Release is published in a Repository.
    gittoken.rewardValues['release']                     = 5000 * 10**_decimals;

    // Any time a Repository has a status update from the API
    gittoken.rewardValues['status']                      = 200 * 10**_decimals;

    // Any time a team is created, deleted, modified, or added to or removed from a repository. Organization hooks only
    gittoken.rewardValues['team']                        = 2000 * 10**_decimals;

    // Any time a team is added or modified on a Repository.
    gittoken.rewardValues['team_add']                    = 2000 * 10**_decimals;

    // Any time a User stars a Repository.
    gittoken.rewardValues['watch']                       = 500 * 10**_decimals;

  }

  function totalSupply() constant returns (uint) {
    return gittoken.totalSupply;
  }

  function decimals() constant returns (uint) {
    return gittoken.decimals;
  }

  function organization() constant returns (string) {
    return gittoken.organization;
  }

  function name() constant returns (string) {
    return gittoken.name;
  }

  function symbol() constant returns (string) {
    return gittoken.symbol;
  }
  /*
   * ERC20 Methods
   */
  function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool) {
    if(!gittoken._transfer(_to, _value)) {
      throw;
    } else {
      Transfer(msg.sender, _to, _value);
    }
  }

  function balanceOf(address _contributor) constant returns (uint) {
    return gittoken.balances[_contributor];
  }

  function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
    if(!gittoken._transferFrom(_from, _to, _value)) {
      throw;
    } else {
      Transfer(_from, _to, _value);
    }
  }

  function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
    // Explicitly check if the approved address already has an allowance,
    // Ensure the approver must reset the approved value to 0 before changing to the desired amount.
    // see: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if(_value > 0 && gittoken.allowed[msg.sender][_spender] > 0) {
      throw;
    } else {
      gittoken.allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
    }
  }

  function allowance(address _owner, address _spender) constant returns (uint) {
    return gittoken.allowed[_owner][_spender];
  }


  /**
   * GitToken Setter (State Changing) Functions
   */
  function setRewardValue(
    uint256 _rewardValue,
    string _rewardType
  ) onlyOwner public returns (bool) {
    gittoken.rewardValues[_rewardType] = _rewardValue;
    return true;
  }

  function verifyContributor(address _contributor, string _username) onlyOwner public returns (bool) {
    /*gittoken.usernameVerification[_username] = keccak256(_code);
    return true;*/
    if(!gittoken._verifyContributor(_contributor, _username)) {
      throw;
    } else {
      ContributorVerified(_contributor, _username, now);
      return true;
    }

  }

  function setContributor(string _username, bytes _code) public returns (bool) {
    if (!gittoken._setContributor(_username, _code)) {
      throw;
    } else {
      return true;
    }
  }

  function rewardContributor(
    string _username,
    string _rewardType,
    uint _rewardBonus,
    string _deliveryID
  ) onlyOwner public returns (bool) {
    if(!gittoken._rewardContributor(_username, _rewardType, _rewardBonus, _deliveryID)) {
      throw;
    } else {
      address _contributor = gittoken.contributorAddresses[_username];
      uint _value = gittoken.rewardValues[_rewardType].add(_rewardBonus);
      Contribution(_contributor, _username, _value, now, _rewardType);
      return true;
    }
  }


  /**
   * GitToken Getter Functions
   */

  function getRewardDetails(string _rewardType) constant returns (uint256) {
    return gittoken.rewardValues[_rewardType];
  }

  function getContributorAddress(string _username) constant returns (address) {
    return gittoken.contributorAddresses[_username];
  }

  function getContributorUsername(address _contributorAddress) constant returns (string) {
    return gittoken.contributorUsernames[_contributorAddress];
  }

  function getUnclaimedRewards(string _username) constant returns (uint) {
    return gittoken.unclaimedRewards[_username];
  }

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }


}
