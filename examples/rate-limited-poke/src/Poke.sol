// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {NPerEpoch} from "n-per-epoch/NPerEpoch.sol";
import {IWorldID} from "n-per-epoch/interfaces/IWorldID.sol";

contract Poke is NPerEpoch {
    event Poked(address sender);

    constructor(IWorldID worldId) NPerEpoch(worldId) {}

    function poke(
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof,
        RateLimitKey calldata actionId
    ) public rateLimit(
            root, 
            0, 
            nullifierHash, 
            actionId, 
            proof
    ) {
        emit Poked(msg.sender);
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
