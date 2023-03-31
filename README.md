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

<p align="center">
 <img src="assets/logo-n-per-epoch.png" alt="logo">
</p>

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
> ❗️Warning
>
> Be sure to take into account _proof generation time_ and the _block inclusion time_. The "epochId" must match for both proof and settlement on the chain. So _epochLength_ must be greater than the sum of _proof generation time_ and _block inclusion time_ with some buffer.
>

## Privacy Preserving?

You will notice that these contracts do not care at all about `msg.sender`. This is by design! Under the hood, this
takes advantage of zero knowledge proof of inclusion through the usage of the [semaphore][semaphore-link] library.
The contract enforces auth via the provided zk proof instead of relying on the signer of the transaction. [ERC4337][erc4337-link]
style account abstraction could trivially leverage this type of authentication!

## Human?

This example leverages an existing "anonymity set" developed by [Worldcoin][worldid-docs], comprising approximately 1.4 million verified human users. Worldcoin established this set by scanning individuals' irises and ensuring that each iris had not been previously added to the set. To utilize a different set, simply modify the groupId within the settings.

## Why is rate limiting useful?

1. __Prevent abuse__: By limiting the number of requests per user, it helps to prevent abuse of services or resources by malicious actors or bots. This ensures that genuine users have fair access to the system without being crowded out by automated scripts or attacks.

1. __Encourage fair distribution__: In scenarios where resources, rewards, or opportunities are limited, rate limiting human users ensures a more equitable distribution. This can help prevent a few users from monopolizing access to valuable assets or services, such as NFT drops or token faucets.

1. __Enhance user experience__: When resources are constrained, rate limiting human users can help maintain a smooth and responsive experience for legitimate users. By preventing system overload or resource depletion, it ensures that users can continue to interact with the application without disruption.

1. __Manage costs__: In blockchain applications, rate limiting human users can help manage costs associated with gas fees or other operational expenses. By controlling the frequency of transactions or function calls, service providers can optimize their expenses while still offering a valuable service to users.

1. __Preserve privacy__: By focusing on human users and leveraging privacy-preserving techniques, rate limiting can be implemented without compromising user privacy. This is particularly important in decentralized systems, where trust in the system is often built on the foundation of user privacy and data security.

## Example use-cases

- __Gas-sponsoring relays__: These relays aim to provide gas for human users of their applications while preventing resource depletion by a single user. This library effectively enables protocols to manage resource allocation for individual users.
- __Faucets__: Distribute assets to human users at a controlled pace, preventing abuse.
- __Rewarding user interactions on social networks__: Rate limiting helps limit the impact of spamming while still encouraging genuine engagement.
- __Fair allocation of scarce resources (e.g., NFT drops)__: By implementing rate limiting, each human user could be allowed to mint a specific amount (e.g., one per hour), promoting equitable distribution.

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

## TODO

- [x] Migrate to foundry. There was some issues with the worldcoin starter code that i didnt want to deal with
- [x] package this nicely for simple install (`forge install rsproule/n-per-epoch`)
- [x] migrate the scripts to typescript
- [ ] how to deploy to production (polygon)
- [ ] example repo (embedded or separate)
