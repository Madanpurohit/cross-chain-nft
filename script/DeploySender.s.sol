// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";
import {Sender} from "../src/Sender.sol";

contract DeploySender is Script{
    function run() external {
        vm.startBroadcast();
        Sender sender = new Sender(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,0xF694E193200268f9a4868e4Aa017A0118C9a8177);
        vm.stopBroadcast();
    }
}