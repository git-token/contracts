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
import './GitTokenLib.sol';
import './Ownable.sol';


/**
 * @title GitToken Contract for distributing ERC20 tokens for Git contributions;
 * @author Ryan Michael Tate <ryan.tate@gittoken.io>
 */
contract GitToken is Ownable {

  using SafeMath for uint;
  using GitTokenLib for GitTokenLib.Data;
  GitTokenLib.Data gittoken;

  /**
   * ERC20 Approval Event | Emitted when a spender is approved by an owner
   * @param owner   address Ethereum address of owner of tokens,
   * @param spender address Ethereum address of approved spender of tokens,
   * @param value   uint    Number of tokens to approve spender for;
   */
  event Approval(address indexed owner, address indexed spender, uint value);

  /**
   * ERC20 Transfer Event | Emitted when a transfer is made between accounts
   * @param from  address Ethereum address of tokens sent from,
   * @param to    address Ethereum address of tokens sent to,
   * @param value uint    Number of tokens to transfer;
   */
  event Transfer(address indexed from, address indexed to, uint value);

  /**
   * Contribution Event | Emitted when a GitHub contribution is broadcasted by web hook,
   * @param contributor   address Ethereum address of contributor,
   * @param username      string  GitHub username of contributor,
   * @param value         uint    Number of tokens created and distributed to contributor,
   * @param reservedValue uint    Number of tokens created and reserved for auction,
   * @param date          uint    Unix timestamp of when the contributor was rewarded,
   * @param rewardType    string  GitHub web hook event type (e.g. push, pull_request)
   */
  event Contribution(address indexed contributor, string username, uint value, uint reservedValue, uint date, string rewardType);

  /**
   * ContributionVerified Event | Emitted when a user verifies themselves on the UI using GitHub OAuth
   * @param contributor address Ethereum address of verified contributor,
   * @param username    string  GitHub username associated with contributor Ethereum address,
   * @param date        uint    Unix timestamp when user was verified;
   */
  event ContributorVerified(address indexed contributor, string username, uint date);

  /**
   * RewardValueSet Event | Emitted when the reward and reserved type values are changed
   * @param rewardType   string GitHub web hook event type,
   * @param reservedType string GitHub web hook action type (a subtype of rewardType; e.g. `organization` -> `member_added`),
   * @param value        uint   Updated value of reward or reserved Type
   * @param date         uint   Unix timestamp when reward values are reset
   * NOTE: This event is used by `setRewardValue()` and `setReservedValue()` methods
   */
  event RewardValueSet(string rewardType, string reservedType, uint value, uint date);

  /**
   * @dev
   * @param startDate          uint Start date of the auction
   * @param endDate            uint End date of the auction
   * @param tokensOffered uint Token supply offered during the auction
   * @param initialPrice       uint Initial price per token, denominated in ETH;
   * default (10 ** 18 / 10 ** _decimals) * 5000 tokens / ETH
   */
  event NewAuction(uint auctionRound, uint startDate, uint endDate, uint lockDate, uint tokensOffered, uint initialPrice);

  event SealAuction(uint auctionRound, uint weightedAveragePrice, uint date);

  /**
   * @dev Constructor method for GitToken Contract,
   * @param _contributor  address Ethereum Address of the primary contributor or organization owner,
   * @param _name         string  Name of the GitToken contract (name of organization),
   * @param _username     string  GitHub username of the primary contributor or organization owner,
   * @param _organization string  GitHub Organization as it appears in the GitHub organization URL (e.g. https://GitHub.com/git-token),
   * @param _symbol       string  Symbol of the GitToken contract,
   * @param _decimals     uint    Number of decimal representation for token balances;
   */
  function GitToken(
    address _contributor,
    string _name,
    string _username,
    string _organization,
    string _symbol,
    uint _decimals
  ) {
    if (_contributor != 0x0) {
      // Set initial contributor username & address
      owner[_contributor] = true;
      gittoken.contributorUsernames[_contributor] = _username;
      gittoken.contributorAddresses[_username] = _contributor;
    }

    gittoken.totalSupply = 0;
    gittoken.name = _name;
    gittoken.organization = _organization;
    gittoken.symbol = _symbol;
    gittoken.decimals = _decimals;


    gittoken.reservedValues['milestone']['created']           = 0 * 10**_decimals;

    // Anytime a new member is invited to an organization
    gittoken.reservedValues['organization']['member_invited'] = 0 * 10**_decimals;
    // Anytime a new member is added to an organization
    gittoken.reservedValues['organization']['member_added']   = 15000 * 10**_decimals;
    // Use when setting up the webhook for github
    gittoken.rewardValues['ping']                             = 2500 * 10**_decimals;
    // Any time a Commit is commented on.
    gittoken.rewardValues['commit_comment']                   = 250 * 10**_decimals;

     // Any time a Branch or Tag is created.
    gittoken.rewardValues['create']                           = 2500 * 10**_decimals;
    // Any time a Branch or Tag is deleted.
    gittoken.rewardValues['delete']                           = 0 * 10**_decimals;

     // Any time a Repository has a new deployment created from the API.
    gittoken.rewardValues['deployment']                       = 5000 * 10**_decimals;
    // Any time a deployment for a Repository has a status update
    gittoken.rewardValues['deployment_status']                = 100 * 10**_decimals;
    // Any time a Repository is forked.
    gittoken.rewardValues['fork']                             = 5000 * 10**_decimals;

     // Any time a Wiki page is updated.
    gittoken.rewardValues['gollum']                           = 100 * 10**_decimals;
    // Any time a GitHub App is installed or uninstalled.
    gittoken.rewardValues['installation']                     = 250 * 10**_decimals;
    // Any time a repository is added or removed from an organization (? check this)
    gittoken.rewardValues['installation_repositories']        = 1000 * 10**_decimals;

     // Any time a comment on an issue is created, edited, or deleted.
    gittoken.rewardValues['issue_comment']                    = 250 * 10**_decimals;
    // Any time an Issue is assigned, unassigned, labeled, unlabeled, opened, edited,
    gittoken.rewardValues['issues']                           = 500 * 10**_decimals;
    // Any time a Label is created, edited, or deleted.
    gittoken.rewardValues['label']                            = 100 * 10**_decimals;
    // Any time a user purchases, cancels, or changes their GitHub
    gittoken.rewardValues['marketplace_purchases']            = 0 * 10**_decimals;
    // Any time a User is added or removed as a collaborator to a Repository, or has
    gittoken.rewardValues['member']                           = 1000 * 10**_decimals;
    // Any time a User is added or removed from a team. Organization hooks only.
    gittoken.rewardValues['membership']                       = 1000 * 10**_decimals;
    // Any time a Milestone is created, closed, opened, edited, or deleted.
    gittoken.rewardValues['milestone']                        = 250 * 10**_decimals;
    // Any time a user is added, removed, or invited to an Organization.
    gittoken.rewardValues['organization']                     = 1000 * 10**_decimals;
    // Any time an organization blocks or unblocks a user. Organization hooks only.
    gittoken.rewardValues['org_block']                        = 0 * 10**_decimals;

     // Any time a Pages site is built or results in a failed build.
    gittoken.rewardValues['page_build']                       = 500 * 10**_decimals;
    // Any time a Project Card is created, edited, moved, converted to an issue,
    gittoken.rewardValues['project_card']                     = 250 * 10**_decimals;
    // Any time a Project Column is created, edited, moved, or deleted.
    gittoken.rewardValues['project_column']                   = 50 * 10**_decimals;
    // Any time a Project is created, edited, closed, reopened, or deleted.
    gittoken.rewardValues['project']                          = 1000 * 10**_decimals;
    // Any time a Repository changes from private to public.
    gittoken.rewardValues['public']                           = 10000 * 10**_decimals;
    // Any time a comment on a pull request's unified diff is created, edited, or deleted (in the Files Changed tab).
    gittoken.rewardValues['pull_request_review_comment']      = 250 * 10**_decimals;
    // Any time a pull request review is submitted, edited, or dismissed.
    gittoken.rewardValues['pull_request_review']              = 250 * 10**_decimals;
    // Any time a pull request is assigned, unassigned, labeled, unlabeled, opened, edited, closed, reopened, or synchronized (updated due to a new push in the branch that the pull request is tracking). Also any time a pull request review is requested, or a review request is removed.
    gittoken.rewardValues['pull_request']                     = 2500 * 10**_decimals;
    // Any Git push to a Repository, including editing tags or branches. Commits via API actions that update references are also counted. This is the default event.
    gittoken.rewardValues['push']                             = 1000 * 10**_decimals;
    // Any time a Repository is created, deleted (organization hooks only), made public, or made private.
    gittoken.rewardValues['repository']                       = 2500 * 10**_decimals;
    // Any time a Release is published in a Repository.
    gittoken.rewardValues['release']                          = 5000 * 10**_decimals;
    // Any time a Repository has a status update from the API
    gittoken.rewardValues['status']                           = 200 * 10**_decimals;
    // Any time a team is created, deleted, modified, or added to or removed from a repository. Organization hooks only
    gittoken.rewardValues['team']                             = 2000 * 10**_decimals;
    // Any time a team is added or modified on a Repository.
    gittoken.rewardValues['team_add']                         = 2000 * 10**_decimals;
    // Any time a User stars a Repository.
    gittoken.rewardValues['watch']                            = 100 * 10**_decimals;

  }

  /**
   * @dev Returns the current total supply of tokens issued
   * @return _supply uint Supply of tokens currently issued
   * NOTE: Remember to adjust supply for decimals representation (e.g. supply / 10 ** decimals)
   */
  function totalSupply() constant returns (uint _supply) {
    return gittoken.totalSupply;
  }

  /**
   * @dev Returns the number of decimal places to adjust token values
   * @return _decimals uint Number of decimal places
   * NOTE: Remember to adjust token values for decimals representation (e.g. value / 10 ** decimals)
   */
  function decimals() constant returns (uint _decimals) {
    return gittoken.decimals;
  }

  /**
   * @dev Returns the string of the GitHub organization associated with the contract
   * @return _organization string GitHub organization (e.g. git-token)
   * NOTE: This value is used to make GitHub API calls; it must be associated with
   * the GitHub organization the web hook has been configured for.
   */
  function organization() public returns (string _organization) {
    return gittoken.organization;
  }

  /**
   * @dev Returns the string of the token contract name
   * @return _name string Name of the token contract
   */
  function name() public returns (string _name) {
    return gittoken.name;
  }

  /**
   * @dev Returns the string of the token contract symbol
   * @return _symbol string Symbol of the token contract
   */
  function symbol() public returns (string _symbol) {
    return gittoken.symbol;
  }

  /**
   * @dev ERC20 `balanceOf` Method | Returns the balance of tokens associated with the address provided
   * @param  _holder      address Ethereum address to find token balance for
   * @return _balance     uint    Value of tokens held by ethereum address
   */
  function balanceOf(address _holder) constant returns (uint _balance) {
    return gittoken.balances[_holder];
  }

  /**
   * @dev ERC20 `transfer` Method | Transfer tokens to account from sender account
   * @param  _to      address Ethereum address to transfer tokens to,
   * @param  _value   uint    Number of tokens to transfer,
   * @return          bool    Returns boolean value if method is called
   */
  function transfer(
    address _to,
    uint _value
  )
    externalTokenTransfersLocked
    public
    returns (bool)
  {
    require(gittoken._transfer(_to, _value));
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev ERC20 `transferFrom` Method | Allow approved spender (msg.sender) to transfer tokens from one account to another
   * @param  _from  address Ethereum address to move tokens from,
   * @param  _to    address Ethereum address to move tokens to,
   * @param  _value uint    Number of tokens to move between accounts,
   * @return        bool    Retrusn boolean value if method is called
   */
  function transferFrom(
    address _from,
    address _to,
    uint _value
  )
    externalTokenTransfersLocked
    public
    onlyPayloadSize(3)
    returns (bool)
  {
    require(gittoken._transferFrom(_from, _to, _value));
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev ERC20 `approve` Method | Approve spender to transfer an amount of
   * tokens on behalf of another account
   * @param  _spender address Ethereum address of spender to approve,
   * @param  _value   uint    Number of tokens to approve spender to transfer,
   * @return          bool    Returns boolean value is method is called;
   * NOTE: Explicitly check if the approved address already has an allowance,
   * Ensure the approver must reset the approved value to 0 before changing to the desired amount.
   * see: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   */
  function approve(
    address _spender,
    uint _value
  )
    public
    onlyPayloadSize(2)
    returns (bool)
  {
    require(_value == 0 && gittoken.allowed[msg.sender][_spender] == 0);
    gittoken.allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  /**
   * @dev ERC20 `allowance` Method | Check the spender allowance for a token owner
   * @param  _owner     address Ethereum address of token owner,
   * @param  _spender   address Ethereum address of spender,
   * @return _allowance uint    Number of tokens allowed by the owner to be
   * moved by the spender
   */
  function allowance(address _owner, address _spender) constant returns (uint _allowance) {
    return gittoken.allowed[_owner][_spender];
  }


  /**
   * @dev Set the reward value for a GitHub web hook event
   * @param _rewardValue uint256 Number of tokens to issue given a rewardType,
   * @param _rewardType  string  GitHub web hook event,
   * @return             bool    Returns boolean value if method is called;
   */
  function setRewardValue(
    uint256 _rewardValue,
    string _rewardType
  )
    onlyOwner
    public
    returns (bool)
  {
    gittoken.rewardValues[_rewardType] = _rewardValue;
    RewardValueSet(_rewardType, '', _rewardValue, now);
    return true;
  }

  /**
   * @dev Set the reserved value for a GitHub web hook event subtype
   * @param _reservedValue uint256 Number of tokens to issue given a reservedType,
   * @param _rewardType    string  GitHub web hook event,
   * @param _reservedType  string  GitHub web hook event subtype (action; e.g. `organization` -> `member_added`),
   * @return               bool    Returns boolean value if method is called;
   */
  function setReservedValue(
    uint256 _reservedValue,
    string _rewardType,
    string _reservedType
  )
    onlyOwner
    public
    returns (bool)
  {
    gittoken.reservedValues[_rewardType][_reservedType] = _reservedValue;
    RewardValueSet(_rewardType, _reservedType, _reservedValue, now);
    return true;
  }

  /**
   * @dev Verify contributor Ethereum address associated with GitHub username
   * @param  _contributor address Ethereum address of GitHub organization contributor,
   * @param  _username    string  GitHub username of contributor,
   * @return              bool    Returns boolean value if method is called;
   */
  function verifyContributor(
    address _contributor,
    string _username
  )
    onlyOwner
    public
    returns (bool)
  {
    require(gittoken._verifyContributor(_contributor, _username));
    ContributorVerified(_contributor, _username, now);
    return true;
  }

  /**
   * @dev Reward contributor when a GitHub web hook event is received
   * @param  _username     string GitHub username of contributor
   * @param  _rewardType   string GitHub web hook event
   * @param  _reservedType string GitHub web hook event subtype (action; e.g. `organization` -> `member_added`)
   * @param  _rewardBonus  uint   Number of tokens to send to contributor as a bonus (used for off-chain calculated values)
   * @param  _deliveryID   string GitHub delivery ID of web hook request
   * @return               bool   Returns boolean value if method is called
   */
  function rewardContributor(
    string _username,
    string _rewardType,
    string _reservedType,
    uint _rewardBonus,
    string _deliveryID
  )
  onlyOwner
  public
  returns (bool) {
    require(gittoken._rewardContributor(_username, _rewardType, _reservedType, _rewardBonus, _deliveryID));
    address _contributor = gittoken.contributorAddresses[_username];
    uint _value = gittoken.rewardValues[_rewardType].add(_rewardBonus);
    uint _reservedValue = gittoken.reservedValues[_rewardType][_reservedType];

    Contribution(_contributor, _username, _value, _reservedValue, now, _rewardType);

    return true;
  }

  /**
   * @dev Initialize Auction & broadcast a NewAuction event
   * @param  _initialPrice uint Token/ETH Exchange Rate (#Tokens / 1 ETH); adjusted for decimal representation;
   * @param  _delay        uint Time in milliseconds to delay each auction period (I - Pre, II - Start, III - End, IV - Post),
   * Must be greater than 86400 (1 day in unix time)
   * @param  _lockTokens   bool Boolean value to optionally lock all token transfers until the Post auction date.
   * @return               bool Returns Boolean value if called from another contract;
   */
  function initializeAuction(
    uint _initialPrice,
    uint _delay,
    bool _lockTokens
  )
  onlyOwner
  public
  returns (bool) {
    require(gittoken._initializeAuction(_initialPrice, _delay, _lockTokens));
    NewAuction(
      gittoken.auctionRound,
      gittoken.auctionDetails[gittoken.auctionRound].startDate,
      gittoken.auctionDetails[gittoken.auctionRound].endDate,
      gittoken.lockTokenTransfersUntil,
      gittoken.auctionDetails[gittoken.auctionRound].tokensOffered,
      gittoken.auctionDetails[gittoken.auctionRound].initialPrice
    );
    return true;
  }


  function sealAuction(
    uint _auctionRound,
    uint _weightedAveragePrice
  )
  onlyOwner
  public
  returns (bool) {
    require(gittoken._sealAuction(_auctionRound, _weightedAveragePrice));
    SealAuction(_auctionRound, _weightedAveragePrice, now);
    return true;
  }


  function executeBid(uint _auctionRound) payable public returns (bool) {
    uint tokenValue = gittoken._executeBid(_auctionRound, msg.sender, msg.value);
    require(tokenValue > 0);
    Transfer(address(this), msg.sender, tokenValue);
    return true;
  }


  /**
   * @dev Get the value associated with a GitHub web hook event
   * @param  _rewardType  string  GitHub web hook event,
   * @return _rewardValue uint256, _reservedType uint256 Reward value associated
   * with GitHub web hook event and subtype (action);
   */
  function getRewardDetails(string _rewardType, string _reservedType) constant returns (uint256 _rewardValue, uint256 _reservedValue) {
    return (gittoken.rewardValues[_rewardType], gittoken.reservedValues[_rewardType][_reservedType]);
  }

  /**
   * @dev Get Ethereum address associated with contributor's GitHub username
   * @param  _username            string GitHub username of the contributor,
   * @return _contributorAddress  address Ethereum address of the contributor associated
   * passed in GitHub username;
   */
  function getContributorAddress(string _username) constant returns (address _contributorAddress) {
    return gittoken.contributorAddresses[_username];
  }

  /**
   * @dev Get GitHub username from contributor's Ethereum address
   * @param  _contributorAddress address Ethereum address of contributor,
   * @return _username           string  GitHub username associated with contributor address;
   */
  function getContributorUsername(address _contributorAddress) constant returns (string _username) {
    return gittoken.contributorUsernames[_contributorAddress];
  }

  /**
   * @dev Get the date timestamp of when tokens are locked until
   * @return _lockedUntil uint Timestamp of when tokens are locked until
   */
  function getTokenLockUntilDate() constant returns (uint _lockedUntil) {
    return gittoken.lockTokenTransfersUntil;
  }

  /**
   * @dev Get unclaimed (pre-verified) rewards associated with GitHub username
   * @param  _username string GitHub username of contributor,
   * @return _value    uint   Number of tokens issued to GitHub username
   */
  function getUnclaimedRewards(string _username) constant returns (uint _value) {
    return gittoken.unclaimedRewards[_username];
  }

  function () {
    revert();
  }

  /**
   * @dev This modifier checks the data length to ensure that it matches the padded
   * length of the input data provided to the method.
   */
  modifier onlyPayloadSize(uint inputLength) {
     require(msg.data.length == inputLength * 32 + 4);
     _;
  }

  /**
   * @dev Disallow external token transfers if the current timestamp is less
   * than the `lockTokenTransfersUntil` date.
   * NOTE: Use `getTokenLockUntilDate` method to check date and mitigate
   * cost of gas throwing;
   */
  modifier externalTokenTransfersLocked() {
    require(now > gittoken.lockTokenTransfersUntil);
    _;
  }


}
