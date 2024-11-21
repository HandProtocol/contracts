// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Scorer is OwnableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); // Define the ADMIN role

    mapping(address => uint256) private _scores; // User scores

    event ScoreUpdated(address indexed user, uint256 newScore);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    /// @notice Initialize this contract by setting up its initial state.
    ///
    /// This is a special initialization phase where external calls are not allowed,
    /// and it can only be called once at instance creation time.
    ///
    /// It sets the deployer as both owner and admin, granting them necessary permissions.
    function initialize(address owner) external initializer {
        __Ownable_init(owner);
        __AccessControl_init();

        // Grant the deployer both the owner and admin roles
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(ADMIN_ROLE, owner);
    }

    function setScore(address user, uint256 newScore)
        external
        onlyRole(ADMIN_ROLE)
    {
        _scores[user] = newScore;
        emit ScoreUpdated(user, newScore);
    }


      /**
     * @dev Returns the score of a specific user.
     *      The score is typically used to determine the user's eligibility for certain actions or claims.
     *      The exact logic for scoring is determined by the implementation of the contract that inherits this interface.
     *
     * @param user The address of the user whose score is being queried.
     * @return The score of the user as a uint256 value.
     * @notice This function should be implemented in the contract that inherits the `IScorer` interface.
     */
    function score(address user) external view returns (uint256) {
        return _scores[user];
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
