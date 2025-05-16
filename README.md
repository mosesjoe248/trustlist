# 🔒 TrustList - A Whitelist/Allowlist Smart Contract on Stacks

The **TrustList** contract is a lightweight and reusable allowlist (whitelist) utility for the Stacks blockchain. It allows the contract owner to manage a list of trusted principals (wallet addresses) and enables other contracts or functions to check if a user is approved.

## 🚀 Features

- ✅ Owner-only management of trusted addresses.
- 🔍 Public `is-trusted` read-only function for checking trust status.
- 📦 Reusable across DeFi, NFT, DAO, or governance smart contracts.
- 🧩 Easy integration with Clarity-based authentication or permission logic.
- 📜 Emits events on trust list updates for transparency and auditability.

## 📦 Contract Functions

### Public Functions

| Function        | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `add-trusted`  | Adds a principal to the trust list (only callable by the contract owner).   |
| `remove-trusted`| Removes a principal from the trust list (only callable by the contract owner). |
| `is-trusted`   | Read-only function that checks whether a principal is in the trust list.    |

## 🔧 Usage

This contract is useful for:

- Controlling mint access for NFTs.
- Enabling identity-gated DAO or community participation.
- Providing a registry for third-party contracts to validate allowed users.

## 🧪 Testing

The contract includes tests to validate:

- Owner-only permissions
- Adding/removing addresses
- Correct trust status results

Run tests using Clarinet:

```bash
clarinet test
