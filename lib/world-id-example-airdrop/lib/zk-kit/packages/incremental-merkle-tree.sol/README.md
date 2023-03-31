<p align="center">
    <h1 align="center">
         Incremental Merkle Trees (Solidity)
    </h1>
    <p align="center">Incremental Merkle tree Solidity libraries.</p>
</p>

<p align="center">
    <a href="https://github.com/appliedzkp/zk-kit">
        <img src="https://img.shields.io/badge/project-zk--kit-blue.svg?style=flat-square">
    </a>
    <a href="https://github.com/appliedzkp/zk-kit/blob/main/LICENSE">
        <img alt="Github license" src="https://img.shields.io/github/license/appliedzkp/zk-kit.svg?style=flat-square">
    </a>
    <a href="https://www.npmjs.com/package/@zk-kit/incremental-merkle-tree.sol">
        <img alt="NPM version" src="https://img.shields.io/npm/v/@zk-kit/incremental-merkle-tree.sol?style=flat-square" />
    </a>
    <a href="https://npmjs.org/package/@zk-kit/incremental-merkle-tree.sol">
        <img alt="Downloads" src="https://img.shields.io/npm/dm/@zk-kit/incremental-merkle-tree.sol.svg?style=flat-square" />
    </a>
    <a href="https://eslint.org/">
        <img alt="Linter eslint" src="https://img.shields.io/badge/linter-eslint-8080f2?style=flat-square&logo=eslint" />
    </a>
    <a href="https://prettier.io/">
        <img alt="Code style prettier" src="https://img.shields.io/badge/code%20style-prettier-f8bc45?style=flat-square&logo=prettier" />
    </a>
</p>

<div align="center">
    <h4>
        <a href="https://discord.gg/9B9WgGP6YM">
            🗣️ Chat &amp; Support
        </a>
    </h4>
</div>

## Libraries:

✔️ [IncrementalBinaryTree](https://github.com/appliedzkp/zk-kit/blob/main/packages/incremental-merkle-tree.sol/contracts/IncrementalBinaryTree.sol) (Poseidon)\
✔️ [IncrementalQuinTree](https://github.com/appliedzkp/zk-kit/blob/main/packages/incremental-merkle-tree.sol/contracts/IncrementalQuinTree.sol) (Poseidon)

> The methods of each library are always the same (i.e `insert`, `remove`, `verify`).

---

## 🛠 Install

### npm or yarn

Install the `@zk-kit/incremental-merkle-tree.sol` package with npm:

```bash
npm i @zk-kit/incremental-merkle-tree.sol --save
```

or yarn:

```bash
yarn add @zk-kit/incremental-merkle-tree.sol
```

## 📜 Usage

### Importing and using the library

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@zk-kit/incremental-merkle-tree.sol/contracts/IncrementalBinaryTree.sol";

contract Example {
  using IncrementalBinaryTree for IncrementalTreeData;

  event TreeCreated(bytes32 id, uint8 depth);
  event LeafInserted(bytes32 indexed treeId, uint256 leaf, uint256 root);
  event LeafRemoved(bytes32 indexed treeId, uint256 leaf, uint256 root);

  mapping(bytes32 => IncrementalTreeData) public trees;

  function createTree(bytes32 _id, uint8 _depth) external {
    require(trees[_id].depth == 0, "Example: tree already exists");

    trees[_id].init(_depth, 0);

    emit TreeCreated(_id, _depth);
  }

  function insertLeaf(bytes32 _treeId, uint256 _leaf) external {
    require(trees[_treeId].depth != 0, "Example: tree does not exist");

    trees[_treeId].insert(_leaf);

    emit LeafInserted(_treeId, _leaf, trees[_treeId].root);
  }

  function removeLeaf(
    bytes32 _treeId,
    uint256 _leaf,
    uint256[] calldata _proofSiblings,
    uint8[] calldata _proofPathIndices
  ) external {
    require(trees[_treeId].depth != 0, "Example: tree does not exist");

    trees[_treeId].remove(_leaf, _proofSiblings, _proofPathIndices);

    emit LeafRemoved(_treeId, _leaf, trees[_treeId].root);
  }
}

```

### Creating an Hardhat task to deploy the contract

```typescript
import { poseidon_gencontract as poseidonContract } from "circomlibjs"
import { Contract } from "ethers"
import { task, types } from "hardhat/config"

task("deploy:example", "Deploy an Example contract")
  .addOptionalParam<boolean>("logs", "Print the logs", true, types.boolean)
  .setAction(async ({ logs }, { ethers }): Promise<Contract> => {
    const poseidonT3ABI = poseidonContract.generateABI(2)
    const poseidonT3Bytecode = poseidonContract.createCode(2)

    const [signer] = await ethers.getSigners()

    const PoseidonLibT3Factory = new ethers.ContractFactory(poseidonT3ABI, poseidonT3Bytecode, signer)
    const poseidonT3Lib = await PoseidonLibT3Factory.deploy()

    await poseidonT3Lib.deployed()

    logs && console.log(`PoseidonT3 library has been deployed to: ${poseidonT3Lib.address}`)

    const IncrementalBinaryTreeLibFactory = await ethers.getContractFactory("IncrementalBinaryTree", {
      libraries: {
        PoseidonT3: poseidonT3Lib.address
      }
    })
    const incrementalBinaryTreeLib = await IncrementalBinaryTreeLibFactory.deploy()

    await incrementalBinaryTreeLib.deployed()

    logs && console.log(`IncrementalBinaryTree library has been deployed to: ${incrementalBinaryTreeLib.address}`)

    const ContractFactory = await ethers.getContractFactory("Example", {
      libraries: {
        IncrementalBinaryTree: incrementalBinaryTreeLib.address
      }
    })

    const contract = await ContractFactory.deploy()

    await contract.deployed()

    logs && console.log(`Example contract has been deployed to: ${contract.address}`)

    return contract
  })
```

## Contacts

### Developers

- e-mail : me@cedoor.dev
- github : [@cedoor](https://github.com/cedoor)
- website : https://cedoor.dev
