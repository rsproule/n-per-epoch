[licence-badge]: https://img.shields.io/github/license/rsproule/n-per-epoch?color=blue
[licence-url]: https://github.com/rsproule/n-per-epoch/blob/main/LICENSE
[actions-badge]: https://github.com/rsproule/n-per-epoch/actions/workflows/test.yml/badge.svg
[actions-url]: https://github.com/rsproule/n-per-epoch/actions/workflows/test.yml
[twitter-badge]: https://img.shields.io/twitter/follow/sproule_
[twitter-url]: https://twitter.com/sproule_
[local-example-url]: src/test/ExampleNPerEpochContract.sol
[worldid-docs]: https://docs.worldcoin.org/
[semaphore-link]: https://semaphore.appliedzkp.org/
[erc4337-link]: https://eips.ethereum.org/EIPS/eip-4337/

# Privacy Preserving Smart Contract Rate Limiting

[![MIT licensed][licence-badge]][licence-url]
[![Build Status][actions-badge]][actions-url]
[![Twitter][twitter-badge]][twitter-url]

Simple contract modifier to add the ability to rate limit humans on any smart contract function call.

## Install / Build / Test

Install

``` sh
git clone git@github.com:rsproule/n-per-epoch.git
```

Build

``` sh
make 
```

Run the unit tests:

``` sh
make test
```

---

## Rate Limiting?

This library enables contract creators to set limits on the number of times a specific user can call a function within a defined epoch. The epoch duration is highly flexible, allowing developers to set it to near infinity (1 per forever) or to a very short duration for higher throughput. 
> **🚨🚨🚨** Be sure to take into account _proof generation time_ and the _block inclusion time_. The "epochId" must match for both proof and settlement on the chain. So _epochLength_ must be greater than the sum of _proof generation time_ and _block inclusion time_ with some buffer.


## Privacy Preserving?

You will notice that these contracts do not care at all about `msg.sender`. This is by design! Under the hood, this
takes advantage of zero knowledge proof of inclusion through the usage of the [semaphore][semaphore-link] library.
The contract enforces auth via the provided zk proof instead of relying on the signer of the transaction. [ERC4337][erc4337-link]
style account abstraction could trivially leverage this type of authentication!

## Human?

This example takes advantage of an existing "anonymity set" which was built by [Worldcoin][worldid-docs]. This set has
approximately 1.4 million _verified_ humans in it. You can opt into using a different set by modifying the groupId
within the settings.

---

## Why is rate limiting useful?

One obvious example is for a gas sponsoring relay. They may want to provide gas for humans that use their application,
but they dont want to get completely drained by a single human. This library allows protocols to control how much resource
is allocated to individual users.

Other use cases:

- __faucets__: Drip assets to humans but at controlled pace.
- Rewarding user interactions in social networks while limiting the damage of spamming
- Fair(ish) allocation of scarce resource (nft drop)
  - ex: each human can mint 1 per hour

---

## How to use in your contracts (wip)

Check out [`ExampleNPerEpochContract.sol`][local-example-url] to see this modifier in action.

``` ts
import { NPerEpoch} from "../NPerEpoch.sol";
...
...
...
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
    if (nullifierHashes[nullifierHash]) revert InvalidNullifier();
    nullifierHashes[nullifierHash] = true;
    emit Message(input);
}
...
...
...
function settings()
    public
    pure
    virtual
    override
    returns (NPerEpoch.Settings memory)
{
    return Settings(1, 300, 2); // groupId (worldID=1), epochLength, numPerEpoch)
}
```

## Todo

- [x] Migrate to foundry. There was some issues with the worldcoin starter code that i didnt want to deal with
- [x] package this nicely for simple install (`forge install rsproule/n-per-epoch`)
- [x] migrate the scripts to typescript
- [ ] how to deploy to production (polygon)
- [ ] example repo (embedded or separate)
