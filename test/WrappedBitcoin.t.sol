// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {WrappedBitcoin, DropBox, IBitcoin} from "src/WrappedBitcoin.sol";
import "forge-std/Test.sol";

contract WrappedBitcoinTest is Test {
    address constant OWNER = address(0xC701E3D2DcCf4115D87a92f2a6E0eeEF2f0D0F25);

    WrappedBitcoin wbtc;
    IBitcoin btc;

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL_MAINNET"));
        vm.deal(OWNER, 100e18);

        wbtc = new WrappedBitcoin();
        btc = IBitcoin(wbtc.underlying());

        vm.prank(OWNER);
        wbtc.createDropBox();
    }

    function testOwnerBalance() public {
        vm.startPrank(OWNER);

        uint256 balance = btc.balanceOf(OWNER);
        console2.log("Owner balance: %s", balance);
        assertTrue(balance > 0);
    }

    function testBitcoinDecimals() public {
        uint256 decimals = btc.decimals();
        console2.log("Bitcoin decimals: %s", decimals);
        assertEq(decimals, 8);
    }

    function testWrap() public {
        vm.startPrank(OWNER);

        uint256 balance = btc.balanceOf(OWNER);
        console2.log("Owner balance: %s", balance);
        assertTrue(balance > 0);

        btc.transfer(wbtc.dropBoxes(OWNER), balance);
        assertEq(btc.balanceOf(wbtc.dropBoxes(OWNER)), balance);
        assertEq(btc.balanceOf(OWNER), 0);

        wbtc.deposit(balance);
        balance = wbtc.balanceOf(OWNER);
        console2.log("Owner wrapped balance: %s", balance);
        assertEq(wbtc.balanceOf(OWNER), balance);
        assertEq(btc.balanceOf(wbtc.dropBoxes(OWNER)), 0);
        assertEq(btc.balanceOf(OWNER), 0);
        assertEq(btc.balanceOf(address(wbtc)), balance);
    }

    function testUnwrap() public {
        vm.startPrank(OWNER);

        uint256 balance = btc.balanceOf(OWNER);
        console2.log("Owner balance: %s", balance);
        assertTrue(balance > 0);

        btc.transfer(wbtc.dropBoxes(OWNER), balance);
        assertEq(btc.balanceOf(wbtc.dropBoxes(OWNER)), balance);
        assertEq(btc.balanceOf(OWNER), 0);

        wbtc.deposit(balance);
        uint256 wrappedBalance = wbtc.balanceOf(OWNER);
        console2.log("Owner wrapped balance: %s", wrappedBalance);
        assertEq(wbtc.balanceOf(OWNER), balance);
        assertEq(btc.balanceOf(wbtc.dropBoxes(OWNER)), 0);
        assertEq(btc.balanceOf(OWNER), 0);
        assertEq(btc.balanceOf(address(wbtc)), balance);

        wbtc.withdraw(wrappedBalance);
        balance = btc.balanceOf(OWNER);
        wrappedBalance = wbtc.balanceOf(OWNER);
        console2.log("Owner balance: %s", balance);
        console2.log("Owner wrapped balance: %s", wrappedBalance);
        assertEq(wbtc.balanceOf(OWNER), 0);
        assertEq(btc.balanceOf(wbtc.dropBoxes(OWNER)), 0);
        assertEq(btc.balanceOf(OWNER), balance);
        assertEq(btc.balanceOf(address(wbtc)), 0);
    }
}
