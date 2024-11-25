// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Scorer is OwnableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(address => mapping(string => uint256)) private _scores; // User scores by type
    string[] public scoreTypes; // List of all score types

    event ScoreUpdated(address indexed user, string scoreType, uint256 newScore, uint256 oldScore);
    event ScoreTypeAdded(string scoreType);
    event ScoreTypeRemoved(string scoreType);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    /// @notice Initializes the contract by setting up its initial state.
    ///
    /// @param owner The owner address.
    function initialize(address owner) external initializer {
        __Ownable_init(owner);
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(ADMIN_ROLE, owner);
    }

    /// @notice Adds a new score type.
    ///
    /// @param scoreType The name of the score type to add.
    function addScoreType(string memory scoreType) external onlyOwner {
        scoreTypes.push(scoreType);
        emit ScoreTypeAdded(scoreType);
    }

    /// @notice Removes an existing score type.
    ///
    /// @param scoreType The name of the score type to remove.
    function removeScoreType(string memory scoreType) external onlyOwner {
        for (uint256 i = 0; i < scoreTypes.length; i++) {
            if (
                keccak256(bytes(scoreTypes[i])) ==
                keccak256(bytes(scoreType))
            ) {
                scoreTypes[i] = scoreTypes[scoreTypes.length - 1];
                scoreTypes.pop();
                emit ScoreTypeRemoved(scoreType);
                return;
            }
        }
        revert("Score type not found");
    }

    /// @notice Sets the score for a specific user and type.
    ///
    /// @param user The address of the user.
    /// @param scoreType The type of the score.
    /// @param newScore The new score value.
    function setScore(
        address user,
        string memory scoreType,
        uint256 newScore
    ) external onlyRole(ADMIN_ROLE) {
        // old score
        uint256 oldScore = _scores[user][scoreType];
        _scores[user][scoreType] = newScore;
        emit ScoreUpdated(user, scoreType, newScore, oldScore);
    }

    /// @notice Retrieves the score of a specific user for a given type.
    ///
    /// @param user The address of the user.
    /// @param scoreType The type of the score.
    /// @return The score value for the user and type.
    function score(
        address user,
        string memory scoreType
    ) external view returns (uint256) {
        return _scores[user][scoreType];
    }

    function addAdmin(address admin) external onlyOwner {
        grantRole(ADMIN_ROLE, admin);
        emit AdminAdded(admin);
    }

    function removeAdmin(address admin) external onlyOwner {
        revokeRole(ADMIN_ROLE, admin);
        emit AdminRemoved(admin);
    }

    function isAdmin(address admin) external view returns (bool) {
        return hasRole(ADMIN_ROLE, admin);
    }
}
