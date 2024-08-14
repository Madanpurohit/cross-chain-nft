// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Client} from "@chainlink/contracts/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts/ccip/applications/CCIPReceiver.sol";
import {MoodNft} from "../src/MoodNft.sol";

contract Receiver is CCIPReceiver {
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        string text //The text that was received.
    );

    bytes32 private s_lastReceivedMsgId;
    string private s_lastMsg;
    MoodNft private s_moodNft;

    constructor(address router,address nft) CCIPReceiver(router){
        s_moodNft = MoodNft(nft);
    }
    receive() external payable{}
    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        s_lastReceivedMsgId = message.messageId;
        s_lastMsg = abi.decode(message.data, (string));
        address addressOnMint = address(bytes20(bytes(s_lastMsg)));
        s_moodNft.mintNft(addressOnMint);
        emit MessageReceived(
            message.messageId,
            message.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(message.sender, (address)), // abi-decoding of the sender address,
            abi.decode(message.data, (string))
        );
    }

    function getLastReceivedMessageDetails()
        external
        view
        returns (bytes32 messageId, string memory text)
    {
        return (s_lastReceivedMsgId, s_lastMsg);
    }
}