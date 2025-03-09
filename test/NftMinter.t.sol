// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;
import {Test, console} from "forge-std/Test.sol";
import {NftMinter} from "../src/NftMinter.sol";

contract NftMinterTest is Test {
    NftMinter public nftMinter;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(1);
        user1 = address(2);
        user2 = address(3);

        console.log("Owner: ", owner);
        console.log("User 1: ", user1);
        console.log("User 2: ", user2);

        vm.prank(owner);
        nftMinter = new NftMinter();
    }

    function test_MintFailsWithoutFee() public {
        vm.prank(user1);
        vm.expectRevert("Must send 0.02 ETH to mint");
        nftMinter.mint("NFT", "NFT Description", "ipfs://");
    }

    function test_Mint() public {
        vm.deal(user1, 1 ether); // Give user1 some ETH
        vm.startPrank(user1);

        nftMinter.mint{value: 0.02 ether}("NFT", "NFT Description", "ipfs://");

        (
            string memory name,
            string memory description,
            string memory ipfsURL,
            address nftOwner
        ) = nftMinter.getNFTDetails(0);

        assertEq(name, "NFT");
        assertEq(description, "NFT Description");
        assertEq(ipfsURL, "ipfs://");
        assertEq(nftOwner, user1);
        assertEq(nftMinter.balanceOf(user1), 1);

        vm.stopPrank();
    }

    function test_MintFeeTransfer() public {
        vm.deal(user1, 1 ether); // Fund user1 with one ether

        uint256 initialBalance = address(owner).balance; // Check contract balance
        console.log("Initial balance: ", initialBalance);

        vm.startPrank(user1);
        nftMinter.mint{value: 0.02 ether}("NFT", "NFT Description", "ipfs://");
        vm.stopPrank();

        assertEq(address(owner).balance, initialBalance + 0.02 ether); // Contract balance should increase
    }
}
