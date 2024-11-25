// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "./interface/IScorer.sol"; // Import the IScorer interface

contract nCookieJar is OwnableUpgradeable {
    using SafeERC20 for IERC20;

    address public constant ETHER = address(0); // Placeholder for Ether
    IScorer public scorer; // Scoring contract for eligibility

    struct Round {
        uint256 start; // Start timestamp of the round
        uint256 end; // End timestamp of the round
        string metadataURI; // IPFS URI for round metadata
    }

    Round public currentRound; // Current round details

    // Tracks balances for each token (including Ether)
    mapping(address => uint256) public totalBalances;
    // Allowed amounts per user per token
    mapping(address => mapping(address => uint256)) public allowedAmounts;

    event Deposit(address indexed depositor, address indexed token, uint256 amount);
    event Claimed(address indexed claimant, address indexed token, uint256 amount);
    event AllowedAmountUpdated(address indexed user, address indexed token, uint256 newAmount);
    event RoundUpdated(uint256 start, uint256 end, string metadataURI);

    /// @notice Initializes this contract with its initial state.
    ///
    /// @param _scorer The scoring contract address.
    /// @param owner The owner address.
    function initialize(address _scorer, address owner) external initializer {
        __Ownable_init(owner); // Initialize OwnableUpgradeable
        scorer = IScorer(_scorer);
    }

    /// @notice Deposits funds into this jar for a specific token or Ether.
    ///
    /// @param token The token address (address(0) for Ether).
    /// @param amount The value to add (in wei for Ether).
    function deposit(address token, uint256 amount) external payable {
        if (token == ETHER) {
            require(msg.value == amount, "Incorrect Ether amount");
        } else {
            require(amount > 0, "Deposit amount must be greater than zero");
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }

        totalBalances[token] += amount;
        emit Deposit(msg.sender, token, amount);
    }

    /// @notice Claims the full allowed amount for a user during the round.
    function claim(address token) external {
        require(block.timestamp >= currentRound.start && block.timestamp <= currentRound.end, "Not within round duration");

        uint256 userAllowedAmount = allowedAmounts[msg.sender][token];
        require(userAllowedAmount > 0, "No claimable amount");
        require(totalBalances[token] >= userAllowedAmount, "Insufficient funds in jar");

        // Check the user's Trust score from the scorer
        bytes32 trustKey = keccak256("Trust");
        require(scorer.score(msg.sender, trustKey) > 0, "Insufficient Trust score");

        allowedAmounts[msg.sender][token] = 0;
        totalBalances[token] -= userAllowedAmount;

        if (token == ETHER) {
            (bool success, ) = msg.sender.call{value: userAllowedAmount}("");
            require(success, "Ether transfer failed");
        } else {
            IERC20(token).safeTransfer(msg.sender, userAllowedAmount);
        }

        emit Claimed(msg.sender, token, userAllowedAmount);
    }

    /// @notice Sets the allowed amount for a specific user and token.
    ///
    /// @param user The address of the user.
    /// @param token The token address.
    /// @param amount The allowed amount for the user.
    function setAllowedAmount(address user, address token, uint256 amount) external onlyOwner {
        allowedAmounts[user][token] = amount;
        emit AllowedAmountUpdated(user, token, amount);
    }

    /// @notice Sets the round duration and metadata URI.
    ///
    /// @param start The start timestamp of the round.
    /// @param end The end timestamp of the round.
    /// @param metadataURI The IPFS URI for the round metadata.
    function setRound(uint256 start, uint256 end, string memory metadataURI) external onlyOwner {
        require(start < end, "Start time must be before end time");
        currentRound = Round(start, end, metadataURI);
        emit RoundUpdated(start, end, metadataURI);
    }

    /// @notice Withdraws funds from the jar for a specific token or Ether.
    ///
    /// @param token The token address (address(0) for Ether).
    /// @param amount The amount to withdraw.
    function withdraw(address token, uint256 amount) external onlyOwner {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(totalBalances[token] >= amount, "Insufficient funds");

        totalBalances[token] -= amount;

        if (token == ETHER) {
            (bool success, ) = owner().call{value: amount}("");
            require(success, "Ether transfer failed");
        } else {
            IERC20(token).safeTransfer(owner(), amount);
        }
    }

    /// @notice Allows Ether deposits directly via fallback function.
    receive() external payable {
        totalBalances[ETHER] += msg.value;
        emit Deposit(msg.sender, ETHER, msg.value);
    }
}
