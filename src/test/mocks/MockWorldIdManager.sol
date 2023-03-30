// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { IWorldID } from "worldcoin/world-id/interfaces/IWorldID.sol";
import { Semaphore } from "semaphore/Semaphore.sol";

contract MockWorldIdManager is IWorldID {
    Semaphore internal immutable semaphore;
    uint256 internal groupId;

    constructor(Semaphore _worldId) {
        semaphore = _worldId;
        groupId = 1;
    }

    function verifyProof(
        uint256 root,
        uint256 signalHash,
        uint256 nullifierHash,
        uint256 externalNullifierHash,
        uint256[8] calldata proof
    ) external {
        semaphore.verifyProof(
            groupId,
            root,
            signalHash,
            nullifierHash,
            externalNullifierHash,
            proof
        );
    }

    function getRoot() external returns (uint256) {
        return semaphore.getMerkleTreeRoot(groupId);
    }

    function createGroup() external {
        semaphore.createGroup(groupId, 20, address(this));
    } 

    function addMember(uint256 identityCommitment) external {
        semaphore.addMember(groupId, identityCommitment);
    }
}