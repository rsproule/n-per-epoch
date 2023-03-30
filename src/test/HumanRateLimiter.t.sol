// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./RateLimitedMessenger.sol";
import { MockWorldIdManager } from "./mocks/MockWorldIdManager.sol";
import "./utils/TypeConverter.sol";
import { IWorldID } from "worldcoin/world-id/interfaces/IWorldID.sol";
import { Semaphore as WorldId } from "semaphore/Semaphore.sol";
import { SemaphoreVerifier } from "semaphore/base/SemaphoreVerifier.sol";
import { ByteHasher } from "worldcoin/world-id/libraries/ByteHasher.sol";

contract SendMessageTest is Test {
    using ByteHasher for bytes;
    using TypeConverter for uint256;

    RateLimitedMessenger internal messengerContract;
    WorldId internal worldId;
    MockWorldIdManager internal mockWID;

    function setUp() public {
        // vm.warp(1641070800);
        SemaphoreVerifier verifier = new SemaphoreVerifier();
        worldId = new WorldId(verifier);
        mockWID = new MockWorldIdManager(worldId);
        vm.label(address(verifier), 'Verifier');
        vm.label(address(worldId), 'WorldId');
        vm.label(address(mockWID), 'MockWorldID');
        mockWID.createGroup();
        messengerContract = new RateLimitedMessenger(mockWID);
        vm.label(address(messengerContract), 'messengerContract');
    }

    function testGetSettings() public {
        HumanRateLimiter.Settings memory settings = messengerContract.settings();
        assertEq(settings.groupId, 1);
        assertEq(settings.epochLength, 300);
        assertEq(settings.limitPerEpoch, 1);
    }

    function testSendMessage() public {
        uint256 idCommitment = _genIdentityCommitment();
        mockWID.addMember(idCommitment);
        string memory input = "test message";
        uint256 root = mockWID.getRoot();
        HumanRateLimiter.Settings memory settings = messengerContract.settings();
        HumanRateLimiter.RateLimitKey memory rateLimitKey = _getRateLimitKey(0, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = _genProof(rateLimitKey, input);
        console.log(root);
        console.log(input);
        messengerContract.sendMessage(
            root,
            input,
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
        string[] memory ffiArgs = new string[](7);
        ffiArgs[0] = 'node';
        ffiArgs[1] = '--no-warnings';
        ffiArgs[2] = 'src/test/scripts/generate-proof.js';
        ffiArgs[3] = rateLimitKey.namespace;
        ffiArgs[4] = rateLimitKey.epochId.toString();
        ffiArgs[5] = rateLimitKey.indexId.toString();
        ffiArgs[6] = message;

        bytes memory returnData = vm.ffi(ffiArgs);
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

}
