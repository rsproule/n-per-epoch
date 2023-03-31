// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";
import {ExampleNPerEpochContract} from "./ExampleNPerEpochContract.sol";
import {InteractsWithWorldID} from "./helpers/InteractsWithWorldID.sol";
import { NPerEpoch } from "../NPerEpoch.sol";

contract NPerEpochTest is Test, InteractsWithWorldID {
    ExampleNPerEpochContract internal messengerContract;

    function nodePath() public pure override returns (string memory) {
        return "node_modules/ts-node/dist/bin.js";
    }

    function proofGenPath() public pure override returns (string memory) {
        return "src/test/scripts/generate-proof.ts";
    }

    function genIdPath() public pure override returns (string memory) {
        return "src/test/scripts/generate-commitment.ts";
    }

    function setUp() public {
        setUpWorldID();
        // update any constructor parameters you need here!
        messengerContract = new ExampleNPerEpochContract(worldID);

        vm.label(address(this), "Sender");
        vm.label(address(messengerContract), "RateLimitMessenger");
    }
    function _getRateLimitKey(uint256 index, uint256 epochLength)
            internal view returns (NPerEpoch.RateLimitKey memory) {
        uint256 currentEpoch = block.timestamp / epochLength;
        return NPerEpoch.RateLimitKey(
            "send_message",
            currentEpoch,
            index
        );
    }

    function testSendMessage() public {
        registerIdentity();
        string memory input = "test message";
        NPerEpoch.Settings memory settings = messengerContract.settings();
        NPerEpoch.RateLimitKey memory rateLimitKey = _getRateLimitKey(1, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = getProof(rateLimitKey, input);
        messengerContract.sendMessage(
            getRoot(),
            input,
            nullifierHash,
            proof,
            rateLimitKey
        );
    }

  function testCannotDoubleSendSendMessage() public {
        registerIdentity();
        string memory input = "test message";
        NPerEpoch.Settings memory settings = messengerContract.settings();
        NPerEpoch.RateLimitKey memory rateLimitKey = _getRateLimitKey(1, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = getProof(rateLimitKey, input);
        messengerContract.sendMessage(
            getRoot(),
            input,
            nullifierHash,
            proof,
            rateLimitKey
        );
        uint256 root = getRoot();
        vm.expectRevert(NPerEpoch.InvalidNullifier.selector);
        messengerContract.sendMessage(
            root,
            input,
            nullifierHash,
            proof,
            rateLimitKey
        );
    }
  
    function testCannotCallIfNotMember() public {
        registerInvalidIdentity();
        string memory input = "test message";
        NPerEpoch.Settings memory settings = messengerContract.settings();
        NPerEpoch.RateLimitKey memory rateLimitKey = _getRateLimitKey(1, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = getProof(rateLimitKey, input);
        uint256 root = getRoot();
        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        messengerContract.sendMessage(
            root,
            input,
            nullifierHash,
            proof,
            rateLimitKey
        );
    }

    function testCannotCallWithInvalidSignal() public {
        registerIdentity();
        string memory input = "test message";
        NPerEpoch.Settings memory settings = messengerContract.settings();
        NPerEpoch.RateLimitKey memory rateLimitKey = _getRateLimitKey(1, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = getProof(rateLimitKey, input);
        uint256 root = getRoot();
        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        messengerContract.sendMessage(
            root,
            "random garbage",
            nullifierHash,
            proof,
            rateLimitKey
        );
    }
    
   function testCannotCallWithInvalidProof() public {
        registerIdentity();
        string memory input = "test message";
        NPerEpoch.Settings memory settings = messengerContract.settings();
        NPerEpoch.RateLimitKey memory rateLimitKey = _getRateLimitKey(1, settings.epochLength);
        (uint256 nullifierHash, uint256[8] memory proof) = getProof(rateLimitKey, input);
        proof[0] ^= 42;
        uint256 root = getRoot();
        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        messengerContract.sendMessage(
            root,
            input,
            nullifierHash,
            proof,
            rateLimitKey
        );
    }
}
