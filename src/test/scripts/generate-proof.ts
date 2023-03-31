import { Identity } from "@semaphore-protocol/identity";
import { Group } from "@semaphore-protocol/group";
import { generateProof } from "@semaphore-protocol/proof";
import { keccak256, pack } from "@ethersproject/solidity";
import { defaultAbiCoder as abi } from "@ethersproject/abi";
import { BigNumber } from "@ethersproject/bignumber";

function hashBytes(signal: string, type = "bytes") {
  return BigInt(keccak256([type], [signal])) >> BigInt(8);
}

async function main(
  namespace: string,
  epochId: string,
  indexId: string,
  signal: string
) {
  const identity = new Identity("test-identity");
  const group = new Group(1);
  const identityCommitment = identity.getCommitment();
  const externalNullifier = hashBytes(
    pack(
      ["string", "uint256", "uint256"],
      [
        namespace,
        BigNumber.from("0x" + epochId),
        BigNumber.from("0x" + indexId),
      ]
    )
  );

  group.addMembers([identityCommitment]);
  const fullProof = await generateProof(
    identity,
    group,
    externalNullifier,
    pack(["string"], [signal]),
    {
      zkeyFilePath:
        "./lib/world-id-contracts/lib/semaphore/snark-artifacts/20/semaphore.zkey",
      wasmFilePath:
        "./lib/world-id-contracts/lib/semaphore/snark-artifacts/20/semaphore.wasm",
    }
  );
  process.stdout.write(
    abi.encode(
      ["uint256", "uint256[8]"],
      [fullProof.nullifierHash, fullProof.proof]
    )
  );
}
//@ts-ignore
main(...process.argv.splice(2)).then(() => process.exit(0));
