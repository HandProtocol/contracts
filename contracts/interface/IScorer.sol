// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IScorer {
        /**
     * @dev Returns the score of a specific user.
     *      The score is typically used to determine the user's eligibility for certain actions or claims.
     *      The exact logic for scoring is determined by the implementation of the contract that inherits this interface.
     *
     * @param user The address of the user whose score is being queried.
     * @return The score of the user as a uint256 value.
     * @notice This function should be implemented in the contract that inherits the `IScorer` interface.
     */
    function score(address user) external view returns (uint256);
}
