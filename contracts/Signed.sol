pragma solidity ^0.4.15;


contract Signed {

    address public signer;

    function Signed(address _signer) public {
        signer = _signer;
    }

    modifier onlySigner() {
        require(signer == msg.sender);
        _;
    }
}
