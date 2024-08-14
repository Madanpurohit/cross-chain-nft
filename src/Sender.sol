// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnerIsCreator} from "@chainlink/contracts/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/shared/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts/ccip/interfaces/IRouterClient.sol";

contract Sender is OwnerIsCreator {
    /////////////////////////////////////////////////////////////////
    ///////////////////////////ERRORS////////////////////////////////
    /////////////////////////////////////////////////////////////////
    error Sender__notEnoughBalance(uint256 currentBalance, uint256 fees);
    /////////////////////////////////////////////////////////////////
    ///////////////////////////EVENT/////////////////////////////////
    //////////////////////////////////////////////////////////////////

    event Sender__messageSent(
        bytes32 indexed messageId, uint64 indexed destinationChainSelector, address receiver, string msg
    );

    LinkTokenInterface private s_linkToken;
    IRouterClient private s_routerClient;

    constructor(address linkToken, address router) {
        s_linkToken = LinkTokenInterface(linkToken);
        s_routerClient = IRouterClient(router);
    }
    /**
     * @param destinationChainSelector Chain destination selector will be different for different for deferent chain
     * @param receiver receiver contract address
     * @param text message you want to send
     */

    function sendMsg(uint64 destinationChainSelector, address receiver, string calldata text)
        external
        returns (bytes32 messageId)
    {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(text),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            feeToken: address(s_linkToken)
        });
        uint256 fees = s_routerClient.getFee(destinationChainSelector, evm2AnyMessage);
        if (fees > s_linkToken.balanceOf(address(this))) {
            revert Sender__notEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
        }
        s_linkToken.approve(address(s_routerClient), fees);
        messageId = s_routerClient.ccipSend(destinationChainSelector, evm2AnyMessage);
        emit Sender__messageSent(messageId, destinationChainSelector, receiver, text);
        return messageId;
    }
}
