// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {ByteHasher} from "../helpers/ByteHasher.sol";
import {IWorldID} from "../interfaces/IWorldID.sol";
import { NPerEpoch} from "../NPerEpoch.sol";

contract ExampleNPerEpochContract is NPerEpoch {
    using ByteHasher for bytes;

    error MismatchedMessage();
    error InvalidActionId();
    event Message(string message);

    mapping(uint256 => bool) internal nullifierHashes;

    constructor(IWorldID _worldId) NPerEpoch(_worldId) {}

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
        if (keccak256(abi.encodePacked(actionId.namespace)) != keccak256(abi.encodePacked("send_message"))) revert InvalidNullifier();
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();
        nullifierHashes[nullifierHash] = true;
        emit Message(input);
    }

    function settings()
        public
        pure
        virtual
        override
        returns (NPerEpoch.Settings memory)
    {
        return Settings(1, 300, 2);
    }

}
