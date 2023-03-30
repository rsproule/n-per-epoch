// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ByteHasher } from "worldcoin/world-id/libraries/ByteHasher.sol";
import { WorldIDIdentityManager as WorldID } from "worldcoin/world-id/WorldIDIdentityManager.sol";
import { IWorldID } from "worldcoin/world-id/interfaces/IWorldID.sol";
import { HumanRateLimiter } from "../HumanRateLimiter.sol";

contract RateLimitedMessenger is HumanRateLimiter {
    using ByteHasher for bytes;

    error MismatchedMessage();
    error InvalidActionId();
    event Message(string message);

    mapping(uint256 => bool) internal nullifierHashes;

    constructor(IWorldID _worldId) HumanRateLimiter(_worldId) {}

    function sendMessage(
        uint256 root,
        string calldata input,
        uint256 nullifierHash,
        uint256[8] calldata proof,
        RateLimitKey calldata actionId
    )
        public rateLimit(
            root, 
            abi.encodePacked(input).hashToField(), 
            nullifierHash, 
            actionId, 
            proof
        )
    {
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();
        nullifierHashes[nullifierHash] = true;
        emit Message(input);
    }

    function settings()
        public
        pure
        virtual
        override
        returns (HumanRateLimiter.Settings memory)
    {
        return Settings(1, 300, 1);
    }

}
