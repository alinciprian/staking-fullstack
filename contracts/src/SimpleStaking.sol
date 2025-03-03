//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract SimpleStaking is ReentrancyGuard {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    uint256 immutable PRECISION = 10 ** 18;

    address owner;
    uint256 public rewardRate;
    // the total amount of staked tokens
    uint256 totalSupply;
    //last time rewards were distributed
    uint256 public lastRewardTimestamp;
    // starting Timestamp
    uint256 public startTimestamp;
    // (reward rate * dt * 1e18)/ totalSupply
    uint256 rewardPerTokenStored;
    // how much did each user stake
    mapping(address => uint256) public balanceOf;
    // rewards to be claimed by each user
    mapping(address => uint256) public rewards;
    mapping(address => uint256) rewardDebt;

    constructor(address _stakingToken, address _rewardToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        startTimestamp = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier updateRewardPerToken() {
        rewardPerTokenStored += ((block.timestamp - lastRewardTimestamp) * rewardRate * PRECISION) / totalSupply;
        lastRewardTimestamp = block.timestamp;
        _;
    }

    //There will be a fixed amount of reward that will be distributed over time across all participants
    //Each participant will get reward proportional to the amount of staked tokens over time

    //Each time deposit() or stake() functions are used by any user, the rewards accumulated will be distributed in the database

    // (rewardPerSecond * (block.timstamp - lastUpdateAt))/ totalSupply - how much a single token has accumulated in an interval of time

    //o functie de calcul pt rewards

    function stake(uint256 _amount) external updateRewardPerToken {
        require(_amount > 0, "amount must be greater than 0");

        rewardDebt[msg.sender] = _amount * rewardPerTokenStored;
        balanceOf[msg.sender] = _amount;
        totalSupply += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _amount) external updateRewardPerToken {
        require(_amount > 0, "amount must be greater than 0");
        require(_amount <= balanceOf[msg.sender], "not enough balance");
        balanceOf[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }
}
