// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/test/RateLimitedMessenger.sol";
import { IWorldID } from "worldcoin/world-id/interfaces/IWorldID.sol";
import { WorldIDIdentityManagerImplV1 } from "worldcoin/world-id/WorldIDIdentityManagerImplV1.sol";

contract SendMessageTest is Test {
    RateLimitedMessenger public messengerContract;

    function setUp() public {
        IWorldID worldId = new WorldIDIdentityManagerImplV1();
        messengerContract = new RateLimitedMessenger(worldId);
    }

    function testGetSettings() public {
        (uint groupId, uint256 epochLength, uint256 limitPerEpoch) = messengerContract.settings();
        assertEq(groupId, 1);
        assertEq(epochLength, 300);
        assertEq(limitPerEpoch, 1);
    }

    function testSendMessage() public {
        string calldata input = "test message";
        uint256 root = worldId.getRoot();
        HumanRateLimiter.RateLimitKey rateLimitKey = HumanRateLimiter.RateLimitKey {
            namespace: "send_message",
            epochId: 12, // TODO 
            indexId: 0
        };
        (uint256 nullifierHash, uint256[8] calldata proof) = _genProof(rateLimitKey, input);
        messengerContract.sendMessage(
            input,
            root,
            nulliferHash,
            proof,
            rateLimitKey
        );
    }
    function _genIdentityCommitment() internal returns (uint256) {
        string[] memory ffiArgs = new string[](2);
        ffiArgs[0] = 'node';
        ffiArgs[1] = 'src/test/scripts/generate-commitment.js';

        bytes memory returnData = vm.ffi(ffiArgs);
        return abi.decode(returnData, (uint256));
    }

    function _genProof(uint256 profileId) internal returns (uint256, uint256[8] memory proof) {
        string[] memory ffiArgs = new string[](5);
        ffiArgs[0] = 'node';
        ffiArgs[1] = '--no-warnings';
        ffiArgs[2] = 'src/test/scripts/generate-proof.js';
        ffiArgs[3] = 'wid_staging_12345678';
        ffiArgs[4] = profileId.toString();

        bytes memory returnData = vm.ffi(ffiArgs);

        return abi.decode(returnData, (uint256, uint256[8]));
    }

    function _getRateLimitKey() internal returns (HumanRateLimiter.RateLimitKey rlk) {
                // const epoch = Math.floor(Date.now() / (epochLength.toNumber() * 1000)) + epochForward;
        return HumanRateLimiter.RateLimitKey(
            "send_message",
            epoch,
            index
        );
    }
}
