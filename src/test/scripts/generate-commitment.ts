
import { Identity } from "@semaphore-protocol/identity";
import { defaultAbiCoder as abi } from "@ethersproject/abi";

function main() {
  const identity = new Identity("test-identity");

  process.stdout.write(
    abi.encode(["uint256"], [identity.getCommitment()])
  );
}

main();
