pragma solidity ^0.4.15;

import './SafeMath.sol';
import './GitToken.sol';
import './Signed.sol';

contract GitTokenAuction is Signed {

  using SafeMath for uint;
  using SafeMath for uint[];

  struct Auction {
    uint startDate;
    uint endDate;
    uint lockDate;
    uint tokensOffered;
    uint initialPrice;
    uint fundsCollected;
    uint numBids;
    uint wtdAvgPrice;
    uint[] values;
    uint[] prices;
  }

  mapping(address => mapping(uint => Auction)) auctions;
  mapping(address => uint) rounds;

  event NewAuction(
    address indexed gittoken,
    uint round,
    uint startDate,
    uint endDate,
    uint tokensOffered,
    uint initialPrice
  );

  event Bid(address indexed gittoken, address bidder, uint round, uint price, uint tokens, uint value);

  function GitTokenAuction() Signed(msg.sender) public {}

  function init(address _gittoken, uint _minPrice) onlyGitTokenSigner(_gittoken) public returns(bool success) {
      /*require(auctions[_gittoken][rounds[_gittoken]].endDate < now); //*/
      require(GitToken(_gittoken).balanceOf(address(this)) > 0); // ensure contract has tokens to auction

      rounds[_gittoken] += 1;

      auctions[_gittoken][rounds[_gittoken]].startDate = now + 86400*3; // t+3 days
      auctions[_gittoken][rounds[_gittoken]].endDate = now + 86400*12; // t+12 days
      auctions[_gittoken][rounds[_gittoken]].tokensOffered = GitToken(_gittoken).balanceOf(address(this)); // currently held token balance
      auctions[_gittoken][rounds[_gittoken]].initialPrice = _minPrice;

      NewAuction(
        _gittoken,
        rounds[_gittoken],
        auctions[_gittoken][rounds[_gittoken]].startDate,
        auctions[_gittoken][rounds[_gittoken]].endDate,
        auctions[_gittoken][rounds[_gittoken]].tokensOffered,
        auctions[_gittoken][rounds[_gittoken]].initialPrice
      );

      return true;
  }

  function bid( address _gittoken, uint _price) payable validate(_gittoken, _price)
    public returns(bool success)
  {
    auctions[_gittoken][rounds[_gittoken]].values.push(msg.value);
    auctions[_gittoken][rounds[_gittoken]].prices.push(_price);

    auctions[_gittoken][rounds[_gittoken]].wtdAvgPrice =
      auctions[_gittoken][rounds[_gittoken]].values.wtdAvg(
        auctions[_gittoken][rounds[_gittoken]].prices
      );

    uint tokens = (msg.value / auctions[_gittoken][rounds[_gittoken]].wtdAvgPrice);

    require(GitToken(_gittoken).transfer(msg.sender, tokens));

    Bid(_gittoken,
      msg.sender,
      rounds[_gittoken],
      auctions[_gittoken][rounds[_gittoken]].wtdAvgPrice,
      tokens,
      msg.value
    );

    return true;
  }

  modifier validate(address _gittoken, uint _price) {
      /*require(auctions[_gittoken][rounds[_gittoken]].startDate <= now); // ensure the start date as started
      require(auctions[_gittoken][rounds[_gittoken]].endDate >= now); // ensure that the end date has not expired*/
      require(msg.value >= _price && _price > 0);
      _;
  }

  modifier onlyGitTokenSigner(address _gittoken) {
      require(GitToken(_gittoken).isSigner(msg.sender));
      _;
  }

}
