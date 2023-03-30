// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./RateLimitedMessenger.sol";
import "./utils/TypeConverter.sol";
import {WorldIDIdentityManagerTest} from "worldcoin/world-id/test/identity-manager/WorldIDIdentityManagerTest.sol";
import { IWorldID } from "worldcoin/world-id/interfaces/IWorldID.sol";
import { WorldIDIdentityManagerImplV1 } from "worldcoin/world-id/WorldIDIdentityManagerImplV1.sol";
import { WorldIDIdentityManager } from "worldcoin/world-id/WorldIDIdentityManager.sol";
import { ByteHasher } from "worldcoin/world-id/libraries/ByteHasher.sol";

contract SendMessageTest is WorldIDIdentityManagerTest {
    using ByteHasher for bytes;
    using TypeConverter for uint256;

    RateLimitedMessenger public messengerContract;
    WorldIDIdentityManager public worldId;

    function setUp() public override {
        super.setUp();
        vm.warp(1641070800);
        WorldIDIdentityManagerImplV1 worldIdImpl = new WorldIDIdentityManagerImplV1();
        bytes memory callData = abi.encodeCall(
        WorldIDIdentityManagerImplV1.initialize,
            (
                treeDepth,
                initialRoot,
                defaultInsertVerifiers,
                defaultUpdateVerifiers,
                semaphoreVerifier,
                isStateBridgeEnabled,
                stateBridge
            )
        );
        worldId = new WorldIDIdentityManager(address(worldIdImpl), callData);
        messengerContract = new RateLimitedMessenger(IWorldID(worldIdImpl));
    }

    function testGetSettings() public {
        HumanRateLimiter.Settings memory settings = messengerContract.settings();
        assertEq(settings.groupId, 1);
        assertEq(settings.epochLength, 300);
        assertEq(settings.limitPerEpoch, 1);
    }

    function testSendMessage() public {
        string memory input = "test message";
        uint256 root = _getRoot();
        HumanRateLimiter.Settings memory settings = messengerContract.settings();
        HumanRateLimiter.RateLimitKey memory rateLimitKey = _getRateLimitKey(0, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = _genProof(rateLimitKey, input);
        console.log("Proved");
        messengerContract.sendMessage(
            input,
            root,
            nullifierHash,
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

    function _genProof(
            HumanRateLimiter.RateLimitKey memory rateLimitKey,
            string memory message
        ) internal returns (uint256, uint256[8] memory proof) {
        uint256 externalNullifier =  
            abi.encodePacked(rateLimitKey.namespace, rateLimitKey.epochId, rateLimitKey.indexId).hashToField();
        string[] memory ffiArgs = new string[](5);
        ffiArgs[0] = 'node';
        ffiArgs[1] = '--no-warnings';
        ffiArgs[2] = 'src/test/scripts/generate-proof.js';
        ffiArgs[3] = externalNullifier.toString();
        ffiArgs[4] = message;

        bytes memory returnData = vm.ffi(ffiArgs);
        console.log("uherherherh");
        return abi.decode(returnData, (uint256, uint256[8]));
    }

    function _getRateLimitKey(uint256 index, uint256 epochLength)
            internal view returns (HumanRateLimiter.RateLimitKey memory rlk) {
        uint256 currentEpoch = block.timestamp / epochLength;
        return HumanRateLimiter.RateLimitKey(
            "send_message",
            currentEpoch,
            index
        );
    }

    // proxy horrible-ness
    function _getRoot() internal returns (uint256) {
        bytes memory callData = abi.encodeCall(WorldIDIdentityManagerImplV1.latestRoot, ());
        (, bytes memory returnData) = address(worldId).call(callData);
        (uint256 root) = abi.decode(returnData, (uint256));
        return root;
    }

}
