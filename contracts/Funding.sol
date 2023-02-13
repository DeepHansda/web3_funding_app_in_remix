// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
error NotOwner();

contract Funding {
    // uint256 public amount;
    using PriceConverter for uint256;

    address public org_owner;
    uint256 public constant MINIMUM_USD = 2 * 10**18;
    uint256 public balance;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    constructor() {
        org_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.convertPrice() >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
        balance = address(this).balance;
    }

    function getVersion() public view returns (uint256) {
        // ETH/USD price feed address of Goerli Network.
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        return priceFeed.version();
    }

    modifier onlyOwner() {
        if (msg.sender != org_owner) revert NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex > funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }
}
