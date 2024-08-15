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
        address creator = stringToAddress(s_lastMsg);
        s_moodNft.mintNft(creator);
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
    function externalCCIPReceive(Client.Any2EVMMessage memory message) external {
        _ccipReceive(message); // for test only not for deployment
    }

    function stringToAddress(string memory str) internal pure returns (address) {
        bytes memory strBytes = bytes(str);
        require(strBytes.length == 42, "Invalid address length");
        bytes memory addrBytes = new bytes(20);

        for (uint i = 0; i < 20; i++) {
            addrBytes[i] = bytes1(hexCharToByte(strBytes[2 + i * 2]) * 16 + hexCharToByte(strBytes[3 + i * 2]));
        }

        return address(uint160(bytes20(addrBytes)));
    }

    function hexCharToByte(bytes1 char) internal pure returns (uint8) {
        uint8 byteValue = uint8(char);
        if (byteValue >= uint8(bytes1('0')) && byteValue <= uint8(bytes1('9'))) {
            return byteValue - uint8(bytes1('0'));
        } else if (byteValue >= uint8(bytes1('a')) && byteValue <= uint8(bytes1('f'))) {
            return 10 + byteValue - uint8(bytes1('a'));
        } else if (byteValue >= uint8(bytes1('A')) && byteValue <= uint8(bytes1('F'))) {
            return 10 + byteValue - uint8(bytes1('A'));
        }
        revert("Invalid hex character");
    }
}