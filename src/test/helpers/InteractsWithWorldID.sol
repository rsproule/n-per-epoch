// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Vm} from "forge-std/Vm.sol";
import {IWorldID} from "../../interfaces/IWorldID.sol";
import {Semaphore} from "worldcoin/world-id/Semaphore.sol";
import {TypeConverter} from "./TypeConverter.sol";
import { NPerEpoch } from "../../NPerEpoch.sol";

abstract contract InteractsWithWorldID {
    using TypeConverter for uint256;
    using TypeConverter for address;

    Vm public wldVM =
        Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
    Semaphore internal semaphore;
    IWorldID internal worldID;

    function setUpWorldID() public {
        semaphore = new Semaphore();
        semaphore.createGroup(1, 20, 0);

        worldID = IWorldID(address(semaphore));

        wldVM.label(address(worldID), "WorldID");
    }

    function registerIdentity() public {
        semaphore.addMember(1, _genIdentityCommitment());
    }

    function registerInvalidIdentity() public {
        semaphore.addMember(1, 1);
    }

    function getRoot() public view returns (uint256) {
        return semaphore.getRoot(1);
    }

    function _genIdentityCommitment() internal returns (uint256) {
        string[] memory ffiArgs = new string[](2);
        ffiArgs[0] = string.concat(pathPrefix(), "node_modules/ts-node/dist/bin.js");
        ffiArgs[1] = string.concat(pathPrefix(), "src/test/scripts/generate-commitment.ts");

        bytes memory returnData = wldVM.ffi(ffiArgs);
        return abi.decode(returnData, (uint256));
    }

    function getProof(NPerEpoch.RateLimitKey memory rateLimitKey, string memory message)
        internal
        returns (uint256, uint256[8] memory proof)
    {
        // increase the lenght of the array if you have multiple parameters as signal
        string[] memory ffiArgs = new string[](7);
        ffiArgs[0] = string.concat(pathPrefix(), "node_modules/ts-node/dist/bin.js");
        ffiArgs[1] = string.concat(pathPrefix(), "src/test/scripts/generate-proof.ts");
        ffiArgs[2] = pathPrefix();
        ffiArgs[3] = rateLimitKey.namespace;
        ffiArgs[4] = rateLimitKey.epochId.toString();
        ffiArgs[5] = rateLimitKey.indexId.toString();
        ffiArgs[6] = message;

        bytes memory returnData = wldVM.ffi(ffiArgs);

        return abi.decode(returnData, (uint256, uint256[8]));
    }
    
    function pathPrefix() public virtual returns (string memory);
}
