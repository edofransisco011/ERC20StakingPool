// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Using Solidity 0.8+ which has built-in checks

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";
// REMOVED: import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/math/SafeMath.sol";

/**
 * @title StakingContract
 * @dev Allows users to stake an ERC20 token (MyToken) and earn rewards in the same token.
 * Rewards are calculated based on a rate set by the owner and distributed proportionally to stake amount over time.
 * Uses the Synthetix reward calculation pattern and Solidity 0.8+ built-in overflow/underflow checks.
 */
contract StakingContract is Ownable {
    // REMOVED: using SafeMath for uint256;

    // --- State Variables ---

    IERC20 public immutable stakingToken;

    mapping(address => uint256) public stakedBalance;
    uint256 public totalStaked;

    // Reward calculation variables
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    // --- Events ---

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardRateChanged(uint256 newRate);
    event RewardDeposited(uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    // --- Constructor ---

    constructor(address _stakingTokenAddress, address initialOwner) Ownable(initialOwner) {
        stakingToken = IERC20(_stakingTokenAddress);
        lastUpdateTime = block.timestamp;
    }

    // --- Modifiers ---

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[_account] = earned(_account);
        userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        _;
    }


    // --- Core Logic Functions ---

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        // Using standard operators - Solidity 0.8+ checks for overflow/underflow
        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        return rewardPerTokenStored + (timeElapsed * rewardRate * 1e18) / totalStaked;
    }

    function earned(address _account) public view returns (uint256) {
        // Using standard operators
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 userPaid = userRewardPerTokenPaid[_account];
        // Ensure subtraction doesn't underflow (shouldn't if logic is correct, but good practice)
        uint256 rewardPerTokenDelta = (currentRewardPerToken >= userPaid) ? currentRewardPerToken - userPaid : 0;

        return (stakedBalance[_account] * rewardPerTokenDelta) / 1e18 + rewards[_account];
    }

    function stake(uint256 _amount) public updateReward(msg.sender) {
        require(_amount > 0, "Cannot stake zero tokens");

        // Using standard operators
        totalStaked = totalStaked + _amount;
        stakedBalance[msg.sender] = stakedBalance[msg.sender] + _amount;

        bool success = stakingToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "ERC20: transferFrom failed");

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) public updateReward(msg.sender) {
        require(_amount > 0, "Cannot unstake zero tokens");
        uint256 userBalance = stakedBalance[msg.sender];
        require(userBalance >= _amount, "Insufficient staked balance");

        // Using standard operators
        totalStaked = totalStaked - _amount;
        stakedBalance[msg.sender] = userBalance - _amount;

        bool success = stakingToken.transfer(msg.sender, _amount);
        require(success, "ERC20: transfer failed");

        emit Unstaked(msg.sender, _amount);
    }

    function claimRewards() public updateReward(msg.sender) {
        uint256 rewardAmount = rewards[msg.sender];
        require(rewardAmount > 0, "No rewards to claim");

        rewards[msg.sender] = 0;

        require(stakingToken.balanceOf(address(this)) >= rewardAmount, "Insufficient reward balance in contract");

        bool success = stakingToken.transfer(msg.sender, rewardAmount);
        require(success, "ERC20: transfer failed");

        emit RewardPaid(msg.sender, rewardAmount);
    }


    // --- Owner Functions ---

    function setRewardRate(uint256 _rate) public onlyOwner updateReward(address(0)) { // address(0) signifies global update
        rewardRate = _rate;
        emit RewardRateChanged(_rate);
    }

    function depositRewardTokens(uint256 _amount) public onlyOwner {
         require(_amount > 0, "Cannot deposit zero tokens");
         bool success = stakingToken.transferFrom(msg.sender, address(this), _amount);
         require(success, "ERC20: transferFrom failed");
         emit RewardDeposited(_amount);
    }

}