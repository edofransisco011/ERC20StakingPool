# Simple ERC20 Staking Contract

## Project Description

This project implements a basic staking system on the Ethereum blockchain. Users can stake a specific ERC20 token (`MyToken`) into the `StakingContract` and earn rewards over time, also paid out in `MyToken`. The reward calculation follows the standard proportional distribution model often seen in DeFi protocols (similar to Synthetix).

This project is intended for educational purposes to demonstrate core Solidity concepts like ERC20 interaction, state management, access control, and basic DeFi reward mechanisms.

**Deployed on [Network Name, e.g., Sepolia Testnet] (Optional):**
* `MyToken` Address: `[0xAe06e41E1452cc39e4f2214f4674762303c257Cc]`
* `StakingContract` Address: `[0xAe06e41E1452cc39e4f2214f4674762303c257Cc]`

## Contracts

1.  **`MyToken.sol`**:
    * A standard ERC20 token contract inheriting from OpenZeppelin `ERC20.sol`.
    * Includes an `Ownable` pattern, allowing the contract owner (deployer) to `mint` new tokens. This is primarily for setup and funding the reward pool.

2.  **`StakingContract.sol`**:
    * The main contract where users stake `MyToken`.
    * Inherits from OpenZeppelin `Ownable.sol` for owner-specific functions.
    * Calculates and distributes rewards proportionally based on stake amount and time.
    * Requires the address of the deployed `MyToken` during deployment.

## Features

* **Stake:** Deposit `MyToken` into the contract.
* **Unstake:** Withdraw staked `MyToken` from the contract.
* **Claim Rewards:** Withdraw earned `MyToken` rewards.
* **Reward Calculation:** Rewards accrue based on a `rewardRate` set by the owner and the user's proportion of the total staked amount.
* **Owner Functions:**
    * `setRewardRate(uint256 _rate)`: Set the number of reward tokens distributed per second across all stakers.
    * `depositRewardTokens(uint256 _amount)`: Add `MyToken` to the contract to fund the reward pool (requires prior `approve` from owner to contract).

## Getting Started / Usage

You can compile, deploy, and interact with these contracts using tools like Remix IDE or Hardhat.

**1. Compilation:**
* **Remix:** Open files, select compiler version (`0.8.20` or compatible), click compile.
* **Hardhat:** Run `npx hardhat compile`.

**2. Deployment:**

* **Deploy `MyToken.sol`:**
    * Provide constructor arguments: `_name` (string, e.g., `"My Stake Token"`), `_symbol` (string, e.g., `"MST"`), `initialOwner` (address, usually your deployer address).
    * Note the deployed `MyToken` contract address.
* **Deploy `StakingContract.sol`:**
    * Provide constructor arguments: `_stakingTokenAddress` (address, the deployed `MyToken` address), `initialOwner` (address, usually your deployer address).
    * Note the deployed `StakingContract` address.

**3. Interaction:**

* **Minting (Owner Only):**
    * Call `mint(address to, uint256 amount)` on `MyToken` to create initial tokens for users or rewards. `amount` should include decimals (e.g., `1000 * 10**18` for 1000 tokens if 18 decimals).
* **Funding Rewards (Owner Only):**
    * Call `approve(address spender, uint256 amount)` on `MyToken`, setting `spender` to the `StakingContract` address and `amount` to the reward amount.
    * Call `depositRewardTokens(uint256 _amount)` on `StakingContract` with the amount approved.
* **Setting Reward Rate (Owner Only):**
    * Call `setRewardRate(uint256 _rate)` on `StakingContract`. `_rate` is the total reward tokens per second (e.g., `1 * 10**18 / 3600` for 1 token per hour).
* **Staking (User):**
    * Call `approve(address spender, uint256 amount)` on `MyToken`, setting `spender` to the `StakingContract` address and `amount` to the staking amount.
    * Call `stake(uint256 _amount)` on `StakingContract`.
* **Checking Earned Rewards (User):**
    * Call `earned(address _account)` view function on `StakingContract`.
* **Claiming Rewards (User):**
    * Call `claimRewards()` on `StakingContract`.
* **Unstaking (User):**
    * Call `unstake(uint256 _amount)` on `StakingContract`.

## Key Functions (StakingContract.sol)

* `stake(uint256 _amount)`: Deposits tokens, updates rewards. Requires prior `approve`.
* `unstake(uint256 _amount)`: Withdraws tokens, updates rewards.
* `claimRewards()`: Transfers earned rewards to the user.
* `earned(address _account)`: View function to check current pending rewards.
* `rewardPerToken()`: View function showing accumulated reward per token staked globally.
* `setRewardRate(uint256 _rate)`: Owner function to set reward distribution speed.
* `depositRewardTokens(uint256 _amount)`: Owner function to add funds for reward distribution. Requires prior `approve`.

## Disclaimer

This code is for educational purposes only and has not been audited for production use. Use at your own risk.
