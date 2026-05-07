# Frontier Fixed-Point Math Library Verification

Byte-for-byte bytecode verification for the fixed-point math library at `0x258c09146b7a28Dde8d3e230030e27643F91115F` — the `e_exp` / `ln` / `floor_log2` library that underpinned the world's first known on-chain LMSR prediction-market stack.

| Field | Value |
|---|---|
| Contract | [`0x258c09146b7a28Dde8d3e230030e27643F91115F`](https://etherscan.io/address/0x258c09146b7a28Dde8d3e230030e27643F91115F) |
| Network | Ethereum Mainnet |
| Block | 76,161 |
| Deployed | 2015-08-12 |
| Deployment tx | [`0x5cb8895a1255129e38dc16623958dd085d8ca60a50354bee77784692024ffdda`](https://etherscan.io/tx/0x5cb8895a1255129e38dc16623958dd085d8ca60a50354bee77784692024ffdda) |
| Deployer | [`0x77b97786b0fb73e55d9e92d4b182befbf346f979`](https://etherscan.io/address/0x77b97786b0fb73e55d9e92d4b182befbf346f979) |
| Compiler | `solc 0.1.0` (native C++ build), optimizer OFF |
| Runtime match | EXACT (1913 bytes) |
| Creation match | EXACT (1932 bytes) |

## What this contract is

A 64.64 fixed-point math library exposing three pure functions:

- `e_exp(uint x)` — natural exponential `e^x`. Splits the argument as `q*ln(2) + r` with `r` in `[0, ln(2))`, returns `2^q * (1 + Taylor(r))` evaluated to six Taylor terms with a small `+97423649007` Padé-style correction.
- `ln(uint x)` — natural logarithm. Computes `floor_log2(x)`, normalises `x` to a mantissa in `[1, 2)`, evaluates a 15-term Chebyshev polynomial seeded with a `10*2^64` bias, then converts log2 to ln by dividing by `log2(e) << 64`.
- `floor_log2(uint x)` — binary search across 192 bits of the upper half of the 64.64 input.

Plus three admin functions guarded by an owner slot: `MarketsContract` (the constructor, which is dispatched as a public method in solc 0.1.x and so can be re-called until ownership is set), `changeCreator`, and `deleteContract`.

This contract was deployed on August 12, 2015 — twelve days after Ethereum Frontier mainnet launched on July 30, 2015 — and is part of a three-contract LMSR prediction-market system by the same deployer:

- This math library at [`0x258c09146b7a28Dde8d3e230030e27643F91115F`](https://etherscan.io/address/0x258c09146b7a28Dde8d3e230030e27643F91115F).
- A difficulty resolution oracle at [`0x33cA8b5377c9776eb59863Fb63814dc00a5CB10D`](https://etherscan.io/address/0x33cA8b5377c9776eb59863Fb63814dc00a5CB10D) ([cartoonitunes/frontier-oracle-verification](https://github.com/cartoonitunes/frontier-oracle-verification)).
- An LMSR market-maker contract at [`0xdb7c577b93baeb56dab50af4d6f86f99a06b96a2`](https://etherscan.io/address/0xdb7c577b93baeb56dab50af4d6f86f99a06b96a2) — the deployment ran out of gas, so no code lives at that address.

The deployer is associated with the pre-Gnosis prediction-market team (Stefan George). To our knowledge this is the earliest deployed Solidity library on Ethereum mainnet that implements production-quality `exp`/`ln` over a fixed-point representation, predating Augur, Gnosis, and Polymarket by years.

## How the source was recovered

The on-chain runtime is 1913 bytes / ~970 opcodes. solc 0.1.0 produces no metadata trailer, no debug info, and no constructor arguments — only the raw constructor + runtime. Recovery proceeded by:

1. **Compiler fingerprinting.** A 4-line probe contract pinned the compiler to the native C++ `solc 0.1.0` (frontier-jul29) build rather than the soljson distributions of `0.1.1+`. Solc 0.1.0 emits function bodies in source-declaration order; later versions reverse the order.
2. **Selector recovery.** The six 4-byte selectors brute-forced cleanly to `MarketsContract()`, `changeCreator(address)`, `deleteContract()`, `e_exp(uint256)`, `ln(uint256)`, `floor_log2(uint256)` — matching the dispatch-table order in the runtime exactly.
3. **Algorithm reconstruction.** Each Taylor / Chebyshev coefficient appears as a `PUSH8`/`PUSH9` literal in the bytecode; the set of constants, plus the `2**64` and `ln(2)*2^64 = 12786308645202655660` divisors, identified the underlying fixed-point representation as 64.64.
4. **Iterative source matching.** Two probes converged on the canonical `Math.sol`. The non-obvious quirks of solc 0.1.0:
   - **Function order matters.** Source must declare `e_exp` before `ln` before `floor_log2`; that is the order the on-chain dispatch table emits the bodies. Other orderings produce different bytecode at every internal `JUMPDEST`.
   - **Operand order matters.** Each Taylor/Chebyshev term must be written `const * var / 2**64` (e.g. `12786308848809676358 * xk / 2**64`), not `var * const`. solc 0.1.0 evaluates RHS first, so the canonical form pushes `xk`, then the constant, then `MUL` — the byte-level shape is fragile to operand order.
   - **`(hi + lo) / 2` direction.** Reversing to `(lo + hi)` flips the stack layout in `floor_log2`'s loop.
   - **One `uint(...)` cast** on the `ln` constant `k = 2**64 * uint(10)` defeats solc 0.1.0's constant folder — without it the compiler folds `10 * 2**64` into a single `PUSH9 0x0a000000000000000000`, but the on-chain bytecode emits `PUSH1 0x0a; PUSH9 2**64; MUL` separately.

## Verification

```bash
./verify.sh
```

Requires Docker plus a locally-built `solc 0.1.0` image (see [`BUILD-COMPILER.md`](BUILD-COMPILER.md) — there is no public soljson for `0.1.0`). The script compiles `Math.sol`, then diffs the result against both `onchain-runtime.hex` and `onchain-creation.hex`.

## Files

- `Math.sol` — the canonical source.
- `onchain-runtime.hex` — `eth_getCode` result for the contract address (captured before the contract was selfdestructed).
- `onchain-creation.hex` — `eth_getTransactionByHash` input for the deployment transaction.
- `verify.sh` — reproducible compile + diff.
- `BUILD-COMPILER.md` — recipe for the `solc 0.1.0` Docker image.

## Attribution

Reconstruction by [EthereumHistory](https://ethereumhistory.com).
