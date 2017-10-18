/**
 Copyright 2017-2018 GitToken

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
   * @param rewardType    string  GitHub web hook event type (e.g. push, pull_request)
   * @param rewardValue   uint    Number of tokens created and distributed to contributor,
   * @param reservedValue uint    Number of tokens created and reserved for auction,
   * @param date          uint    Unix timestamp of when the contributor was rewarded,

   */
  event Contribution(
    address indexed contributor,
    string username,
    string rewardType,
    uint rewardValue,
    uint reservedValue,
    uint date
  );

  /**
   * ContributionVerified Event | Emitted when a user verifies themselves on the UI using GitHub OAuth
   * @param contributor address Ethereum address of verified contributor,
   * @param username    string  GitHub username associated with contributor Ethereum address,
   * @param date        uint    Unix timestamp when user was verified;
   */
  event ContributorVerified(address indexed contributor, string username, uint date);

  /* NOTE: Consider removing */
  event Auction(uint[8] auctionDetails);
  event AuctionBid(uint[9] bidDetails);


  /**
   * @dev Constructor method for GitToken Contract,
   * @param _contributor  address Ethereum Address of the primary contributor or organization owner,
   * @param _username     string  GitHub username of the primary contributor or organization owner,
   * @param _name         string  Name of the GitToken contract (name of organization),
   * @param _organization string  GitHub Organization as it appears in the GitHub organization URL (e.g. https://GitHub.com/git-token),
   * @param _symbol       string  Symbol of the GitToken contract,
   * @param _decimals     uint    Number of decimal representation for token balances;
   */
  function GitToken(
    address _contributor,
    string _username,
    string _name,
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
  function organization() constant returns (string _organization) {
    return gittoken.organization;
  }

  /**
   * @dev Returns the string of the token contract name
   * @return _name string Name of the token contract
   */
  function name() constant returns (string _name) {
    return gittoken.name;
  }

  /**
   * @dev Returns the string of the token contract symbol
   * @return _symbol string Symbol of the token contract
   */
  function symbol() constant returns (string _symbol) {
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
   * @param  _username      string GitHub username of contributor
   * @param  _rewardType    string GitHub Event Reward Type
   * @param  _rewardValue   uint   Number of tokens rewarded to contributor
   * @param  _reservedValue uint   Number of tokens reserved for auction
   * @param  _deliveryID    string GitHub delivery ID of web hook request
   * @return                bool   Returns boolean value if method is called
   */
  function rewardContributor(
    string _username,
    string _rewardType,
    uint _rewardValue,
    uint _reservedValue,
    string _deliveryID
  )
  onlyOwner
  public
  returns (bool) {
    require(gittoken._rewardContributor(_username, _rewardValue, _reservedValue, _deliveryID));
    Contribution(
      gittoken.contributorAddresses[_username],
      _username,
      _rewardType,
      _rewardValue,
      _reservedValue,
      now
    );

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
    uint _tokenLimitFactor,
    bool _lockTokens
  ) onlyOwner public returns (bool) {
    Auction(gittoken._initializeAuction(_initialPrice, _delay, _tokenLimitFactor, _lockTokens));
    return true;
  }

  function executeBid(
    uint _auctionRound,
    uint _exchangeRate
  ) payable public returns (bool) {
    AuctionBid(gittoken._executeBid(_auctionRound, _exchangeRate));
    return true;
  }

  function getAuctionRound() constant returns (uint) {
    return gittoken.auctionRound;
  }

  function getAuctionDetails(uint auctionRound) constant returns(uint[11], uint[], uint[]) {
    return ([
        gittoken.auctionDetails[auctionRound].round,
        gittoken.auctionDetails[auctionRound].startDate,
        gittoken.auctionDetails[auctionRound].endDate,
        gittoken.auctionDetails[auctionRound].lockDate,
        gittoken.auctionDetails[auctionRound].tokensOffered,
        gittoken.auctionDetails[auctionRound].initialPrice,
        gittoken.auctionDetails[auctionRound].wtdAvgExRate,
        gittoken.auctionDetails[auctionRound].fundsCollected,
        gittoken.auctionDetails[auctionRound].fundLimit,
        gittoken.auctionDetails[auctionRound].numBids,
        gittoken.auctionDetails[auctionRound].tokenLimitFactor
      ],
        gittoken.auctionDetails[auctionRound].ethValues,
        gittoken.auctionDetails[auctionRound].exRateValues
      );
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
