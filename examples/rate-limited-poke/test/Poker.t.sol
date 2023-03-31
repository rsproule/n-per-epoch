// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Poke.sol";
import {InteractsWithWorldID} from "n-per-epoch/test/helpers/InteractsWithWorldID.sol";
import { NPerEpoch } from "n-per-epoch/NPerEpoch.sol";

contract PokeTest is Test, InteractsWithWorldID {
    Poke public poker;

    function setUp() public {
        setUpWorldID();
        poker = new Poke(worldID);
        vm.label(address(poker), "Poker");
    }

    function testPoke() public {
        registerIdentity();
        NPerEpoch.Settings memory settings = poker.settings();
        NPerEpoch.RateLimitKey memory rateLimitKey = _getRateLimitKey(1, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = getProof(rateLimitKey, "poke");
        poker.poke(
            getRoot(),
            nullifierHash,
            proof,
            rateLimitKey
        );
    }
    function _getRateLimitKey(uint256 index, uint256 epochLength)
            internal view returns (NPerEpoch.RateLimitKey memory) {
        uint256 currentEpoch = block.timestamp / epochLength;
        return NPerEpoch.RateLimitKey(
            "poke",
            currentEpoch,
            index
        );
    }
}
