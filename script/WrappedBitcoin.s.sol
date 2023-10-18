// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {WrappedBitcoin} from "src/WrappedBitcoin.sol";
import "forge-std/Script.sol";

contract WrappedBitcoinScript is Script {
    function run() external returns (WrappedBitcoin deployment) {
        vm.startBroadcast();

        deployment = new WrappedBitcoin();

        vm.stopBroadcast();
    }
}
