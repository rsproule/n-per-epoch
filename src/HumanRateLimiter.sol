// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import { ByteHasher } from "worldcoin/world-id/libraries/ByteHasher.sol";
import { IWorldID } from "worldcoin/world-id/interfaces/IWorldID.sol";
import "forge-std/Test.sol";

abstract contract HumanRateLimiter {
    using ByteHasher for bytes;
    error InvalidNullifier();
    IWorldID public immutable worldId;

    constructor(IWorldID _worldID) {
        worldId = _worldID;
    }

    struct RateLimitKey {
        string namespace;
        uint256 epochId;
        uint256 indexId;
    }

    modifier rateLimit(
        uint256 inputHash,
        uint256 root,
        uint256 nullifierHash,
        RateLimitKey calldata rateLimitKey,
        uint256[8] calldata proof
    ) {
        Settings memory _settings = settings();
        uint256 currentEpoch = block.timestamp / _settings.epochLength;
        if (currentEpoch != rateLimitKey.epochId) revert InvalidNullifier();
        if (rateLimitKey.indexId >= _settings.limitPerEpoch) revert InvalidNullifier();
        console.log("verifying proof");
        worldId.verifyProof(
            root,
            inputHash,
            nullifierHash,
            abi.encodePacked(rateLimitKey.namespace, rateLimitKey.epochId, rateLimitKey.indexId).hashToField(),
            proof
        );
        _;
    }

    function settings() public virtual returns (Settings memory);

    struct Settings {
        uint256 groupId; 
        uint256 epochLength;
        uint256 limitPerEpoch;
    }
}
