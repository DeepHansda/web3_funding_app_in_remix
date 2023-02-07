// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './PriceConverter.sol';
contract Funding{
    // uint256 public amount;
    using PriceConverter for uint256;
  
    address public org_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    function fund() public payable{
      require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
    }

    constructor(){
        org_owner = msg.sender;
    } 
}