[licence-badge]: https://img.shields.io/github/license/rsproule/n-per-epoch?color=blue
[licence-url]: https://github.com/rsproule/n-per-epoch/blob/main/LICENSE
[actions-badge]: https://github.com/rsproule/n-per-epoch/actions/workflows/test.yml/badge.svg
[actions-url]: https://github.com/rsproule/n-per-epoch/actions/workflows/test.yml
[twitter-badge]: https://img.shields.io/twitter/follow/sproule_
[twitter-url]: https://twitter.com/sproule_
[local-example-url]: src/test/ExampleNPerEpochContract.sol
[worldid-docs]: https://docs.worldcoin.org/

# Privacy Preserving Smart Contract Rate Limiting

[![MIT licensed][licence-badge]][licence-url]
[![Build Status][actions-badge]][actions-url]
[![Twitter][twitter-badge]][twitter-url]

Simple contract modifier to add the ability to rate limit humans on any smart contract function call.

## Privacy Preserving?

This takes advantage of zero knowledge proof of inclusion. You will notice that this contract does not care at all
about `address`. This is by design! This means interaction with any of these function can be fully privacy preserving.

## Human?

This example takes advantage of an existing "anonymity set" which was built by [Worldcoin][worldid-docs]. This set has
approximately 1.4 million _verified_ humans in it. You can opt into using a different set by modifying the groupId
within the settings.

## Rate Limiting?

This library gives the contract creator the ability to create limits on the number of times that any given user can
call the function over a provided epoch. This is flexible users can set the epoch to near infinity if they dont want
the users to get a new set of calls or they can set it super low if they want it to refresh frequently, though because
proof creating and the settlement on the chain "epochId" needs to match, contract creators should consider proof time and
the amount of time until the transaction is actually included in a block.

## Why is rate limiting useful?

One obvious example is for a gas sponsoring relay. They may want to provide gas for humans that use their application,
but they dont want to get completely drained by a single human. This library allows protocols to control how much resource
is allocated to individual users.

Other use cases:

- faucets: drip assets to Humans but at controlled pace.
- rewarding user interactions in social networks while limiting the damage of spamming
- fair(ish) allocation of scarce resource (nft drop)

---

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

## How to use in your contracts (wip)

Check out [`ExampleNPerEpochContract.sol`][local-example-url] to see this modifier in action.

``` ts
import { NPerEpoch} from "../NPerEpoch.sol";
// ...
// ...
// ...
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
// ...
// ...
// ...
function settings()
    public
    pure
    virtual
    override
    returns (NPerEpoch.Settings memory)
{
    return Settings(1, 300, 2);
}
```

## Todo

- [x] Migrate to foundry. There was some issues with the worldcoin starter code that i didnt want to deal with
- [x] package this nicely for simple install (`forge install rsproule/n-per-epoch`)
- [x] migrate the scripts to typescript
- [ ] how to deploy to production (polygon)
- [ ] example repo (embedded or separate)
