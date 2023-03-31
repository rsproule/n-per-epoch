import { poseidon_gencontract as poseidonContract } from "circomlibjs"
import { Contract } from "ethers"
import { task, types } from "hardhat/config"

task("deploy:quin-tree-test", "Deploy a QuinTreeTest contract")
  .addOptionalParam<boolean>("logs", "Print the logs", true, types.boolean)
  .setAction(async ({ logs }, { ethers }): Promise<Contract> => {
    const poseidonT6ABI = poseidonContract.generateABI(5)
    const poseidonT6Bytecode = poseidonContract.createCode(5)

    const [signer] = await ethers.getSigners()

    const PoseidonLibT6Factory = new ethers.ContractFactory(poseidonT6ABI, poseidonT6Bytecode, signer)
    const poseidonT6Lib = await PoseidonLibT6Factory.deploy()

    await poseidonT6Lib.deployed()

    if (logs) {
      console.info(`PoseidonT6 library has been deployed to: ${poseidonT6Lib.address}`)
    }

    const IncrementalQuinTreeLibFactory = await ethers.getContractFactory("IncrementalQuinTree", {
      libraries: {
        PoseidonT6: poseidonT6Lib.address
      }
    })
    const incrementalQuinTreeLib = await IncrementalQuinTreeLibFactory.deploy()

    await incrementalQuinTreeLib.deployed()

    if (logs) {
      console.info(`IncrementalQuinTree library has been deployed to: ${incrementalQuinTreeLib.address}`)
    }

    const ContractFactory = await ethers.getContractFactory("QuinTreeTest", {
      libraries: {
        IncrementalQuinTree: incrementalQuinTreeLib.address
      }
    })

    const contract = await ContractFactory.deploy()

    await contract.deployed()

    if (logs) {
      console.info(`Test contract has been deployed to: ${contract.address}`)
    }

    return contract
  })
