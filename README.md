# Privacy Preserving Smart Contract Rate Limiting

Simple contract modifier to add the ability to rate limit humans on any smart contract function call.

## Privacy Preserving?

This takes advantage of zero knowledge proof of inclusion. You will notice that this contract does not care at all
about `address`. This is by design! This means interaction with any of these function can be fully privacy preserving.

## Human?

This example takes advantage of an existing "anonymity set" which was built by the Worldcoin team. This set has
approximately 1.4 million _verified_ humans in it. You can opt into using a different set by modifyin the groupId
within the settings.

## Rate Limiting?

This library gives the contract creator the ability to create limits on the number of times that any given user can
call the function over a provided epoch. This is flexible users can set the epoch to near infitity if they dont want
the users to get a new set of calls or they can set it super low if they want it to refresh frequently, though because
proof creating and the settlement on the chain "epochId" needs to match, contract creators should consider proof time and
the amount of time until the transaction is actually included in a block.

## Why is rate limiting useful?

One obvious example is for a gas sponsoring relay. They may want to provide gas for humans that use their application,
but they dont want to get completely drained by a single human. This library allows protocols to control how much resource
is allocated to individual users.

Other use cases:

- faucets: drip assets to Humans but at controlled pace.
- rewarding user interactions in social networks
- fair(ish) allocation of scarce resource (nft drop)

---

## How to use (wip)

Check out `Contract.sol` to see this modifier in action.

```ts
    function sendMessage(
        uint256 input,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof,
        RateLimitKey calldata actionId,
        string calldata message
    ) public rateLimit(input, root, nullifierHash, actionId, proof) {
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();
        nullifierHashes[nullifierHash] = true;
        emit Message(message);
    }
```

## Todo

- [ ] Migrate to foundry. There was some issues with the worldcoin starter code that i didnt want to deal with
- [ ] small frontend demo?
- [ ] package this nicely for simple install (`forge install rsproule/this`)