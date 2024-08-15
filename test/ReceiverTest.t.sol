// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test} from "forge-std/Test.sol";
import {DeployMoodNftAndReceiver} from "../script/DeployMoodNftAndReceiver.s.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Receiver} from "../src/Receiver.sol";
import {Client} from "@chainlink/contracts/ccip/libraries/Client.sol";

contract ReceiverTest is Test{
    MoodNft moodNft;
    Receiver receiver;
    DeployMoodNftAndReceiver deployMoodNftAndReceiver;
    address private USER_1 = makeAddr('user');
    function setUp() public {
        deployMoodNftAndReceiver = new DeployMoodNftAndReceiver();
        //vm.startBroadcast();
        (moodNft,receiver) = deployMoodNftAndReceiver.run();
        //vm.startBroadcast();
    }

    function test_userAbleToMintNft() external {
        string memory user = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        vm.prank(USER_1);
        //vm.startBroadcast();
        payable(address(receiver)).call{value: 1 ether}("");
        Client.Any2EVMMessage memory message = Client.Any2EVMMessage({
           messageId : bytes32("0008990"),
           sourceChainSelector: 16015286601757825753,
           sender: bytes("89890808"),
           data: abi.encode(user),
           destTokenAmounts: new Client.EVMTokenAmount[](0)
        });
        receiver.externalCCIPReceive(message);
        uint256 balance = moodNft.balanceOf(USER_1);
        //vm.startBroadcast();
        //console.log("balance is ",balance);
        assertEq(balance,1);
    }
}