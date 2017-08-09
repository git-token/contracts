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
 * @author Ryan Michael Tate <ryan.tate@gittoken.io>
 */
library GitTokenLib {

  using SafeMath for uint;

  struct Auction {
    uint round;
    uint startDate;
    uint endDate;
    uint tokensOffered;
    uint initialPrice;
    uint weightedAveragePrice;
  }

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
    uint auctionRound;
    uint lockTokenTransfersUntil;
    mapping(uint => Auction) auctionDetails;
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
  function _transfer(Data storage self, address _to, uint _value) internal returns (bool) {
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
    if(_value == 0 && _reservedValue == 0){
      throw;
      // If the GitHub web hook event ID has already occured, then throw the transaction;
    } else if(self.receivedDelivery[_deliveryID] == true) {
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

      // Set the received deliveries for this event to true to prevent/mitigate event replay attacks;
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
    require(_contributor != 0x0);

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
   * @dev Internal Initialize Auction
   * @param  _initialPrice uint Token/ETH Exchange Rate (#Tokens / 1 ETH)
   * @param  _delay        uint Time in milliseconds to delay each auction period (I - Pre, II - Start, III - End, IV - Post)
   * @param  _lockTokens   bool Boolean value to optionally lock all token transfers until the Post auction date.
   * @return               bool Returns Boolean value when called from parent contract;
   */
  function _initializeAuction(
    Data storage self,
    uint _initialPrice,
    uint _delay,
    bool _lockTokens
  ) internal returns(bool) {
    // Ensure the contract has enough tokens to move to auction;

    uint initialPrice = 10 ** 18 / (10 ** 18 / 10 ** self.decimals) * _initialPrice;

    if(self.balances[address(this)] == 0 || initialPrice == 0) {
      throw;
    } else if (initialPrice > self.balances[address(this)]) {
      throw;
    } else {
      self.auctionRound += 1;

      /*uint delay     = _delay > 60*60*24 ? _delay : 60*60*24*3;*/
      uint delay     = _delay > 0 ? _delay : 60*60*24*3;
      uint startDate = now.add(delay);
      uint endDate   = startDate.add(delay);

      self.auctionDetails[self.auctionRound] = Auction(
        self.auctionRound,
        startDate,
        endDate,
        self.balances[address(this)],
        initialPrice,
        0
      );

      _lockTokens == true ?
        self.lockTokenTransfersUntil = endDate.add(delay) :
        self.lockTokenTransfersUntil = 0;

      return true;
    }
  }

  /**
   * @dev Internal
   */
  function _sealAuction(Data storage self, uint _auctionRound, uint _weightedAveragePrice)
    internal returns (bool) {
    require(now >= self.auctionDetails[_auctionRound].endDate);
    self.auctionDetails[_auctionRound].weightedAveragePrice = _weightedAveragePrice;
    return true;
  }

  /**
   * @dev Internal
   */
  function _executeBid(Data storage self, uint _auctionRound, address _bidder, uint _eth )
    internal returns (uint _tokenValue) {
    uint tokenValue = _eth / (10 ** 18 / 10 ** self.decimals) * self.auctionDetails[_auctionRound].weightedAveragePrice;

    require(tokenValue > 0);
    require(self.auctionDetails[_auctionRound].tokensOffered > 0);
    require(self.auctionDetails[_auctionRound].tokensOffered > tokenValue);
    require(now >= self.auctionDetails[_auctionRound].endDate);

    self.balances[address(this)] = self.balances[address(this)].sub(tokenValue);
    self.auctionDetails[_auctionRound].tokensOffered = self.auctionDetails[_auctionRound].tokensOffered.sub(tokenValue);
    self.balances[_bidder] = self.balances[_bidder].add(tokenValue);

    return tokenValue;
  }

}
