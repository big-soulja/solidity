// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/Strings.sol";

contract moneyPipe{

    uint256 public oldBalance;
    uint256 public totalBalance;
    uint256 public numberOfWallets;
    mapping (address => uint) payout;
    address[] recipients;


    constructor(address[] memory wallets) {
        numberOfWallets = wallets.length;
        recipients = wallets;
    } 

    function checkWallet(address walletInQuestion) public view returns(bool) {
        for(uint i = 0; i < recipients.length; i++) {
            if (recipients[i] == walletInQuestion) { return true; }
        }
        return false;
    }

    function checkYourRoyalties() public view returns(uint) {
        return (totalBalance / numberOfWallets) - payout[msg.sender];
    }

    function updateBalance() public {
        totalBalance += (address(this).balance - oldBalance);
        oldBalance = address(this).balance;
    }

    function getMoney() public payable {
        require(checkWallet(msg.sender), "Not allowed!");
        require(totalBalance + (address(this).balance - oldBalance) / numberOfWallets <= address(this).balance, "Not enough money!");
        updateBalance();
        (bool success, ) = payable(msg.sender).call{value: totalBalance / numberOfWallets - payout[msg.sender]} ('');
        require(success);
        payout[msg.sender] += totalBalance / numberOfWallets - payout[msg.sender];
    }

    function donate(address payable donationDestination) public payable {
        uint donation = msg.value;
        donationDestination.transfer(donation - donation / 10);
    }

}
// [0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db]