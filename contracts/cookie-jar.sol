// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "./interface/IScorer.sol"; // Import the IScorer interface

contract nCookieJar is OwnableUpgradeable {
    using SafeERC20 for IERC20;
    address public token; // Address of USDGLO or address(0) for ETH
    IScorer public scorer; // Scoring contract for eligibility
    uint256 public dailyLimit; // Limit per user per day
    uint256 public totalBalance; // Total balance in the jar
    uint256 public scoreRequired; // Minimum score required to claim
    mapping(address => uint256) public lastClaimed; // Tracks last claim time for users

    event Deposit(address indexed depositor, uint256 amount);
    event Claimed(address indexed claimant, uint256 amount);
    event UpdatedDailyLimit(uint256 newLimit);
    event UpdatedScoreRequired(uint256 newScoreRequired);

    /// @notice Initializes this contract with its initial state.
    ///
    /// @dev This is a special initialization phase where external calls are not allowed,
    /// and it can be called only once at instance creation time.
    function initialize(
        address _token,
        address _scorer,
        uint256 _dailyLimit,
        address owner,
        uint256 _scoreRequired
    ) external initializer {
        __Ownable_init(owner); // Initialize OwnableUpgradeable

        token = _token;
        scorer = IScorer(_scorer);
        dailyLimit = _dailyLimit;
        scoreRequired = _scoreRequired;
    }

    /// @notice Deposits funds into this jar.
    ///
    /// @dev This can be either ETH or a specific token, depending on what's set in token.
    ///
    /// @param amount The value to add (in wei for ETH).
    function deposit(uint256 amount) external payable {
        if (token == address(0)) {
            // ETH deposit
            require(msg.value == amount, "Incorrect ETH amount");
        } else {
            // Token deposit
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }
        totalBalance += amount;
        emit Deposit(msg.sender, amount);
    }

    /**
     * @dev Allows users to claim a specified amount of funds from the contract.
     *      The claim is subject to the following conditions:
     *      - The amount claimed cannot exceed the daily limit (`dailyLimit`).
     *      - The user can only claim once every 24 hours, enforced by `lastClaimed`.
     *      - The user must have a score that meets or exceeds the required score (`scoreRequired`).
     *      - The contract must have enough funds to fulfill the claim.
     *
     * @param amount The amount of funds the user wishes to claim.
     * @notice Emits a `Claimed` event when the claim is successful.
     * @notice The function supports both ETH and ERC20 token claims. The behavior is based on whether `token` is set to `address(0)` (ETH).
     */
    function claim(uint256 amount) external {
        require(amount <= dailyLimit, "Exceeds daily limit");
        require(block.timestamp - lastClaimed[msg.sender] >= 1 days, "Daily claim limit reached");
        require(scorer.score(msg.sender) >= scoreRequired, "Score too low");
        require(amount <= totalBalance, "Insufficient funds in jar");

        lastClaimed[msg.sender] = block.timestamp;
        totalBalance -= amount;

        if (token == address(0)) {
            // Send ETH
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            // Send token
            IERC20(token).transfer(msg.sender, amount);
        }

        emit Claimed(msg.sender, amount);
    }

    function updateDailyLimit(uint256 newLimit) external onlyOwner {
        dailyLimit = newLimit;
        emit UpdatedDailyLimit(newLimit);
    }

    function setScoreRequired(uint256 newScoreRequired) external onlyOwner {
        scoreRequired = newScoreRequired;
        emit UpdatedScoreRequired(newScoreRequired);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= totalBalance, "Insufficient funds");

        totalBalance -= amount;
        if (token == address(0)) {
            // Withdraw ETH
            (bool success, ) = owner().call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            // Withdraw token
            IERC20(token).transfer(owner(), amount);
        }
    }

    function setScorer(address _scorer) external onlyOwner {
        scorer = IScorer(_scorer);
    }

    receive() external payable {
        totalBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
