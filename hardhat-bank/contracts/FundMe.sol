// 20230209 deployed smart contract 0x55833278c264C8CCE77E9a81BB26029cA1dd68a1
// Get funds from users
// Withdraw funds
// Set a minimum funding value is USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// we make mathmatical calculation to library
import "./PriceConverter.sol";

// Error codes
// It makes gas smaller because error character string uses many storage.
error FundMe__NotOwner();

// Interfaces, Libraries, Contracts

/// @title A contract for crowd funding
/// @author Moon MyeongKyun
/// @notice This contract is to demo a sample funding contract
/// @dev This implements price feeds as our library
contract FundMe {
  using PriceConverter for uint256;

  // real USD value
  // constant makes gas smaller.
  uint256 public constant MINIMUM_USD = 50 * 1e18;

  address[] public funders;
  mapping(address => uint256) public addressToAmountFunded;

  // immutable keyword is used when it is in constructor
  address public immutable i_owner;

  AggregatorV3Interface public priceFeed;

  constructor(address priceFeedAddress) {
    i_owner = msg.sender;
    priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  // What happens if someone sends this contract ETH without calling the fund func?

  // receive()
  receive() external payable {
    fund();
  }

  fallback() external payable {
    fund();
  }

  function fund() public payable {
    // Want to be able to set a minumum fund amount
    // 1. How do we send ETH to this contract?
    // assert : for security, require : for mistake
    require(
      msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
      "Didn't send enough!"
    ); // 1e18 = 1 * 10 ** 18
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] += msg.value;
    // block chain don't allow https api

    // What in reverting? undo any action before, and send remaining gas.

    // We can get a ethereum price through chainlink
  }

  function withdraw() public onlyOwner {
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      addressToAmountFunded[funder] = 0;
    }

    // reset the array
    funders = new address[](0);

    // // actually withdraw the funds

    // // transfer
    // // msg.sender = address
    // // payable(msg.sender) = payable address
    // payable(msg.sender).transfer(address(this).balance);

    // // send
    // bool sendSuccess = payable(msg.sender).send(address(this).balance);
    // require(sendSuccess, "Send failed");

    // call
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call failed");
  }

  modifier onlyOwner() {
    if (msg.sender != i_owner) {
      revert FundMe__NotOwner();
    }
    // require(msg.sender == i_owner, "Sender is not owner!");
    // run the rest of the code.
    _;
  }

  // fallback()

  // Explainer from: https://solidity-by-example.org/fallback/
  // Ether is sent to contract
  //      is msg.data empty?
  //          /   \
  //         yes  no
  //         /     \
  //    receive()?  fallback()
  //     /   \
  //   yes   no
  //  /        \
  //receive()  fallback()
}
